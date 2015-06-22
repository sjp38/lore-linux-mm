Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E318C6B006E
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 07:28:17 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so138626528wgb.2
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:28:17 -0700 (PDT)
Received: from johanna4.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id s2si19218755wiy.117.2015.06.22.04.28.15
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 04:28:16 -0700 (PDT)
Date: Mon, 22 Jun 2015 14:28:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 32/36] thp: reintroduce split_huge_page()
Message-ID: <20150622112800.GD7934@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1433351167-125878-33-git-send-email-kirill.shutemov@linux.intel.com>
 <55785B5E.3000306@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55785B5E.3000306@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 10, 2015 at 05:44:30PM +0200, Vlastimil Babka wrote:
> On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> >+static int __split_huge_page_tail(struct page *head, int tail,
> >+		struct lruvec *lruvec, struct list_head *list)
> >+{
> >+	int mapcount;
> >+	struct page *page_tail = head + tail;
> >+
> >+	mapcount = page_mapcount(page_tail);
> 
> Isn't page_mapcount() unnecessarily heavyweight here? When you are splitting
> a page, it already should have zero compound_mapcount() and shouldn't be
> PageDoubleMap(), no? So you should care about page->_mapcount only? Sure,
> splitting THP is not a hotpath, but when done 512 times per split, it could
> make some difference in the split's latency.

Okay, replaced with direct atomic_read().

> >+	VM_BUG_ON_PAGE(atomic_read(&page_tail->_count) != 0, page_tail);
> >+
> >+	/*
> >+	 * tail_page->_count is zero and not changing from under us. But
> >+	 * get_page_unless_zero() may be running from under us on the
> >+	 * tail_page. If we used atomic_set() below instead of atomic_add(), we
> >+	 * would then run atomic_set() concurrently with
> >+	 * get_page_unless_zero(), and atomic_set() is implemented in C not
> >+	 * using locked ops. spin_unlock on x86 sometime uses locked ops
> >+	 * because of PPro errata 66, 92, so unless somebody can guarantee
> >+	 * atomic_set() here would be safe on all archs (and not only on x86),
> >+	 * it's safer to use atomic_add().
> 
> I would be surprised if this was the first place to use atomic_set() with
> potential concurrent atomic_add(). Shouldn't atomic_*() API guarantee that
> this works?

I don't have much insight on the issue. This part is carried over from
pre-rework split_huge_page().

> 
> >+	 */
> >+	atomic_add(page_mapcount(page_tail) + 1, &page_tail->_count);
> 
> You already have the value in mapcount variable, so why read it again.

Fixed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
