Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 62C1A6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 09:52:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 16 Apr 2013 19:18:41 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 5A1B31258051
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 19:23:27 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3GDprbq13631942
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 19:21:53 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3GDpscl028088
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 23:51:57 +1000
Message-ID: <516D56DA.7000102@linux.vnet.ibm.com>
Date: Tue, 16 Apr 2013 19:19:14 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 14/15] mm: Add alloc-free handshake to trigger
 memory region compaction
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com> <20130409214853.4500.63619.stgit@srivatsabhat.in.ibm.com> <5165F508.4020207@linux.vnet.ibm.com>
In-Reply-To: <5165F508.4020207@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Hi Cody,

Thank you for your review comments and sorry for the delay in replying!

On 04/11/2013 04:56 AM, Cody P Schafer wrote:
> On 04/09/2013 02:48 PM, Srivatsa S. Bhat wrote:
>> We need a way to decide when to trigger the worker threads to perform
>> region evacuation/compaction. So the strategy used is as follows:
>>
>> Alloc path of page allocator:
>> ----------------------------
>>
>> This accurately tracks the allocations and detects the first allocation
>> in a new region and notes down that region number. Performing compaction
>> rightaway is not going to be helpful because we need free pages in the
>> lower regions to be able to do that. And the page allocator allocated in
>> this region precisely because there was no memory available in lower
>> regions.
>> So the alloc path just notes down the freshly used region's id.
>>
>> Free path of page allocator:
>> ---------------------------
>>
>> When we enter this path, we know that some memory is being freed. Here we
>> check if the alloc path had noted down any region for compaction. If so,
>> we trigger the worker function that tries to compact that memory.
>>
>> Also, we avoid any locking/synchronization overhead over this worker
>> function in the alloc/free path, by attaching appropriate semantics to
>> the
>> available status flags etc, such that we won't need any special locking
>> around them.
>>
> 
> Can you explain why avoiding locking works in this case?
> 

Sure, see below. BTW, the whole idea behind doing this is to avoid additional
overhead as much as possible, since these are quite hot paths in the kernel.

> It appears the lack of locking is only on the worker side, and the
> mem_power_ctrl is implicitly protected by zone->lock on the alloc & free
> side.
> 

That's right. What I meant to say is that I don't introduce any *extra*
locking overhead in the alloc/free path, just to synchronize the updates to
mem_power_ctrl. On the alloc/free side, as you rightly noted, I piggyback
on the zone->lock to get the synchronization right.

On the worker side, I don't need any locking, due to the following reasons:

a. Only 1 worker (at max) is active at any given time.

   The free path of the page allocator (which queues the worker) never
   queues more than 1 worker at a time. If a worker is still busy doing a
   previously queued work, the free path just ignores new hints from the
   alloc path about region evacuation. So essentially no 2 workers run at
   the same time. So the worker need not worry about being re-entrant.

b. The ->work_status field in the mem_power_ctrl structure is never written
   to by 2 different tasks at the same time.
 
   The free path always avoids updates to the ->work_status field in presence
   of an active worker. That is, until the ->work_status is set to
   MEM_PWR_WORK_COMPLETE by the worker, the free path won't write to it.

   So the ->work_status field can be written to by the worker and read by
   the free path at the same time - which is fine, because in that case,
   if the free path read the old value, it will just assume that the worker
   is still active and ignores the alloc path's hint, which is harmless.
   Similar is the case about why the alloc path can read the ->work_status
   without locking out the worker : if it reads the old value, it doesn't
   set any new hints in ->region, which is again fine.

c. The ->region field in the mem_power_ctrl structure is also never written
   to by 2 different tasks at the same time. This goes by extending the logic
   in 'b'.

Yes, this scheme could mean that sometimes we might lose a few opportunities to
perform region evacuation, but that is OK, because that's the price we pay
in order to avoid hurting performance too much. Besides, there's a more
important reason why its actually critical that we aren't too aggressive
and jump at every opportunity to do compaction; see below.

> In the previous patch I see smp_mb(), but no explanation is provided for
> why they are needed. Are they related to/necessary for this lack of
> locking?
> 

Hmm, looking at that again, I don't think it is needed. I'll remove it in
the next version.

> What happens when a region is passed over for compaction because the
> worker is already compacting another region? Can this occur?

Yes it can occur. But since we try to allocate pages in increasing order of
regions, if this situation does occur, there is a very good chance that we
won't benefit from compacting both regions, see below.

> Will the
> compaction re-trigger appropriately?
> 

No, there is no re-trigger and that's by design. A particular region being
suitable for compaction is only a transient/temporary condition; it might
not persist forever. So it might not be worth trying over and over.
So if the worker was busy compacting some other region when the alloc path
hinted a new region for compaction, we simply ignore it because, there is
no guarantee that that situation (the new region being suitable for compaction)
would continue to hold good when the worker finishes its current job.

Part of it is actually true even for *any* work that the worker performs:
by the time it gets into action, the region might not be suitable for
compaction any more, perhaps because more pages have been allocated from that
region in the meantime, making evacuation costlier. So, that part is handled
by re-evaluating the situation by looking at the region statistics in the
worker, before actually performing the compaction.

The harder problem to solve is: how to avoid having workers clash or otherwise
undo the efforts of each other. That is, say we tried to compact 2 regions
say A and B, one soon after the other. Then it is a little hard to guarantee
that we didn't do the stupid mistake of first moving pages of A to B via
compaction and then again compacting B and moving the pages elsewhere.
I still need to think of ways to explicitly avoid this from happening. But on
a first approximation, as mentioned above, if the alloc path saw fresh
allocations on 2 different regions within a short period of time, its probably
best to avoid taking *both* hints into consideration and instead act on only
one of them. That's why this patch doesn't bother re-triggering compaction
at a later time, if the worker was already busy working on another region.

> I recommend combining this patch and the previous patch to make the
> interface more clear, or make functions that explicitly handle the
> interface for accessing mem_power_ctrl.
>

Sure, I'll think more on how to make it clearer.

Thanks a lot!
 
Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
