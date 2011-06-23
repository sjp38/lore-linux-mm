Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B6CBC900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 03:37:03 -0400 (EDT)
Date: Thu, 23 Jun 2011 16:23:21 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: unlock page before charging it. (WasRe: [PATCH
 V2] mm: Do not keep page locked during page fault while charging it for
 memcg
Message-Id: <20110623162321.f7b12b29.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
	<20110622121516.GA28359@infradead.org>
	<20110622123204.GC14343@tiehlicka.suse.cz>
	<20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Thu, 23 Jun 2011 15:08:42 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 22 Jun 2011 14:32:04 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Wed 22-06-11 08:15:16, Christoph Hellwig wrote:
> > > > +
> > > > +			/* We have to drop the page lock here because memcg
> > > > +			 * charging might block for unbound time if memcg oom
> > > > +			 * killer is disabled.
> > > > +			 */
> > > > +			unlock_page(vmf.page);
> > > > +			ret = mem_cgroup_newpage_charge(page, mm, GFP_KERNEL);
> > > > +			lock_page(vmf.page);
> > > 
> > > This introduces a completely poinless unlock/lock cycle for non-memcg
> > > pagefaults.  Please make sure it only happens when actually needed.
> > 
> > Fair point. Thanks!
> > What about the following?
> > I realize that pushing more memcg logic into mm/memory.c is not nice but
> > I found it better than pushing the old page into mem_cgroup_newpage_charge.
> > We could also check whether the old page is in the root cgroup because
> > memcg oom killer is not active there but that would add more code into
> > this hot path so I guess it is not worth it.
> > 
> > Changes since v1
> > - do not unlock page when memory controller is disabled.
> > 
> 
> Great work. Then I confirmed Lutz' problem is fixed.
> 
> But I like following style rather than additional lock/unlock.
> How do you think ? I tested this on the latest git tree and confirmed
> the Lutz's livelock problem is fixed. And I think this should go stable tree.
> 
I vote for this one.

One comments are inlined below.

> 
> ==
> From 7e9250da9ff529958d4c1ff511458dbdac8e4b81 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 23 Jun 2011 15:05:57 +0900
> Subject: [PATCH] memcg: unlock page before charging it.
> 
> Currently we are keeping faulted page locked throughout whole __do_fault
> call (except for page_mkwrite code path). If we do early COW we allocate a
> new page which has to be charged for a memcg (mem_cgroup_newpage_charge).
> 
> This function, however, might block for unbounded amount of time if memcg
> oom killer is disabled or fork-bomb is running because the only way out of
> the OOM situation is either an external event or OOM-situation fix.
> 
> processes from faulting it in which is not good at all because we are
> basically punishing potentially an unrelated process for OOM condition
> in a different group (I have seen stuck system because of ld-2.11.1.so being
> locked).
> 
> We can do test easily.
>  % cgcreate -g memory:A
>  % cgset -r memory.limit_in_bytes=64M A
>  % cgset -r memory.memsw.limit_in_bytes=64M A
>  % cd kernel_dir; cgexec -g memory:A make -j
> 
> Then, the whole system will live-locked until you kill 'make -j'
> by hands (or push reboot...) This is because some important
> page in a shared library are locked and never released bcause of fork-bomb.
> 
> This patch delays "charge" until unlock_page() called. There is
> no problem as far as we keep reference on a page.
> (memcg doesn't require page_lock()).
> 
> Then, above livelock disappears.
> 
> Reported-by: Lutz Vieweg <lvml@5t9.de>
> Original-idea-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memory.c |   28 +++++++++++++++++++---------
>  1 files changed, 19 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 87d9353..66442da 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3129,7 +3129,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *page;
>  	pte_t entry;
>  	int anon = 0;
> -	int charged = 0;
> +	struct page *need_charge = NULL;
>  	struct page *dirty_page = NULL;
>  	struct vm_fault vmf;
>  	int ret;
> @@ -3177,12 +3177,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  				ret = VM_FAULT_OOM;
>  				goto out;
>  			}
> -			if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
> -				ret = VM_FAULT_OOM;
> -				page_cache_release(page);
> -				goto out;
> -			}
> -			charged = 1;
> +			need_charge = page;
>  			copy_user_highpage(page, vmf.page, address, vma);
>  			__SetPageUptodate(page);
>  		} else {
> @@ -3251,12 +3246,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		/* no need to invalidate: a not-present page won't be cached */
>  		update_mmu_cache(vma, address, page_table);
>  	} else {
> -		if (charged)
> -			mem_cgroup_uncharge_page(page);
>  		if (anon)
>  			page_cache_release(page);
>  		else
>  			anon = 1; /* no anon but release faulted_page */
> +		need_charge = NULL;
>  	}
>  
>  	pte_unmap_unlock(page_table, ptl);
> @@ -3268,6 +3262,17 @@ out:
>  		if (set_page_dirty(dirty_page))
>  			page_mkwrite = 1;
>  		unlock_page(dirty_page);
> +		if (need_charge) {
> +			/*
> +			 * charge this page before we drop refcnt.
> +			 * memory cgroup returns OOM condition when
> +			 * this task is killed. So, it's not necesasry
> +			 * to undo.
> +			 */
> +			if (mem_cgroup_newpage_charge(need_charge,
> +					mm, GFP_KERNEL))
> +				ret = VM_FAULT_OOM;
> +		}
>  		put_page(dirty_page);
>  		if (page_mkwrite && mapping) {
>  			/*
Hmm, if I read the code correctly, we don't come to this path.
Because "dirty_page" is set only in "anon == 0" case and, when we set "need_charge",
we set "anon" too.
So, we can do mem_cgroup_newpage_charge(need_charge) outside of
"if (dirty_page) ... else ..." block ?


Thanks,
Daisuke Nishimura.

> @@ -3282,6 +3287,11 @@ out:
>  			file_update_time(vma->vm_file);
>  	} else {
>  		unlock_page(vmf.page);
> +		if (need_charge) {
> +			if (mem_cgroup_newpage_charge(need_charge,
> +						mm, GFP_KERNEL))
> +				ret = VM_FAULT_OOM;
> +		}
>  		if (anon)
>  			page_cache_release(vmf.page);
>  	}
> -- 
> 1.7.4.1
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
