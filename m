Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB41vhOi015499
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 10:57:43 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5714A45DE50
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 10:57:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34EA945DD77
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 10:57:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 13BC31DB803A
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 10:57:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C1AB61DB803B
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 10:57:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] - support inheritance of mlocks across fork/exec V2
In-Reply-To: <1228331069.6693.73.camel@lts-notebook>
References: <20081125152651.b4c3c18f.akpm@linux-foundation.org> <1228331069.6693.73.camel@lts-notebook>
Message-Id: <20081204105527.1D5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 10:57:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

> @@ -600,9 +603,15 @@ asmlinkage long sys_mlockall(int flags)
>  	unsigned long lock_limit;
>  	int ret = -EINVAL;
>  
> -	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
> +	if (!(flags & (MCL_CURRENT | MCL_FUTURE)))
>  		goto out;
>  
> +	if (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_INHERIT | MCL_RECURSIVE))
> +		goto out;	/* undefined flag bits */
> +
> +	if ((flags & (MCL_INHERIT | MCL_RECURSIVE)) == MCL_RECURSIVE)
> +		goto out;	/* 'RECURSIVE undefined without 'INHERIT */
> +
>  	ret = -EPERM;
>  	if (!can_do_mlock())
>  		goto out;

looks good to me.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
