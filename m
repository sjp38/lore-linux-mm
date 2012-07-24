Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 6793F6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 21:09:03 -0400 (EDT)
Received: by ggm4 with SMTP id 4so7455857ggm.14
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 18:09:02 -0700 (PDT)
Date: Mon, 23 Jul 2012 18:08:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
In-Reply-To: <20120723114007.GU9222@suse.de>
Message-ID: <alpine.LSU.2.00.1207231702440.1683@eggly.anvils>
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <20120723114007.GU9222@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, 23 Jul 2012, Mel Gorman wrote:
> On Sun, Jul 22, 2012 at 09:04:33PM -0700, Hugh Dickins wrote:
> > On Fri, 20 Jul 2012, Mel Gorman wrote:
> > > On Fri, Jul 20, 2012 at 04:36:35PM +0200, Michal Hocko wrote:
> 
> I like it in that it's simple and I can confirm it works for the test case
> of interest.

Phew, I'm glad to hear that, thanks.

> 
> However, is your patch not vunerable to truncate issues?
> madvise()/truncate() issues was the main reason why I was wary of VMA tricks
> as a solution. As it turns out, madvise(DONTNEED) is not a problem as it is
> ignored for hugetlbfs but I think truncate is still problematic. Lets say
> we mmap(MAP_SHARED) a hugetlbfs file and then truncate for whatever reason.
> 
> invalidate_inode_pages2
>   invalidate_inode_pages2_range
>     unmap_mapping_range_vma
>       zap_page_range_single
>         unmap_single_vma
> 	  __unmap_hugepage_range (removes VM_MAYSHARE)
> 
> The VMA still exists so the consequences for this would be varied but
> minimally fault is going to be "interesting".

You had me worried there, I hadn't considered truncation or invalidation2
at all.

But actually, I don't think they do pose any problem for my patch.  They
would indeed if I were removing VM_MAYSHARE in __unmap_hugepage_range()
as you show above; but no, I'm removing it in unmap_hugepage_range().

That's only called by unmap_single_vma(): which is called via
unmap_vmas() by unmap_region() or exit_mmap() just before free_pgtables()
(the problem cases); or by madvise_dontneed() via zap_page_range(), which
as you note is disallowed on VM_HUGETLB; or by zap_page_range_single().

zap_page_range_single() is called by zap_vma_ptes(), which is only
allowed on VM_PFNMAP; or by unmap_mapping_range_vma(), which looked
like it was going to deadlock on i_mmap_mutex (with or without my
patch) until I realized that hugetlbfs has its own hugetlbfs_setattr()
and hugetlb_vmtruncate() which don't use unmap_mapping_range() at all.

invalidate_inode_pages2() (and _range()) do use unmap_mapping_range(),
but hugetlbfs doesn't support direct_IO, and otherwise I think they're
called by a filesystem directly on its own inodes, which hugetlbfs
does not.  Anyway, if there's a deadlock on i_mmap_mutex somewhere
in there, it's not introduced by the proposed patch.

So, unmap_hugepage_range() is only being called in the problem cases,
just before free_pgtables(), when unmapping a vma (with mmap_sem held),
or when exiting (when we have the last reference to mm): in each case,
the vma is on its way out, and VM_MAYSHARE no longer of interest to others.

I spent a while concerned that I'd overlooked the truncation case, before
realizing that it's not a problem: the issue comes when we free_pgtables(),
which truncation makes no attempt to do.

So, after a bout of anxiety, I think my &= ~VM_MAYSHARE remains good.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
