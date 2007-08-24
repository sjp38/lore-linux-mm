Message-ID: <46CE694C.7060504@redhat.com>
Date: Fri, 24 Aug 2007 01:14:52 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: Drop caches - is this safe behavior?
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>	 <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>	 <46CE3617.6000708@redhat.com> <bd9320b30708232135g38095588ld336017388412ea0@mail.gmail.com>
In-Reply-To: <bd9320b30708232135g38095588ld336017388412ea0@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mike <mike503@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mike wrote:
> thanks for the reply... few comments
> 
> On 8/23/07, Chris Snook <csnook@redhat.com> wrote:
> 
>> This widespread fallacy has been false for a long time.  The kernel will
>> swap instead of dropping caches if it believes that doing so will
>> improve performance.  It uses heuristics for this, and sometimes guesses
>> wrong, but it's not a bad thing.  Consider the memory used in the
>> initialization and shutdown routines for an application.  In normal
>> operation, you're never using it, so it's much better to swap this out
>> than to drop caches of a file you've actually accessed recently.  It is
>> completely normal to use have a small amount of swap utilization for
>> precisely this reason.  All you're doing by dropping caches is hurting
>> performance, probably by a lot.  The drop_caches patch was resisted for
>> a very long time because we knew people would use it to shoot themselves
>> in the foot.  It should only be used for debugging or benchmarking.
> 
> with this going right now, i have 0 megs of swap being used, tons of
> physical memory available. basically what i would expect to see.

You're expecting the wrong thing.  On any steady workload, free physical 
memory should only be just enough to satisfy emergency allocations, 
generally a few percent at most.  If any more than this is free, you're 
getting less performance than you would be if you had better (higher) 
utilization.  There are fleetingly rare exceptions to this, all of them 
bugs that have been or should be fixed.

> i
> have the PHP fastcgi engines killing themselves after only 50 requests
> (aggressive) - its their effort to keep memory leaks away. i have
> tried both aggressive and non-aggressive request numbers.

Okay, so it sounds like you have an extremely unsteady load, due to this 
leak/restart cycle.  That's the problem you need to be fixing.  The 
kernel is behaving correctly.

>> "Rampant and greedy" is correct behavior, as long as it doesn't harm
>> performance.  Usually it helps performance, but if it does harm
>> performance, let us know, since that would be a bug we need to fix.  By
>> dropping caches of NFS-backed files on multiple systems, you're moving
>> the load from several underutilized systems to one heavily-utilized system.
> 
> it seems to affect performance. that's one of the reasons i am trying this out.

Can you quantify this, perhaps with sar data?

>> Safety aside, it's harmful no matter where you do it.  Forget about
>> drop_caches.  Don't use it.  It wasn't meant for your use case.
>>
>> If you think the system is doing the wrong thing (and it doesn't sound
>> like it is) you should be tweaking the vm.swappiness sysctl.  The
>> default is 60, but lower values will make it behave more like you think
>> it should be behaving, though you'll still probably see a tiny bit of
>> swap usage.  Of course, if your webservers are primarily serving up
>> static content, you'll want a higher value, since swapping anonymous
>> memory will leave more free for the pagecache you're primarily working with.
> 
> i have played with swappiness, i had it down to 10 at one point.

Can you quantify the impact it had?  Perhaps your workload is one we 
could use to inform slightly more intelligent self-tuning in the VM, but 
we'd need hard numbers before we could even begin such analysis.

> i have the drop_caches going every 5 minutes. the servers seem to be
> running well. i had complaints after maybe 24 hours that things began
> to lag on the web side. this has been running great so far.

If you need to do it every 5 minutes, that must be one hell of a bad 
memory leak in your application.  I've seen arguably legitimate uses of 
drop_caches to clean up after backup jobs.  They fire exactly once, at 
the end of the job.  Pagecache is only filling back up because you're 
actually using those files, so all of the data you're getting rid of is 
data that has been used in the last 5 minutes.

If your complaints are happening after 24 hours, then drop caches once 
every 12 hours, at non-peak times.  It's still an ugly hack, but it's a 
less damaging ugly hack.  If you're running out of anything, it's 
probably *lower zone* memory, or *contiguous* memory for NFS operations 
and DMA buffers.  If you're on i386, vm.lower_zone_protection=100 will 
mitigate this.

> i am also trying out a drop_caches with swappiness of 0 too on one
> machine to see how that works.
> 
> it doesn't seem to be hurting anything currently. the NFS server is
> performing with plenty of idle CPU, webservers have free memory, not
> stuck up in swap that seems to not necessarily recycle nicely.

There's no such thing as "stuck up in swap".  Swap is an optimization, 
and the kernel has chosen to use swap because it believes that doing so 
will free memory for more important pagecache.  Swap doesn't "recycle" 
back into RAM unless someone is actually using it.  The fact that it 
remains in swap *proves* that it belongs there.

> i'm trying deadline scheduler, the SLUB allocator, all sorts of things
> here. sysctl configuration for tcp tweaks - with and without. nfs v3
> and nfs v4. this actually seems to work though...

Sure, it works, but it's not efficient, and it should never be 
necessary.  If it truly is necessary, we need to fix the VM.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
