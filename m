Subject: Re: accel again.
References: <Pine.LNX.4.10.9909041708350.22380-100000@imperial.edgeglobal.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 09 Sep 1999 13:37:46 -0500
In-Reply-To: James Simmons's message of "Sat, 4 Sep 1999 17:27:42 -0400 (EDT)"
Message-ID: <m1emg8dj7p.fsf@alogconduit1ae.ccr.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Simmons <jsimmons@edgeglobal.com> writes:

> Well I did my homework on spinlocks and see what you mean by using
> spinlocks to handle accel and framebuffer access. So just before I have
> fbcon access the accel engine I could do this right?

This prevents the page table from changing, not the mapped pages.
(Though you can unmap them as well).

I still think
for_each_task(p) {
	if (p->mm == &fb_info->vm_area->vm_mm) {
		put_process_to_sleep(p); /* pseudo code */
	}
}
is less costly.
And the single process case can usually optimized to:
if ((&fb_info->vm_area->vm_mm == current->mm) && (current->mm->count == 1)) {
	/* do nothing */
} else {
	/* put everyone else to sleep */
}
in the send_accel_command() interface, so you would only need
to really put processes to sleep when you have multiple processes mapping
the frame buffer.  You could also use this optimization with the unmapping
case so I'm not certain which is superior.   Blocking on a page fault when
you access memory is certainly better explored.

The worst case only comes into play when (a) you have mm->count >1
or (b) the kernel is doing something asynchronously.
(a) Looks easy enough to avoid (it's not exactly polite but not using
threads is simple)
(b) should be rare.

But this is only relevant for buggy hardware, that will lock the whole machine.

For non buggy hardware you certainly want a cooperative lock/
something you can block on while the accel commands are running.

But that is probably just a case of documenting your send_accel_command()
interface as blocking when the accel commands are running.

Eric

p.s. your code looks correct from what I can see except 
you are using the wrong lock.  And expecting each store instruction
to take that lock (which doesn't happen).


> 
> In fb.h 
> --------
> struct fb_info {
> 	...
> 	struct vm_area_struct vm_area
> 	...
> }
> --------
> 
> In fbcon.c
> 
> /* I going to access accel engine */
> spin_lock(&fb_info->vm_area->vm_mm->page_table_lock); 
> 
> /* accessing accel engine */
> ....
> /* done with accel engine */
> spin_unlock(&fb_info->vm_area->vm_mm->page_table_lock);
> 
> Now this would lock the framebuffer correct? So if a process would try to
> acces the framebuffer it would be put to sleep while its doing accels. Is
> this basically what I need to do or is their something more that I am
> missing. 
> 
> Their also exist the possiblity that the accel engine in the kernel and
> the accel registers from userland could be access at the same time. This
> means that spin_lock could be called twice. Any danger in this? Then some
> accel engines use a interuppt to flush their FIFO. So a 
> spin_lock_irqsave(&fb_info->vm_area->vm_mm->page_table_lock, flags);
> should always be used correct?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
