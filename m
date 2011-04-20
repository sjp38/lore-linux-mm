Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 645748D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:19:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B31A93EE0C5
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:19:54 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 959B945DEA1
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:19:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 11ED045DE99
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:19:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EA1BBE38007
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:19:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA880E08004
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:19:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <20110420105059.460C.A69D9226@jp.fujitsu.com>
References: <1303263673.5076.612.camel@nimitz> <20110420105059.460C.A69D9226@jp.fujitsu.com>
Message-Id: <20110420112006.461A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 11:19:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <johnstul@us.ibm.com>

> The concept is ok to me. but AFAIK some caller are now using ARRAY_SIZE(tsk->comm).
> or sizeof(tsk->comm). Probably callers need to be changed too.

one more correction.

>  void set_task_comm(struct task_struct *tsk, char *buf)
>  {
> +	char tmp_comm[TASK_COMM_LEN];
> +
>  	task_lock(tsk);
>  
> +	memcpy(tmp_comm, tsk->comm_buf, TASK_COMM_LEN);
> +	tsk->comm = tmp;
>  	/*
> -	 * Threads may access current->comm without holding
> -	 * the task lock, so write the string carefully.
> -	 * Readers without a lock may see incomplete new
> -	 * names but are safe from non-terminating string reads.
> +	 * Make sure no one is still looking at tsk->comm_buf
>  	 */
> -	memset(tsk->comm, 0, TASK_COMM_LEN);
> -	wmb();
> -	strlcpy(tsk->comm, buf, sizeof(tsk->comm));
> +	synchronize_rcu();

The doc says,

/**
 * synchronize_rcu - wait until a grace period has elapsed.
 *

And here is under spinlock.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
