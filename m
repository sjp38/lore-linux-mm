Date: Fri, 10 Sep 1999 16:01:02 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: accel again.
In-Reply-To: <m1emg8dj7p.fsf@alogconduit1ae.ccr.net>
Message-ID: <Pine.LNX.4.10.9909101530170.9815-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 9 Sep 1999, Eric W. Biederman wrote:

> James Simmons <jsimmons@edgeglobal.com> writes:
> 
> > Well I did my homework on spinlocks and see what you mean by using
> > spinlocks to handle accel and framebuffer access. So just before I have
> > fbcon access the accel engine I could do this right?
> 
> This prevents the page table from changing, not the mapped pages.
> (Though you can unmap them as well).
Oh. So you can't allocate or delete pages.

Is it possible then to spin_lock the mapped pages? What I need to prevent
any process from access the framebuffer while the accel engine is going.
Also say on SMP machine each CPU has a process that mmaps the accel
region. Most cards can't handle accel commands coming from both CPUs. I
need to make sure only one process at a time has access to the accel MMIO
region. 

I realize the best way to handle this is to make all accel access happens
atomically. Make sure that code is the only code being processed.  
 
> I still think
> for_each_task(p) {
> 	if (p->mm == &fb_info->vm_area->vm_mm) {
> 		put_process_to_sleep(p); /* pseudo code */
> 	}
> }
> is less costly.
> And the single process case can usually optimized to:
> if ((&fb_info->vm_area->vm_mm == current->mm) && (current->mm->count == 1)) {
> 	/* do nothing */
> } else {
> 	/* put everyone else to sleep */
> }

What if a process mmaps say a file besides the framebuffer? Then whats the
current->mm field look like? I was thinking about doing it that way. The
only thing I don't like about that approach is that a process that mmap
the framebuffer might not be accessing the framebuffer at that time. It
could be doing something that is critical to preformace. Say a computer
game figuring out collisons instead of accessing thr framebuffer. In this
case that would kill the performace of the game.

> in the send_accel_command() interface, so you would only need
> to really put processes to sleep when you have multiple processes mapping
> the frame buffer.  You could also use this optimization with the unmapping
> case so I'm not certain which is superior.   Blocking on a page fault when
> you access memory is certainly better explored.

But this options is to costly especially on a SMP machine.

> The worst case only comes into play when (a) you have mm->count >1
> or (b) the kernel is doing something asynchronously.
> (a) Looks easy enough to avoid (it's not exactly polite but not using
> threads is simple)
> (b) should be rare.
> 
> But this is only relevant for buggy hardware, that will lock the whole 
> machine.
> 
> For non buggy hardware you certainly want a cooperative lock/
> something you can block on while the accel commands are running.
> 
> But that is probably just a case of documenting your send_accel_command()
> interface as blocking when the accel commands are running.
> 
> Eric
> 
> p.s. your code looks correct from what I can see except 
> you are using the wrong lock.  And expecting each store instruction
> to take that lock (which doesn't happen).

A lock on the mmap pages would better then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
