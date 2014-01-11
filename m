Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 50F746B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 10:53:45 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id b57so2392874eek.17
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 07:53:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n47si17168179eef.31.2014.01.11.07.53.44
        for <linux-mm@kvack.org>;
        Sat, 11 Jan 2014 07:53:44 -0800 (PST)
Date: Sat, 11 Jan 2014 16:53:37 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Message-ID: <20140111155337.GA16003@redhat.com>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On 01/10, Alex Thorlton wrote:
>
> This patch adds an mm flag (MMF_THP_DISABLE) to disable transparent
> hugepages using prctl.  It is based on my original patch to add a
> per-task_struct flag to disable THP:

I leave the "whether we need this feature" to other reviewers, although
personally I think it probably makes sense anyway.

But the patch doesn't look nice imho.

> @@ -373,7 +373,15 @@ extern int get_dumpable(struct mm_struct *mm);
>  #define MMF_HAS_UPROBES		19	/* has uprobes */
>  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define MMF_THP_DISABLE		21	/* disable THP for this mm */
> +#define MMF_THP_DISABLE_MASK	(1 << MMF_THP_DISABLE)
> +
> +#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK | MMF_THP_DISABLE_MASK)
> +#else
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
> +#endif

It would be nice to lessen the number of ifdef's. Why we can't define
MMF_THP_DISABLE unconditionally and include it into MMF_INIT_MASK?
Or define it == 0 if !CONFIG_THP. But this is minor.

> +#define PR_SET_THP_DISABLE	41
> +#define PR_CLEAR_THP_DISABLE	42
> +#define PR_GET_THP_DISABLE	43

Why we can't add 2 PR_'s, set and get?

> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -818,6 +818,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>  	mm->pmd_huge_pte = NULL;
>  #endif
> +
>  	if (!mm_init(mm, tsk))
>  		goto fail_nomem;

Why? looks like the accidental change.

> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1835,6 +1835,42 @@ static int prctl_get_tid_address(struct task_struct *me, int __user **tid_addr)
>  }
>  #endif
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static int prctl_set_thp_disable(struct task_struct *me)
> +{
> +	set_bit(MMF_THP_DISABLE, &me->mm->flags);
> +	return 0;
> +}
> +
> +static int prctl_clear_thp_disable(struct task_struct *me)
> +{
> +	clear_bit(MMF_THP_DISABLE, &me->mm->flags);
> +	return 0;
> +}
> +
> +static int prctl_get_thp_disable(struct task_struct *me,
> +				  int __user *thp_disabled)
> +{
> +	return put_user(test_bit(MMF_THP_DISABLE, &me->mm->flags), thp_disabled);
> +}
> +#else
> +static int prctl_set_thp_disable(struct task_struct *me)
> +{
> +	return -EINVAL;
> +}
> +
> +static int prctl_clear_thp_disable(struct task_struct *me)
> +{
> +	return -EINVAL;
> +}
> +
> +static int prctl_get_thp_disable(struct task_struct *me,
> +				  int __user *thp_disabled)
> +{
> +	return -EINVAL;
> +}
> +#endif
> +
>  SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>  		unsigned long, arg4, unsigned long, arg5)
>  {
> @@ -1998,6 +2034,15 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>  		if (arg2 || arg3 || arg4 || arg5)
>  			return -EINVAL;
>  		return current->no_new_privs ? 1 : 0;
> +	case PR_SET_THP_DISABLE:
> +		error = prctl_set_thp_disable(me);
> +		break;
> +	case PR_CLEAR_THP_DISABLE:
> +		error = prctl_clear_thp_disable(me);
> +		break;
> +	case PR_GET_THP_DISABLE:
> +		error = prctl_get_thp_disable(me, (int __user *) arg2);
> +		break;
>  	default:
>  		error = -EINVAL;
>  		break;

I simply can't understand, this all looks like overkill. Can't you simply add

	#idfef CONFIG_TRANSPARENT_HUGEPAGE
	case GET:
		error = test_bit(MMF_THP_DISABLE);
		break;
	case PUT:
		if (arg2)
			set_bit();
		else
			clear_bit();
		break;
	#endif

into sys_prctl() ?	

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
