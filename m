Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC7C18D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 22:13:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D0A343EE0BD
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:13:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D7645DE60
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:13:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DBFA45DE57
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:13:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D572E18001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:13:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 347BCE08002
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:13:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3 3/4] exec: unify do_execve/compat_do_execve code
In-Reply-To: <20110302162753.GD26810@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162753.GD26810@redhat.com>
Message-Id: <20110303120915.B951.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 12:13:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

> @@ -1510,11 +1528,27 @@ int do_execve(const char *filename,
>  	const char __user *const __user *__envp,
>  	struct pt_regs *regs)
>  {
> -	struct conditional_ptr argv = { .native = __argv };
> -	struct conditional_ptr envp = { .native = __envp };
> +	struct conditional_ptr argv = { .ptr.native = __argv };
> +	struct conditional_ptr envp = { .ptr.native = __envp };
>  	return do_execve_common(filename, argv, envp, regs);
>  }
>  
> +#ifdef CONFIG_COMPAT
> +int compat_do_execve(char *filename,
> +	compat_uptr_t __user *__argv,
> +	compat_uptr_t __user *__envp,
> +	struct pt_regs *regs)
> +{
> +	struct conditional_ptr argv = {
> +		.is_compat = true, .ptr.compat = __argv,
> +	};

Please don't mind to compress a line.

	struct conditional_ptr argv = {
		.is_compat = true,
		.ptr.compat = __argv,
	};

is more good readability.


Other parts looks very good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
