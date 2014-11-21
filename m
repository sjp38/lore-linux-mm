Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C35C16B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 06:47:35 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so11772606wiw.7
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 03:47:35 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id gr2si9369393wib.74.2014.11.21.03.47.33
        for <linux-mm@kvack.org>;
        Fri, 21 Nov 2014 03:47:33 -0800 (PST)
Date: Fri, 21 Nov 2014 13:47:09 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
Message-ID: <20141121114709.GA16647@node.dhcp.inet.fi>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
 <20141118084337.GA16714@hori1.linux.bs1.fc.nec.co.jp>
 <20141118095811.GA21774@node.dhcp.inet.fi>
 <87egsx6oo1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87egsx6oo1.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Nov 21, 2014 at 12:11:34PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> 
> > On Tue, Nov 18, 2014 at 08:43:00AM +0000, Naoya Horiguchi wrote:
> >> > @@ -1837,6 +1839,9 @@ static void __split_huge_page_refcount(struct page *page,
> >> >  	atomic_sub(tail_count, &page->_count);
> >> >  	BUG_ON(atomic_read(&page->_count) <= 0);
> >> >  
> >> > +	page->_mapcount = *compound_mapcount_ptr(page);
> >> 
> >> Is atomic_set() necessary?
> >
> > Do you mean
> > 	atomic_set(&page->_mapcount, atomic_read(compound_mapcount_ptr(page)));
> > ?
> >
> > I don't see why we would need this. Simple assignment should work just
> > fine. Or we have archs which will break?
> 
> Are you looking at architecture related atomic_set issues, or the fact
> that we cannot have parallel _mapcount update and hence the above
> assignment should be ok ? If the former, current thp code
> use atomic_add instead of even using atomic_set when
> updatinge page_tail->_count.  
> 
> 		 * from under us on the tail_page. If we used
> 		 * atomic_set() below instead of atomic_add(), we
> 		 * would then run atomic_set() concurrently with
> 		 * get_page_unless_zero(), and atomic_set() is
> 		 * implemented in C not using locked ops. spin_unlock
> 		 * on x86 sometime uses locked ops because of PPro
> 		 * errata 66, 92, so unless somebody can guarantee
> 		 * atomic_set() here would be safe on all archs (and
> 		 * not only on x86), it's safer to use atomic_add().
> 		 */
> 		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
> 			   &page_tail->_count);

We don't have anything like get_page_unless_zero() for _mapcount as far as
I can see. And we have similar assignment there now:

	page_tail->_mapcount = page->_mapcount;

Anyway the assignment goes away by the end of patchset.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
