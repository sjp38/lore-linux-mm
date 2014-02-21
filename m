Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEC76B00CB
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 12:25:31 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u57so2805216wes.13
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 09:25:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t6si8846218wjq.152.2014.02.21.09.25.28
        for <linux-mm@kvack.org>;
        Fri, 21 Feb 2014 09:25:29 -0800 (PST)
Date: Fri, 21 Feb 2014 12:25:12 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53078c09.c63ac20a.7b53.ffffd227SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <53078A53.9030302@oracle.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-12-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5306F29D.8070600@gmail.com>
 <530785b2.d55c8c0a.3868.ffffa4e1SMTPIN_ADDED_BROKEN@mx.google.com>
 <53078A53.9030302@oracle.com>
Subject: Re: [PATCH 11/11] mempolicy: apply page table walker on
 queue_pages_range()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Fri, Feb 21, 2014 at 12:18:11PM -0500, Sasha Levin wrote:
> On 02/21/2014 11:58 AM, Naoya Horiguchi wrote:
> > On Fri, Feb 21, 2014 at 01:30:53AM -0500, Sasha Levin wrote:
> >> On 02/10/2014 04:44 PM, Naoya Horiguchi wrote:
> >>> queue_pages_range() does page table walking in its own way now,
> >>> so this patch rewrites it with walk_page_range().
> >>> One difficulty was that queue_pages_range() needed to check vmas
> >>> to determine whether we queue pages from a given vma or skip it.
> >>> Now we have test_walk() callback in mm_walk for that purpose,
> >>> so we can do the replacement cleanly. queue_pages_test_walk()
> >>> depends on not only the current vma but also the previous one,
> >>> so we use queue_pages->prev to keep it.
> >>>
> >>> ChangeLog v2:
> >>> - rebase onto mmots
> >>> - add VM_PFNMAP check on queue_pages_test_walk()
> >>>
> >>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>> ---
> >>
> >> Hi Naoya,
> >>
> >> I'm seeing another spew in today's -next, and it seems to be related
> >> to this patch. Here's the spew (with line numbers instead of kernel
> >> addresses):
> > 
> > Thanks. (line numbers translation is very helpful.)
> > 
> > This bug looks strange to me.
> > "kernel BUG at mm/hugetlb.c:3580" means we try to do isolate_huge_page()
> > for !PageHead page. But the caller queue_pages_hugetlb() gets the page
> > with "page = pte_page(huge_ptep_get(pte))", so it should be the head page!
> > 
> > mm/hugetlb.c:3580 is VM_BUG_ON_PAGE(!PageHead(page), page), so we expect to
> > have dump_page output at this point, is that in your kernel log?
> 
> This is usually a sign of a race between that code and thp splitting, see
> https://lkml.org/lkml/2013/12/23/457 for example.

queue_pages_hugetlb() is for hugetlbfs, not for thp, so I don't think that
it's related to thp splitting, but I agree it's a race.

> I forgot to add the dump_page output to my extraction process and the complete logs all long gone.
> I'll grab it when it happens again.

Thank you. It'll be useful.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
