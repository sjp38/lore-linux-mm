Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 70F4C9000F0
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 06:25:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 060843EE0B6
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:25:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC1AA45DEB5
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:25:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D61045DEB4
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:25:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E2D51DB8037
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:25:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A90E1DB803C
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:25:43 +0900 (JST)
Date: Mon, 3 Oct 2011 19:24:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: One comment on the __release_region in kernel/resource.c
Message-Id: <20111003192458.14d198a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CADLM8XNiaxLFRZXs4NKJmoORvED-DV0bNxPF6eHsfnLqtxw09w@mail.gmail.com>
References: <CADLM8XNiaxLFRZXs4NKJmoORvED-DV0bNxPF6eHsfnLqtxw09w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 2 Oct 2011 21:57:07 +0800
Wei Yang <weiyang.kernel@gmail.com> wrote:

> Dear experts,
> 
> I am viewing the source code of __release_region() in kernel/resource.c.
> And I have one comment for the performance issue.
> 
> For example, we have a resource tree like this.
> 10-89
>    20-79
>        30-49
>        55-59
>        60-64
>        65-69
>    80-89
> 100-279
> 
> If the caller wants to release a region of [50,59], the original code will
> execute four times in the for loop in the subtree of 20-79.
> 
> After changing the code below, it will execute two times instead.
> 
> By using the "git annotate", I see this code is committed by Linus as the
> initial version. So don't get more information about why this code is
> written
> in this way.
> 
> Maybe the case I thought will not happen in the real world?
> 
> Your comment is warmly welcome. :)
> 
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 8461aea..81525b4 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -931,7 +931,7 @@ void __release_region(struct resource *parent,
> resource_size_t start,
>        for (;;) {
>                struct resource *res = *p;
> 
> -               if (!res)
> +               if (!res || res->start > start)

Hmm ?
	res->start > end ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
