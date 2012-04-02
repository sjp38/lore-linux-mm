Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 0A8E46B007E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 14:05:55 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3312639bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 11:05:54 -0700 (PDT)
Date: Mon, 2 Apr 2012 22:05:51 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120402180551.GJ7607@moon>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
 <20120331203912.GB687@moon>
 <4F79755B.3030703@openvz.org>
 <20120402144821.GA3334@redhat.com>
 <4F79D1AF.7080100@openvz.org>
 <20120402162733.GI7607@moon>
 <4F79DE84.8020807@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F79DE84.8020807@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>

On Mon, Apr 02, 2012 at 09:14:44PM +0400, Konstantin Khlebnikov wrote:
...
> >
> >Ah, it's about locking. I misundertand it at first.
> >Oleg, forget about my email then.
> 
> Yes, it's about locking. Please review patch for your code from attachment.

Thanks a lot, Konstantin! This should do the trick.

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index cff94cd..4a41270 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -437,6 +437,7 @@ extern int get_dumpable(struct mm_struct *mm);
>  					/* leave room for more dump flags */
>  #define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
>  #define MMF_VM_HUGEPAGE		17	/* set when VM_HUGEPAGE is set on vma */
> +#define MMF_EXE_FILE_CHANGED	18	/* see prctl(PR_SET_MM_EXE_FILE) */
>  
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
>  
> diff --git a/kernel/sys.c b/kernel/sys.c
> index da660f3..b217069 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1714,17 +1714,11 @@ static bool vma_flags_mismatch(struct vm_area_struct *vma,
>  
>  static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
>  {
> +	struct vm_area_struct *vma;
>  	struct file *exe_file;
>  	struct dentry *dentry;
>  	int err;
>  
> -	/*
> -	 * Setting new mm::exe_file is only allowed when no VM_EXECUTABLE vma's
> -	 * remain. So perform a quick test first.
> -	 */
> -	if (mm->num_exe_file_vmas)
> -		return -EBUSY;
> -
>  	exe_file = fget(fd);
>  	if (!exe_file)
>  		return -EBADF;
> @@ -1745,17 +1739,28 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
>  	if (err)
>  		goto exit;
>  
> +	down_write(&mm->mmap_sem);
> +	/*
> +	 * Forbid mm->exe_file change if there are mapped some other files.
> +	 */
> +	err = -EEXIST;
> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		if (vma->vm_file &&
> +		    !path_equal(&vma->vm_file->f_path, &exe_file->f_path))
> +			goto out_unlock;
> +	}

If I understand right, this snippet is emulating old behaviour (ie as
it was with num_exe_file_vmas), thus -EBUSY might be more appropriate?
But it's really a small nit I think. Thanks again.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
