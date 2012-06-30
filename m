Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 247FF6B0074
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 01:10:06 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2387671qcs.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 22:10:05 -0700 (PDT)
Date: Sat, 30 Jun 2012 01:10:01 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 19/40] autonuma: alloc/free/init sched_autonuma
Message-ID: <20120630051000.GF3975@localhost.localdomain>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-20-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340888180-15355-20-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Jun 28, 2012 at 02:55:59PM +0200, Andrea Arcangeli wrote:
> This is where the dynamically allocated sched_autonuma structure is
> being handled.
> 
> The reason for keeping this outside of the task_struct besides not
> using too much kernel stack, is to only allocate it on NUMA
> hardware. So the not NUMA hardware only pays the memory of a pointer
> in the kernel stack (which remains NULL at all times in that case). 

.. snip..
> +	if (unlikely(alloc_task_autonuma(tsk, orig, node)))
> +		/* free_thread_info() undoes arch_dup_task_struct() too */
> +		goto out_thread_info;
>  

That looks (without seeing the implementation) and from reading the git
commit, like that on non-NUMA machines it would fail - and end up
stop the creation of a task.

Perhaps a better name for the function: alloc_always_task_autonuma
since the function (at least from the description of this patch) will
always succeed. Perhaps even remove the:
"if unlikely(..)" bit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
