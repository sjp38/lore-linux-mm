Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2C1826B01B0
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:51 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjnOo024545
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B250C45DE52
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8492245DD71
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 570951DB801A
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C5DDE1DB8015
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mempolicy: reduce stack size of migrate_pages()
In-Reply-To: <20100618143851.0661daa2.akpm@linux-foundation.org>
References: <20100616130040.3831.A69D9226@jp.fujitsu.com> <20100618143851.0661daa2.akpm@linux-foundation.org>
Message-Id: <20100621090550.B4F8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> >  	const struct cred *cred = current_cred(), *tcred;
> > -	struct mm_struct *mm;
> > +	struct mm_struct *mm = NULL;
> >  	struct task_struct *task;
> > -	nodemask_t old;
> > -	nodemask_t new;
> >  	nodemask_t task_nodes;
> >  	int err;
> > +	NODEMASK_SCRATCH(scratch);
> > +	nodemask_t *old = &scratch->mask1;
> > +	nodemask_t *new = &scratch->mask2;
> >
> > +	if (!scratch)
> > +		return -ENOMEM;
> 
> It doesn't matter in practice, but it makes me all queazy to see code
> which plays with pointers which might be NULL.

I see. thanks.
Do we need to send you updated patch?


> 
> --- a/mm/mempolicy.c~mempolicy-reduce-stack-size-of-migrate_pages-fix
> +++ a/mm/mempolicy.c
> @@ -1279,13 +1279,16 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
>  	struct task_struct *task;
>  	nodemask_t task_nodes;
>  	int err;
> +	nodemask_t *old;
> +	nodemask_t *new;
>  	NODEMASK_SCRATCH(scratch);
> -	nodemask_t *old = &scratch->mask1;
> -	nodemask_t *new = &scratch->mask2;
>  
>  	if (!scratch)
>  		return -ENOMEM;
>  
> +	old = &scratch->mask1;
> +	new = &scratch->mask2;
> +
>  	err = get_nodes(old, old_nodes, maxnode);
>  	if (err)
>  		goto out;
> _
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
