From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Clean up of __alloc_pages
Date: Sun, 6 Nov 2005 18:35:53 +0100
References: <20051028183326.A28611@unix-os.sc.intel.com> <p73oe4z2f9h.fsf@verdi.suse.de> <20051105201841.2591bacc.pj@sgi.com>
In-Reply-To: <20051105201841.2591bacc.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511061835.53575.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 06 November 2005 05:18, Paul Jackson wrote:

> The current code in the kernel does the following:
>   1) The cpuset_update_current_mems_allowed() calls in the
>      various alloc_page*() paths in mm/mempolicy.c:
> 	* take the task_lock spinlock on the current task

That needs to go imho. At least for the common "cpusets compiled in, but not 
used" case. We already have too many locks. Even with cpusets - why
can't you test that generation lockless?

> 	* compare the tasks mems_generation to that in its cpuset

>   2) The first cpuset_zone_allowed() call or two, near the top
>      of mm/page_alloc.c:__alloc_pages():
> 	* check in_interrupt()
> 	* check if the zone's node is set in task->mems_allowed

It's also too slow for the common "compiled in but not used" case.

I did a simple patch for that - at least skip all the loops when there
is no cpuset - but it got lost in a disk crash.

> This task_lock spinlock, or some performance equivalent, is, I think,
> unavoidable.

why?

>
> An essential difference between mempolicy and cpusets is that cpusets
> supports outside manipulation of a tasks memory placement.  

Yes, that is their big problem (there is a reason I'm always complaining
about attempts to change mempolicy externally) 

But actually some mempolicy can be already changed outside the task - 
using VMA policy.

> Sooner or 
> later, the task has to synchronize with these outside changes, and a
> task_lock(current) in the path to __alloc_pages() is the lowest cost
> way I could find to do this.

Why can't it just test that generation number lockless after testing
if there is a cpuset at all?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
