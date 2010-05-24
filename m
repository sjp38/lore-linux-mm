Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E1D696B01B0
	for <linux-mm@kvack.org>; Sun, 23 May 2010 21:04:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4O14CkY010026
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 24 May 2010 10:04:12 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 169443266C5
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:04:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3BBC1EF087
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:04:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B41091DB8055
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:04:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FFDBE08008
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:04:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/27] mm: Use memdup_user
In-Reply-To: <Pine.LNX.4.64.1005221019370.13021@ask.diku.dk>
References: <Pine.LNX.4.64.1005221019370.13021@ask.diku.dk>
Message-Id: <20100524095902.1E92.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 24 May 2010 10:04:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Julia Lawall <julia@diku.dk>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
>  mm/util.c |   11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index f5712e8..4735ea4 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -225,15 +225,10 @@ char *strndup_user(const char __user *s, long n)
>  	if (length > n)
>  		return ERR_PTR(-EINVAL);
>  
> -	p = kmalloc(length, GFP_KERNEL);
> +	p = memdup_user(s, length);

memdup? Why can't we use strnlen_user() and legitimate length copy?


>  
> -	if (!p)
> -		return ERR_PTR(-ENOMEM);
> -
> -	if (copy_from_user(p, s, length)) {
> -		kfree(p);
> -		return ERR_PTR(-EFAULT);
> -	}
> +	if (IS_ERR(p))
> +		return p;
>  
>  	p[length - 1] = '\0';
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
