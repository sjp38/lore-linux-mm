Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E1F886B0096
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:38:34 -0500 (EST)
From: Milton Miller <miltonm@bga.com>
Message-Id: <compat-not-unlikely@mdm.bga.com>
In-Reply-To: <20101130200129.GG11905@redhat.com>
References: <20101130200129.GG11905@redhat.com>
Date: Wed, 01 Dec 2010 11:37:58 -0600
Subject: (No subject header)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 about 20:01:29 -0000, Oleg Nesterov wrote:
> Teach get_arg_ptr() to handle compat = T case correctly.

>  #include <asm/uaccess.h>
>  #include <asm/mmu_context.h>
> @@ -395,6 +396,18 @@ get_arg_ptr(const char __user * const __
>  {
>  	const char __user *ptr;
>  
> +#ifdef CONFIG_COMPAT
> +	if (unlikely(compat)) {

This should not be marked unlikely.  Unlikely tells gcc the path
with over 99% confidence and disables branch predictors on some
architectures.  If called from a compat processes this will result
in a mispredicted branch every iteration.  Just use if (compat)
and let the hardware branch predictors do their job.

> +		compat_uptr_t __user *a = (void __user*)argv;
> +		compat_uptr_t p;
> +
> +		if (get_user(p, a + argc))
> +			return ERR_PTR(-EFAULT);
> +
> +		return compat_ptr(p);
> +	}
> +#endif
> +
>  	if (get_user(ptr, argv + argc))
>  		return ERR_PTR(-EFAULT);
>  
> @@ -1501,6 +1514,18 @@ int do_execve(const char *filename,
>  	return do_execve_common(filename, argv, envp, regs, false);
>  }
>  
> +#ifdef CONFIG_COMPAT
> +int compat_do_execve(char * filename,
> +	compat_uptr_t __user *argv,
> +	compat_uptr_t __user *envp,
> +	struct pt_regs * regs)
> +{
> +	return do_execve_common(filename,
> +				(void __user*)argv, (void __user*)envp,

Shouldn't these be compat_ptr(argv)?  (makes a difference on s390)

> +				regs, true);
> +}
> +#endif
> +
>  void set_binfmt(struct linux_binfmt *new)
>  {
>  	struct mm_struct *mm = current->mm;

Thanks,
milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
