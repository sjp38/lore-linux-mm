Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 98E946B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 16:59:56 -0400 (EDT)
Message-ID: <520A9E4A.2050203@tilera.com>
Date: Tue, 13 Aug 2013 16:59:54 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
References: <5202CEAA.9040204@linux.vnet.ibm.com> <201308072335.r77NZZwl022494@farm-0012.internal.tilera.com> <20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org> <52099187.80301@tilera.com> <20130813123512.3d6865d8bf4689c05d44738c@linux-foundation.org> <20130813201958.GA28996@mtj.dyndns.org> <20130813133135.3b580af557d1457e4ee8331a@linux-foundation.org>
In-Reply-To: <20130813133135.3b580af557d1457e4ee8331a@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On 8/13/2013 3:35 PM, Andrew Morton wrote:
> He may be
> old and wrinkly, but I do suggest that the guy who wrote and maintains
> that code could have got a cc. 

Sorry about that - I just went by what MAINTAINERS shows.  There's no
specific maintainer listed for the swap code.  I probably should have
looked at the final Signed-off-by's on recent commits.

On 8/13/2013 4:31 PM, Andrew Morton wrote:
> On Tue, 13 Aug 2013 16:19:58 -0400 Tejun Heo <tj@kernel.org> wrote:
>
>> Hello,
>>
>> On Tue, Aug 13, 2013 at 12:35:12PM -0700, Andrew Morton wrote:
>>> I don't know how lots-of-kmallocs compares with alloc_percpu()
>>> performance-wise.
>> If this is actually performance sensitive,
> I've always assumed that it isn't performance-sensitive. 
> schedule_on_each_cpu() has to be slow as a dog.
>
> Then again, why does this patchset exist?  It's a performance
> optimisation so presumably someone cares.  But not enough to perform
> actual measurements :(

The patchset exists because of the difference between zero overhead on
cpus that don't have drainable lrus, and non-zero overhead.  This turns
out to be important on workloads where nohz cores are handling 10 Gb
traffic in userspace and really, really don't want to be interrupted,
or they drop packets on the floor.

>> the logical thing to do
>> would be pre-allocating per-cpu buffers instead of depending on
>> dynamic allocation.  Do the invocations need to be stackable?
> schedule_on_each_cpu() calls should if course happen concurrently, and
> there's the question of whether we wish to permit async
> schedule_on_each_cpu().  Leaving the calling CPU twiddling thumbs until
> everyone has finished is pretty sad if the caller doesn't want that.
>
>>> That being said, the `cpumask_var_t mask' which was added to
>>> lru_add_drain_all() is unneeded - it's just a temporary storage which
>>> can be eliminated by creating a schedule_on_each_cpu_cond() or whatever
>>> which is passed a function pointer of type `bool (*call_needed)(int
>>> cpu, void *data)'.
>> I'd really like to avoid that.  Decision callbacks tend to get abused
>> quite often and it's rather sad to do that because cpumask cannot be
>> prepared and passed around.  Can't it just preallocate all necessary
>> resources?
> I don't recall seeing such abuse.  It's a very common and powerful
> tool, and not implementing it because some dummy may abuse it weakens
> the API for all non-dummies.  That allocation is simply unneeded.

The problem with a callback version is that it's not clear that
it helps with Andrew's original concern about allocation.  In
schedule_on_each_cpu() we need to track which cpus we scheduled work
on so that we can flush_work() after all the work has been scheduled.
Even with a callback approach, we'd still end up wanting to record
the results of the callback in the first pass so that we could
properly flush_work() on the second pass.  Given that, having the
caller just create the cpumask in the first place makes more sense.

As Andrew suggests, we could also just have an asynchronous version
of schedule_on_each_cpu(), but I don't know if that's beneficial
enough to the swap code to make it worthwhile, or if it's tricky
enough on the workqueue side to make it not worthwhile; it does seem
like we would need to rethink the work_struct allocation, and
e.g. avoid re-issuing the flush to a cpu that hadn't finished the
previous flush, etc.  Potentially tricky, particularly if
lru_add_drain_all() doesn't care about performance in the first place.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
