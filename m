Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 884239003C7
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 00:13:22 -0400 (EDT)
Received: by pawu10 with SMTP id u10so28783719paw.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 21:13:22 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id uj2si1563486pac.163.2015.08.12.21.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 21:13:21 -0700 (PDT)
Received: by pdco4 with SMTP id o4so14673458pdc.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 21:13:21 -0700 (PDT)
Date: Wed, 12 Aug 2015 21:12:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: page-flags behavior on compound pages: a worry
In-Reply-To: <20150812222136.GA15010@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1508122038380.4539@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1508052001350.6404@eggly.anvils> <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils> <20150812143509.GA12320@node.dhcp.inet.fi> <20150812141644.ceb541e5b52d76049339a243@linux-foundation.org> <20150812222136.GA15010@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 13 Aug 2015, Kirill A. Shutemov wrote:
> 
> All this situation is ugly. I'm thinking on more general solution for
> PageTail() vs. ->first_page race.
> 
> We would be able to avoid the race in first place if we encode PageTail()
> and position of head page within the same word in struct page. This way we
> update both thing in one shot without possibility of race.
> 
> Details get tricky.
> 
> I'm going to try tomorrow something like this: encode the position of head
> as offset from the tail page and store it as negative number in the union
> with ->mapping and ->s_mem. PageTail() can be implemented as check value
> of the field to be in range -1..-MAX_ORDER_NR_PAGES. 
> 
> I'm not sure at all if it's going to work, especially looking on
> ridiculously high CONFIG_FORCE_MAX_ZONEORDER some architectures allow.
> 
> We could also try to encode page order instead (again as negative number)
> and calculate head page position based on alignment...
> 
> Any other ideas are welcome.

Good luck, I've not given it any thought, but hope it works out:
my reasoning was the same when I put the PageAnon bit into
page->mapping instead of page->flags.

Something to beware of though: although exceedingly unlikely to be a
problem, page->mapping always contained a pointer to or into a relevant
structure, or else something that could not possibly be a kernel pointer,
when I was working on KSM swapping: see comment above get_ksm_page() in
mm/ksm.c.  It is best to keep page->mapping for pointers if possible
(and probably avoid having the PageAnon bit set unless really Anon).

I've only just read your mail, and I'm too slow a thinker to have
worked through your isolate_migratepages_block() race yet.  But, given
the timing, cannot resist sending you a code fragment I wrote earlier
today for our v3.11-based kernel: which still has compound_trans_order(),
which we had been using in a similar racy physical scan.

I'm not for a moment suggesting that this fragment is relevant to your
race; but it is something amusing to consider when you're thinking of
such races.  Credit to Greg Thelen for thinking of the prep_compound_page()
end of it, when I'd been focussed on the __split_huge_page_refcount() end.

	/*
	 * It is not safe to use compound_lock (inside compound_trans_order)
	 * until we have a reference on the page (okay, done above) and have
	 * then seen PageLRU on it (just below): because mm/huge_memory.c uses
	 * the non-atomic __SetPageUptodate on a freshly allocated THPage in
	 * several places, believing it to be invisible to the outside world,
	 * but liable to race and leave PG_compound_lock set when cleared here.
	 */
	nr_pages = 1;
	if (PageHead(page)) {
		/*
		 * smp_rmb() against the smp_wmb() in the first iteration of
		 * prep_compound_page(), so that the PageTail test ensures
		 * that compound_order(page) is now correctly readable.
		 */
		smp_rmb();
		if (PageTail(page + 1)) {
			nr_pages = 1 << compound_order(page);
			/*
			 * Then smp_rmb() against smp_wmb() in last iteration of
			 * __split_huge_page_refcount(), to ensure that has not
			 * yet written something else into page[1].lru.prev.
			 */
			smp_rmb();
			if (!PageTail(page + 1))
				nr_pages = 1;
		}
	}

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
