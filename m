Date: Sun, 6 Nov 2005 12:49:44 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Clean up of __alloc_pages
Message-Id: <20051106124944.0b2ccca1.pj@sgi.com>
In-Reply-To: <200511061835.53575.ak@suse.de>
References: <20051028183326.A28611@unix-os.sc.intel.com>
	<p73oe4z2f9h.fsf@verdi.suse.de>
	<20051105201841.2591bacc.pj@sgi.com>
	<200511061835.53575.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi wrote:
> > The current code in the kernel does the following:
> >   1) The cpuset_update_current_mems_allowed() calls in the
> >      various alloc_page*() paths in mm/mempolicy.c:
> > 	* take the task_lock spinlock on the current task
> 
> That needs to go imho.

The comment for refresh_mems(), where this is happening, explains
why this lock is needed:

 * The task_lock() is required to dereference current->cpuset safely.
 * Without it, we could pick up the pointer value of current->cpuset
 * in one instruction, and then attach_task could give us a different
 * cpuset, and then the cpuset we had could be removed and freed,
 * and then on our next instruction, we could dereference a no longer
 * valid cpuset pointer to get its mems_generation field.

Hmmm ... on second thought ... damn ... you're right.

I can just flat out remove that task_lock - without penalty.

It's *OK* if I dereference a no longer valid cpuset pointer to get
its (used to be) mems_generation field.  Either that field will have
already changed, or it won't.

    If it has changed to some other value (doesn't matter what value)
    I will realize (quite correctly) that my cpuset has changed out
    from under me, and go into the slow path code to lock things down
    and update things as need be.

    If it has not changed yet (far the more likely case) then I will
    have just missed by the skin of my teeth catching this cpuset
    change this time around.  Which is just fine.  I will catch it next
    time this task allocates memory, for sure, as I will be using the
    new cpuset pointer value the next time, for sure.

Patch coming soon to remove that task_lock/task_unlock.

Thanks.


> At least for the common "cpusets compiled in, but not 
> used" case.

Hmmm ... that comment got me to thinking too.  I could have a global
kernel flag "cpusets_have_been_used", initialized to zero (0), set to
one (1) anytime someone creates or modifies a cpuset.  Then most of my
hooks, in places like fork and exit, could collapse to really trivial
inline lockless code if cpusets have not been used yet since the system
booted.

Would you be interested in seeing such a patch?

This should even apply to the more interesting case of
cpuset_zone_allowed(), which is called for each iteration of each
zone loop in __alloc_pages().  That would be a nice win for those
systems making no active use of cpusets.

===

What about the other part of your initial question - replacing the
cpuset_zone_allowed() hooks in __alloc_pages() with code to build
custom zonelists?

I did my best in my previous reply to spell out the pluses and minuses
of that change and what work would be involved.

What's your recommendation on whether to do that or not?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
