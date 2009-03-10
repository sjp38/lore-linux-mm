Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 711986B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 21:53:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2A1ra2u024988
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Mar 2009 10:53:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 735EC45DE4F
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 10:53:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5165B45DE4E
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 10:53:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C0F41DB8013
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 10:53:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F1C7A1DB8012
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 10:53:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memdup_user: introduce, fix
In-Reply-To: <49B5C69F.3010409@cn.fujitsu.com>
References: <49B5C69F.3010409@cn.fujitsu.com>
Message-Id: <20090310105258.A483.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Mar 2009 10:53:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Americo Wang <xiyou.wangcong@gmail.com>, Alexey Dobriyan <adobriyan@gmail.com>, Arjan van de Ven <arjan@infradead.org>, Roland Dreier <rdreier@cisco.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>   * Include machine specific inline routines
> diff --git a/mm/util.c b/mm/util.c
> index 3d21c21..7c122e4 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -74,15 +74,19 @@ EXPORT_SYMBOL(kmemdup);
>   *
>   * @src: source address in user space
>   * @len: number of bytes to copy
> - * @gfp: GFP mask to use
>   *
>   * Returns an ERR_PTR() on failure.
>   */
> -void *memdup_user(const void __user *src, size_t len, gfp_t gfp)
> +void *memdup_user(const void __user *src, size_t len)
>  {
>  	void *p;
>  
> -	p = kmalloc_track_caller(len, gfp);
> +	/*
> +	 * Always use GFP_KERNEL, since copy_from_user() can sleep and
> +	 * cause pagefault, which makes it pointless to use GFP_NOFS
> +	 * or GFP_ATOMIC.
> +	 */
> +	p = kmalloc_track_caller(len, GFP_KERNEL);
>  	if (!p)
>  		return ERR_PTR(-ENOMEM);

ok. thanks.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
