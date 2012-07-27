Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 880E46B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 04:48:01 -0400 (EDT)
Date: Fri, 27 Jul 2012 09:47:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: hugetlbfs: Close race during teardown of hugetlbfs
 shared page tables v2
Message-ID: <20120727084756.GB612@suse.de>
References: <20120720134937.GG9222@suse.de>
 <501169C0.3070805@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <501169C0.3070805@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 26, 2012 at 12:01:04PM -0400, Larry Woodman wrote:
> On 07/20/2012 09:49 AM, Mel Gorman wrote:
> >+retry:
> >  	mutex_lock(&mapping->i_mmap_mutex);
> >  	vma_prio_tree_foreach(svma,&iter,&mapping->i_mmap, idx, idx) {
> >  		if (svma == vma)
> >  			continue;
> >+		if (svma->vm_mm == vma->vm_mm)
> >+			continue;
> >+
> >+		/*
> >+		 * The target mm could be in the process of tearing down
> >+		 * its page tables and the i_mmap_mutex on its own is
> >+		 * not sufficient. To prevent races against teardown and
> >+		 * pagetable updates, we acquire the mmap_sem and pagetable
> >+		 * lock of the remote address space. down_read_trylock()
> >+		 * is necessary as the other process could also be trying
> >+		 * to share pagetables with the current mm. In the fork
> >+		 * case, we are already both mm's so check for that
> >+		 */
> >+		if (locked_mm != svma->vm_mm) {
> >+			if (!down_read_trylock(&svma->vm_mm->mmap_sem)) {
> >+				mutex_unlock(&mapping->i_mmap_mutex);
> >+				goto retry;
> >+			}
> >+			smmap_sem =&svma->vm_mm->mmap_sem;
> >+		}
> >+
> >+		spage_table_lock =&svma->vm_mm->page_table_lock;
> >+		spin_lock_nested(spage_table_lock, SINGLE_DEPTH_NESTING);
> >
> >  		saddr = page_table_shareable(svma, vma, addr, idx);
> >  		if (saddr) {
> 
> Hi Mel, FYI I tried this and ran into a problem.  When there are
> multiple processes
> in huge_pmd_share() just faulting in the same i_map they all have
> their mmap_sem
> down for write so the down_read_trylock(&svma->vm_mm->mmap_sem) never
> succeeds.  What am I missing?
> 

Probably nothing, this version of the patch is flawed. In the final
(unreleased) version of this approach it had to check if it tried this
trylock for too long and bail out if that happened and fail to share
the page tables. I've dropped this approach to the problem as better
alternatives exist.

Thanks Larry!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
