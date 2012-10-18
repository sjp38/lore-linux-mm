Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 009B36B0062
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 00:35:55 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so8954702pad.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 21:35:55 -0700 (PDT)
Date: Wed, 17 Oct 2012 21:35:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7 v2] mm, mempolicy: avoid taking mutex inside
 spinlock when reading numa_maps
In-Reply-To: <507F803A.8000900@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1210172130350.32271@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com> <20121017193229.GC16805@redhat.com>
 <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com> <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com> <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com>
 <507F803A.8000900@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 18 Oct 2012, Kamezawa Hiroyuki wrote:

> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 14df880..d92e868 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -94,6 +94,11 @@ static void vma_stop(struct proc_maps_private *priv, struct
> vm_area_struct *vma)
>  {
>  	if (vma && vma != priv->tail_vma) {
>  		struct mm_struct *mm = vma->vm_mm;
> +#ifdef CONFIG_NUMA
> +		task_lock(priv->task);
> +		__mpol_put(priv->task->mempolicy);
> +		task_unlock(priv->task);
> +#endif
>  		up_read(&mm->mmap_sem);
>  		mmput(mm);
>  	}
> @@ -130,6 +135,16 @@ static void *m_start(struct seq_file *m, loff_t *pos)
>  		return mm;
>  	down_read(&mm->mmap_sem);
>  +	/*
> +	 * task->mempolicy can be freed even if mmap_sem is down (see
> kernel/exit.c)
> +	 * We grab refcount for stable access.
> +	 * repleacement of task->mmpolicy is guarded by mmap_sem.
> +	 */
> +#ifdef CONFIG_NUMA
> +	task_lock(priv->task);
> +	mpol_get(priv->task->mempolicy);
> +	task_unlock(priv->task);
> +#endif
>  	tail_vma = get_gate_vma(priv->task->mm);
>  	priv->tail_vma = tail_vma;
>  @@ -161,6 +176,11 @@ out:
>   	/* End of vmas has been reached */
>  	m->version = (tail_vma != NULL)? 0: -1UL;
> +#ifdef CONFIG_NUMA
> +	task_lock(priv->task);
> +	__mpol_put(priv->task->mempolicy);
> +	task_unlock(priv->task);
> +#endif
>  	up_read(&mm->mmap_sem);
>  	mmput(mm);
>  	return tail_vma;

Yes, I must admit that this is better than my version and it looks like 
all the ->show() functions that use these start, next, stop functions 
don't take task_lock() and this would generally be useful: we already hold 
current->mm->mmap_sem so there is little harm in holding 
task_lock(current) when reading these files as long as we're not touching 
the fastpath.

These routines seem like it would nicely be added to mempolicy.h since we 
depend on CONFIG_NUMA there already.

Please fix up the mess I made in show_numa_map() in 32f8516a8c73 ("mm, 
mempolicy: fix printing stack contents in numa_maps") by simply removing 
the task_lock() and task_unlock() as part of your patch.

Thanks Kame!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
