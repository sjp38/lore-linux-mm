Date: Sun, 6 Nov 2005 20:37:17 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Clean up of __alloc_pages
Message-Id: <20051106203717.58c3eed0.pj@sgi.com>
In-Reply-To: <200511070442.58876.ak@suse.de>
References: <20051028183326.A28611@unix-os.sc.intel.com>
	<20051106124944.0b2ccca1.pj@sgi.com>
	<436EC2AF.4020202@yahoo.com.au>
	<200511070442.58876.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: nickpiggin@yahoo.com.au, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick wrote:
> Anyway, I think the first problem is a showstopper. I'd look into
> Hugh's SLAB_DESTROY_BY_RCU for this ...

Andi wrote:
> RCU could be used to avoid that. Just only free it in a RCU callback.


... looking at mm/slab.h and rcupdate.h for the first time ... 

Would this mean that I had to put the cpuset structures on their own
slab cache, marked SLAB_DESTROY_BY_RCU?

And is the pair of operators:
  task_lock(current), task_unlock(current)
really that much worse than the pair of operatots
  rcu_read_lock, rcu_read_unlock
which apparently reduce to:
  preempt_disable, preempt_enable

Would this work something like the following?  Say task A, on processor
AP, is trying to dereference its cpuset pointer, while task B, on
processor BP, is trying hard to destroy that cpuset. Then if task A
wraps its reference in <rcu_read_lock, rcu_read_unlock>, this will keep
the RCU freeing of that memory from completing, until interrupts on AP
are re-enabled.

For that matter, if I just put cpuset structs in their own slab
cache, would that be sufficient.

  Nick - Does use-after-free debugging even catch use of objects
	 returned to their slab cache?

What about the other suggestions, Andi:
 1) subset zonelists (which you asked to reconsider)
 2) a kernel flag "cpusets_have_been_used" flag to short circuit
    cpuset logic on systems not using cpusets.



-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
