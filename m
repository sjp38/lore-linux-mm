Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CBC406B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 03:13:50 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so1397900pdj.26
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 00:13:50 -0800 (PST)
Received: from mail-pb0-x22b.google.com (mail-pb0-x22b.google.com [2607:f8b0:400e:c01::22b])
        by mx.google.com with ESMTPS id s7si1627101pae.156.2014.01.29.00.13.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 00:13:49 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id md12so1456262pbc.30
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 00:13:49 -0800 (PST)
Date: Wed, 29 Jan 2014 00:13:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] kthread: ensure locality of task_struct allocations
In-Reply-To: <20140128183808.GB9315@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1401290012460.10268@chino.kir.corp.google.com>
References: <20140128183808.GB9315@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jan Kara <jack@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>

On Tue, 28 Jan 2014, Nishanth Aravamudan wrote:

> In the presence of memoryless nodes, numa_node_id()/cpu_to_node() will
> return the current CPU's NUMA node, but that may not be where we expect
> to allocate from memory from. Instead, we should use
> numa_mem_id()/cpu_to_mem(). On one ppc64 system with a memoryless Node
> 0, this ends up saving nearly 500M of slab due to less fragmentation.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

> diff --git a/kernel/kthread.c b/kernel/kthread.c
> index b5ae3ee..8573e4e 100644
> --- a/kernel/kthread.c
> +++ b/kernel/kthread.c
> @@ -217,7 +217,7 @@ int tsk_fork_get_node(struct task_struct *tsk)
>  	if (tsk == kthreadd_task)
>  		return tsk->pref_node_fork;
>  #endif
> -	return numa_node_id();
> +	return numa_mem_id();

I'm wondering why return NUMA_NO_NODE wouldn't have the same effect and 
prefer the local node?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
