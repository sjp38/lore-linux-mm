Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 53B676B003C
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:15:37 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so5644840qge.32
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:15:37 -0700 (PDT)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id w35si28978388qge.36.2014.07.21.10.15.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:15:36 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 13:15:36 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 348B6C90062
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:15:25 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LHFWvM4522364
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:15:32 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LHFUY2026018
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:15:31 -0400
Date: Mon, 21 Jul 2014 10:15:27 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 01/30] mm, kernel: Use cpu_to_mem()/numa_mem_id()
 to support memoryless node
Message-ID: <20140721171527.GA4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-2-git-send-email-jiang.liu@linux.intel.com>
 <20140711151405.GK16041@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140711151405.GK16041@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Dipankar Sarma <dipankar@in.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Jens Axboe <axboe@kernel.dk>, Frederic Weisbecker <fweisbec@gmail.com>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Christoph Hellwig <hch@infradead.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Xie XiuQi <xiexiuqi@huawei.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Paul,

On 11.07.2014 [08:14:05 -0700], Paul E. McKenney wrote:
> On Fri, Jul 11, 2014 at 03:37:18PM +0800, Jiang Liu wrote:
> > When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> > may return a node without memory, and later cause system failure/panic
> > when calling kmalloc_node() and friends with returned node id.
> > So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> > memory for the/current cpu.
> > 
> > If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> > is the same as cpu_to_node()/numa_node_id().
> > 
> > Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> 
> For the rcutorture piece:
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> Or if you separate the kernel/rcu/rcutorture.c portion into a separate
> patch, I will queue it separately.

Just FYI, based upon a separate discussion with Tejun and others, it
seems to be preferred to avoid the proliferation of cpu_to_mem
throughout the kernel blindly. For kthread_create_on_node(), I'm going
to try and fix the underlying issue and so you, as the caller, should
still specify the NUMA node you are running the kthread on
(cpu_to_node), not where you expect the memory to come from
(cpu_to_mem).

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
