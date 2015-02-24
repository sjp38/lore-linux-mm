Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 352F46B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 06:35:32 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id v63so18756686oia.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:35:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t19si3687125oey.97.2015.02.24.03.35.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 03:35:31 -0800 (PST)
Subject: Re: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1424324307.18191.5.camel@stgolabs.net>
	<201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
	<1424370153.18191.12.camel@stgolabs.net>
	<201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
	<1424449696.2317.0.camel@stgolabs.net>
In-Reply-To: <1424449696.2317.0.camel@stgolabs.net>
Message-Id: <201502242035.GCI75431.LHQFOOJMFVSFtO@I-love.SAKURA.ne.jp>
Date: Tue, 24 Feb 2015 20:35:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@stgolabs.net
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org

Davidlohr Bueso wrote:
> On Fri, 2015-02-20 at 07:11 +0900, Tetsuo Handa wrote:
> > Davidlohr Bueso wrote:
> > > On Thu, 2015-02-19 at 20:07 +0900, Tetsuo Handa wrote:
> > > > Why do we need to let the caller call path_put() ?
> > > > There is no need to do like proc_exe_link() does, for
> > > > tomoyo_get_exe() returns pathname as "char *".
> > > 
> > > Having the pathname doesn't guarantee anything later, and thus doesn't
> > > seem very robust in the manager call if it can be dropped during the
> > > call... or can this never occur in this context?
> > > 
> > tomoyo_get_exe() returns the pathname of executable of current thread.
> > The executable of current thread cannot be changed while current thread
> > is inside the manager call. Although the pathname of executable of
> > current thread could be changed by other threads via namespace manipulation
> > like pivot_root(), holding a reference guarantees nothing. Your patch helps
> > for avoiding memory allocation with mmap_sem held, but does not robustify
> > handling of mm->exe_file for tomoyo.
> 
> Fair enough, I won't argue. This is beyond the scope if what I'm trying
> to accomplish here anyway. Are you ok with this instead?
> 
I prefer cleanups excluded from this patch, like shown below.
Would you please resend?

> diff --git a/security/tomoyo/common.c b/security/tomoyo/common.c
> index e0fb750..73ce629 100644
> --- a/security/tomoyo/common.c
> +++ b/security/tomoyo/common.c
> @@ -908,6 +908,31 @@ static void tomoyo_read_manager(struct tomoyo_io_buffer *head)
>  }
>  
>  /**
> + * tomoyo_get_exe - Get tomoyo_realpath() of current process.
> + *
> + * Returns the tomoyo_realpath() of current process on success, NULL otherwise.
> + *
> + * This function uses kzalloc(), so the caller must call kfree()
> + * if this function didn't return NULL.
> + */
> +static const char *tomoyo_get_exe(void)
> +{
> +	struct file *exe_file;
> +	const char *cp = NULL;

No need to initialize cp here.

> +	struct mm_struct *mm = current->mm;
> +
> +	if (!mm)
> +		return NULL;
> +	exe_file = get_mm_exe_file(mm);
> +	if (!exe_file)
> +		return NULL;
> +
> +	cp = tomoyo_realpath_from_path(&exe_file->f_path);
> +	fput(exe_file);
> +	return cp;
> +}
> +
> +/**
>   * tomoyo_manager - Check whether the current process is a policy manager.
>   *
>   * Returns true if the current process is permitted to modify policy
> diff --git a/security/tomoyo/common.h b/security/tomoyo/common.h
> index b897d48..fc89eba 100644
> --- a/security/tomoyo/common.h
> +++ b/security/tomoyo/common.h
> @@ -947,7 +947,6 @@ char *tomoyo_init_log(struct tomoyo_request_info *r, int len, const char *fmt,
>  char *tomoyo_read_token(struct tomoyo_acl_param *param);
>  char *tomoyo_realpath_from_path(struct path *path);
>  char *tomoyo_realpath_nofollow(const char *pathname);
> -const char *tomoyo_get_exe(void);
>  const char *tomoyo_yesno(const unsigned int value);
>  const struct tomoyo_path_info *tomoyo_compare_name_union
>  (const struct tomoyo_path_info *name, const struct tomoyo_name_union *ptr);
> diff --git a/security/tomoyo/util.c b/security/tomoyo/util.c
> index 2952ba5..7eff479 100644
> --- a/security/tomoyo/util.c
> +++ b/security/tomoyo/util.c
> @@ -939,28 +939,6 @@ bool tomoyo_path_matches_pattern(const struct tomoyo_path_info *filename,
>  }
>  
>  /**
> - * tomoyo_get_exe - Get tomoyo_realpath() of current process.
> - *
> - * Returns the tomoyo_realpath() of current process on success, NULL otherwise.
> - *
> - * This function uses kzalloc(), so the caller must call kfree()
> - * if this function didn't return NULL.
> - */
> -const char *tomoyo_get_exe(void)
> -{
> -	struct mm_struct *mm = current->mm;
> -	const char *cp = NULL;
> -
> -	if (!mm)
> -		return NULL;
> -	down_read(&mm->mmap_sem);
> -	if (mm->exe_file)
> -		cp = tomoyo_realpath_from_path(&mm->exe_file->f_path);
> -	up_read(&mm->mmap_sem);
> -	return cp;
> -}
> -
> -/**
>   * tomoyo_get_mode - Get MAC mode.
>   *
>   * @ns:      Pointer to "struct tomoyo_policy_namespace".
> -- 
> 2.1.4

You can post TOMOYO patches to tomoyo-dev-en@lists.sourceforge.jp .
I'll add your mail address to ML's accept list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
