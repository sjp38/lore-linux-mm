Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 42B216B0062
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:15:10 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C999A82C4AD
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:21:59 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IQBwnaCGXih0 for <linux-mm@kvack.org>;
	Fri,  6 Nov 2009 14:21:59 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8C6D282C4B6
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:21:53 -0500 (EST)
Date: Fri, 6 Nov 2009 14:13:45 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
In-Reply-To: <da621335371fccd6cfb3d8d7c0c2bf3a.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911061409310.15636@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>    <20091104234923.GA25306@redhat.com>    <alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>    <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>    <20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
    <20091106122344.51118116.kamezawa.hiroyu@jp.fujitsu.com>    <alpine.DEB.1.10.0911061231580.5187@V090114053VZO-1> <da621335371fccd6cfb3d8d7c0c2bf3a.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 7 Nov 2009, KAMEZAWA Hiroyuki wrote:

> And allocate mm->usage only when the first CLONE_THREAD is specified.

Ok.

> if (mm->usage)
>     access per cpu
> else
>     atomic_long_xxx

If we just have one thread: Do we need atomic access at all?

> and read operation will be
>
>     val = atomic_read(mm->rss);
>     if (mm->usage)
>         for_each_possible_cpu()....

or
   val = m->rss
   for_each_cpu(cpu) val+= percpu ...


> ==
> Does "if" seems too costly ?

The above method would avoid the if.

> If this idea is bad, I think moving mm_counter to task_struct from
> mm_struct and doing slow-sync is an idea instead of percpu.

Yeah then the access is effectively percpu as long as preempt is disabled.

But then for the mmap_writer_lock we would need to traverse a doubly
linked list to add up the counters. Bad caching on that one and we would
have to lock the list too. Sigh.

> kswapd and reclaim routine can update mm_struct's counter, directly.
> Readers just read mm_struct's counter.

Would work for rss counters but not for avoiding the rw semaphore I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
