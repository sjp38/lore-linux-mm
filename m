Message-ID: <46843E65.3020008@redhat.com>
Date: Thu, 28 Jun 2007 19:04:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random>	<466C36AE.3000101@redhat.com>	<20070610181700.GC7443@v2.random>	<46814829.8090808@redhat.com>	<20070626105541.cd82c940.akpm@linux-foundation.org>	<468439E8.4040606@redhat.com> <20070628155715.49d051c9.akpm@linux-foundation.org>
In-Reply-To: <20070628155715.49d051c9.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 28 Jun 2007 18:44:56 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
>> Andrew Morton wrote:
>>
>>> Where's the system time being spent?
>> OK, it turns out that there is quite a bit of variability
>> in where the system spends its time.  I did a number of
>> reaim runs and averaged the time the system spent in the
>> top functions.
>>
>> This is with the Fedora rawhide kernel config, which has
>> quite a few debugging options enabled.
>>
>> _raw_spin_lock		32.0%
>> page_check_address	12.7%
>> __delay			10.8%
>> mwait_idle		10.4%
>> anon_vma_unlink		5.7%
>> __anon_vma_link		5.3%
>> lockdep_reset_lock	3.5%
>> __kmalloc_node_track_caller 2.8%
>> security_port_sid	1.8%
>> kfree			1.6%
>> anon_vma_link		1.2%
>> page_referenced_one	1.1%
>>
>> In short, the system is waiting on the anon_vma lock.
> 
> Sigh.  We had a workload (forget which, still unfixed) in which things
> would basically melt down in that linear anon_vma walk, walking 10,000 or
> more vma's.  I wonder if that's what's happening here?

That would be a large multi-threaded application that fills up
memory.  Customers are reproducing this with JVMs on some very
large systems.

> Also, one thing to watch out for here is a problem with the spinlocks
> themselves: the problem wherein the cores in one package keep rattling the
> lock around between them and never let it out for the cores in another
> package to grab.

This is a single package quad core system, though.

>> I wonder if Lee Schemmerhorn's patch to turn that
>> spinlock into an rwlock would help this workload,
>> or if we simply should scan fewer pages in the
>> pageout code.
> 
> Maybe.  I'm thinking that the problem here is really due to the huge amount
> of processing which needs to occur when we are in the "all pages active,
> referenced" state and then we hit pages_low.  Panic time, we need to scan
> and deactivate a huge amount of stuff.
> 
> Would it not be better to prevent that situation from occurring by doing a
> bit of scanning and balancing when adding pages to the LRU?  Make sure that
> the lists will be in reasonable shape for when reclaim starts?

Agreed, we need to simply scan fewer pages.

Doing something like SEQ replacement on the anonymous (and other
swap backed) pages might just do the trick here.  Page cache, of
course, should continue using a used-once scheme.

I suspect we want to split out the lists for many other reasons
anyway, as detailed on http://linux-mm.org/PageoutFailureModes

I'll whip up a patch that does this...

> That'd deoptimise those workloads which allocate and free pages but never
> enter reclaim.  Probably liveable with.

If we do true SEQ replacement for anonymous pages (deactivating
active pages without regard to the referenced bit) and keep the
inactive list reasonably small that penalty should be negligable.

> We would want to avoid needlessly unmapping pages and causing more minor
> faults.

That's a minor issue, the page fault path is pretty cheap and
very scalable.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
