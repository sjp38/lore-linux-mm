Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B4616B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 03:59:00 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R7wvsQ010916
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Oct 2009 16:58:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 973E545DE52
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:58:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4492645DE4D
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:58:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7DBBE08004
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:58:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BE68E08003
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:58:56 +0900 (JST)
Date: Tue, 27 Oct 2009 16:56:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
Message-Id: <20091027165628.acda4540.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <hav57c$rso$1@ger.gmane.org>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
	<20091027153429.b36866c4.minchan.kim@barrios-desktop>
	<20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
	<20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 16:45:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
  	/*
>  	 * After this unlock we can no longer dereference local variable `mm'
> @@ -92,8 +93,13 @@ unsigned long badness(struct task_struct
>  	 */
>  	list_for_each_entry(child, &p->children, sibling) {
>  		task_lock(child);
> -		if (child->mm != mm && child->mm)
> -			points += child->mm->total_vm/2 + 1;
> +		if (child->mm != mm && child->mm) {
> +			unsigned long cpoint;
> +			/* At considering child, we don't count swap */
> +			cpoint = get_mm_counter(child->mm, anon_rss) +
> +				 get_mm_counter(child->mm, file_rss);
> +			points += cpoint/2 + 1;
> +		}
>  		task_unlock(child);

BTW, I'd like to get rid of this code.

Can't we use other techniques for detecting fork-bomb ?

This check can't catch following type, anyway.

   fork()
     -> fork()
          -> fork()
               -> fork()
                    ....

but I have no good idea.
What is the difference with task-launcher and fork bomb()...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
