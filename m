Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBC96B02F3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 03:00:35 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m40so18584650ioi.4
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 00:00:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h25sor1120443iti.8.2017.08.29.00.00.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 00:00:32 -0700 (PDT)
Subject: Re: [PATCH] mm/ksm : Checksum calculation function change (jhash2 ->
 crc32)
References: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
 <20170801200550.GB24406@redhat.com>
 <bf406908-bf93-83dd-54e6-d2e3e5881db6@os.korea.ac.kr>
 <20170803132350.GI21775@redhat.com>
 <df5c8e04-280b-c0eb-2820-eff2dce67582@os.korea.ac.kr>
 <20170824191453.GE7241@redhat.com>
From: sioh Lee <solee@os.korea.ac.kr>
Message-ID: <cb640b63-a9f3-c083-6453-43006a59b477@os.korea.ac.kr>
Date: Tue, 29 Aug 2017 15:35:34 +0900
MIME-Version: 1.0
In-Reply-To: <20170824191453.GE7241@redhat.com>
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, zhongjiang@huawei.com, minchan@kernel.org, arvind.yadav.cs@gmail.com, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hxy@os.korea.ac.kr, oslab@os.korea.ac.kr

Hello,
Thank you for the reply and for being supportive.
First of all, I made a mistake in that I typed crc32 incorrectly. All the experiments were done using crc32c-intel, not crc32 (PCLMULQDQ).

Second, the reason for (priority < 200) is because the priority of crc32c-intel is 200 so that if the priority is less than 200, jhash2 is used.
Also, I have a question about implementation. Do you want to exclude jhash2 from ksm and go only with crc32 ? Could you please give me guidance about it?

Then, I will implement it and send you a new patch.
Once again, thank you so much for your reply.
Best regards,

-Sioh Lee-


2017-08-25 ?AAu 4:14?! Andrea Arcangeli AI(?!)  3/4 ' +-U:
> On Wed, Aug 09, 2017 at 10:17:31PM +0900, sioh Lee wrote:
>> Hello.
>> I am sending you the results of the experiments.
>> The experiment was done for two workloads.
>> The first is Kernel build (CPU Intensive) and the second is the iozone benchmark (I/O Intensive).
>> In the experiment, four VMs compile kernel at the same time.
>> I also experimented with iozone in the same way.
>>
>>
>> The values measured in the experiment are:
>> 1. CoW count, 2. Checksum computation time, 3. pages_unshared, 4. pages_sharing, 5. (pages_unshared / pages_sharing).
>> The experiment was conducted twice for each workload and the average value was calculated.
>> Checksum computation time, pages_unshared, and pages_sharing are recorded every 1 second,
>> and the average of the recorded values is obtained after the end of the experiment.
>> The CoW was also recorded whenever CoW occurs on a shared page.
>>
>> Experiment environment
>>
>> test platform : openstack cloud platform (NEWTON version)
>> Experiment node : openstack based cloud compute node (CPU: Xeon E5-2650 v3 2.3Ghz 10core, memory : 64Gb)
>> VM : (2 VCPU, RAM 4GB, DISK 20GB) * 4
>> workload : Kernel Compile (kernel 4.47), iozone (read, write, random read and write for 2GB)
>> KSM setup - sleep_millisecs : 200ms, pages_to_scan : 1600
>>
>> The experimental results are as follows. (All values are truncated to the second decimal place)
> Not sure if kernel build but especially iozone are the best tests for
> this, a number crunching may have generate a larger set of pages,
> these issues would be noticeable only with a very large unstable tree
> (i.e. very large pages_unshared). You've got a very tiny
> pages_unshared of only <=1GB in your tests. That should grow much
> larger to make the measurement meaningful for this hash collision
> concern.
>
> However so far I checked some more information on the collisions of
> crc32. With equal sized random data (i.e. our case, PAGE_SIZE in
> length) it takes about ~78000 tries of new random data for crc32 to
> trigger a collision with 51% probability, or ~200000 tries to get a
> collision with 99% probability.
>
> jhash2 instead starts seeing collisions with 2**52 random data tries?
>
> Our objective here is to simulate a dirty bit, the problem with the
> real pagetable dirty bit is it potentially requires an IPI to threads
> using the "mm" to clear it reliably (i.e. to be sure it gets set on
> next write), and not all archs have the dirty bit set in
> hardware. Write protecting to simulate the dirty bit also wouldn't be
> a solution, because our whole objective is to avoid wrprotecting the
> first place while at the same time we try not to make the unstable
> tree too unstable by adding pages that are statistically changing
> frequently to it.
>
> There were attempts in the past to use the dirty bit on x86 (plus
> skipping the IPI probably wouldn't be a big issue for KSM because the
> scan is linear and takes quite some time to complete if there's lots
> of virtual memory to merge).
>
> So after evaluating 200000 different candidate pages that are changing
> frequently, to see if they're worth adding them to the unstable tree,
> we'll sure get a false positive if compared to jhash2 (we'll add one
> more page than we should have to). Considering the pages can start
> changing at any time regardless after we add them to the unstable tree
> and this check is only statistically significant, the difference with
> jhash2 is probably not going to be noticeable here. We don't use the
> hash to find equal pages of course, the unstable tree does that. I
> earlier thought crc32 would require fewer tries before creating
> collisions, much closer to a checksum. So now I'm optimistic this
> change will be a good tradeoff.
>
> If we switch to crc32 however I don't see why not to use it also if
> the intel insn isn't present (why the < 200?). It's surely running
> much faster also in the generic implementation (jhash2 isn't
> accelerated either).
>
> If we force CRC32C to be enabled if KSM is selected we could drop
> jhash2 entirely. Then we'd need a way to ensure the accelerated
> version gets loaded.
>
> Now about implementation issues, crc32 insn is actually used by crc32c
> not by crc32 (crc32c seems preferable polynomial anyway), the crc32
> that you selected only uses PCLMULQDQ, not the crc32 insn of sse4.2.
>
> I guess on Intel we could try to load crc32c first, if that showup at
> priority < 200 (sse4.2 crc32 that I think you intended to use but you
> got the PCLMULQDQ crc32 instead), then try again with crc32, if that
> also showup at priority < 200, then take crc32c generic (without
> fallback to jhash2 provided we've a build-time way to ensure the
> generic implementation is linked into the kernel as suggested above).
>
> Other archs using different algorithm sounds fine too, for example
> assuming crc32be would be the fastest (not sure, just a guess) it
> could be arch dependent the selection logic (the only non trivial
> issue would be to avoid #ifdefs to make it arch dependent). As long as
> the default fallbacks to generic that's fine.
>
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
