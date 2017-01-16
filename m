Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6A246B0038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 17:45:20 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so268232226pfx.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 14:45:20 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id b84si13094356pfl.88.2017.01.16.14.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 14:45:19 -0800 (PST)
Subject: Re: [LSF/MM TOPIC/ATTEND] Memory Types
References: <9a0ae921-34df-db23-a25e-022f189608f4@intel.com>
 <22fbcb9f-f69a-6532-691f-c0f757cf6b8b@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <7cb30765-6e04-427f-47ea-23fd4158a910@nvidia.com>
Date: Mon, 16 Jan 2017 14:45:18 -0800
MIME-Version: 1.0
In-Reply-To: <22fbcb9f-f69a-6532-691f-c0f757cf6b8b@linux.vnet.ibm.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>



On 01/16/2017 02:59 AM, Anshuman Khandual wrote:
> On 01/16/2017 10:59 AM, Dave Hansen wrote:
>> Historically, computers have sped up memory accesses by either adding
>> cache (or cache layers), or by moving to faster memory technologies
>> (like the DDR3 to DDR4 transition).  Today we are seeing new types of
>> memory being exposed not as caches, but as RAM [1].
>>
>> I'd like to discuss how the NUMA APIs are being reused to manage not
>> just the physical locality of memory, but the various types.  I'd also
>> like to discuss the parts of the NUMA API that are a bit lacking to
>> manage these types, like the inability to have fallback lists based on
>> memory type instead of location.
>>
>> I believe this needs to be a distinct discussion from Jerome's HMM
>> topic.  All of the cases we care about are cache-coherent and can be
>> treated as "normal" RAM by the VM.  The HMM model is for on-device
>> memory and is largely managed outside the core VM.
>
> Agreed. In future core VM should be able to deal with these type of
> coherent memory directly as part of the generic NUMA API and page
> allocator framework. The type of the coherent memory must be a factor
> other than NUMA distances while dealing with it from a NUMA perspective
> as well from page allocation fallback sequence perspective. I have been
> working on a very similar solution called CDM (Coherent Device Memory)
> where we change the zonelist building process as well mbind() interface
> to accommodate a different type of coherent memory other than existing
> normal system RAM. Here are the related postings and discussions.
>
> https://lkml.org/lkml/2016/10/24/19 (CDM with modified zonelists)
> https://lkml.org/lkml/2016/11/22/339 (CDM with modified cpusets)
>
> Though named as "device" for now, it can very well evolve into a generic
> solution to accommodate all kinds of coherent memory (which warrants
> them to be treated at par with system RAM in the core VM in the first
> place). I would like to attend to discuss this topic.

Yes. I'm also very interested in working through a clear way to describe memory, and use it, for 
CDM, NUMA devices, and HMM situations.

I agree that hardware-based memory coherence should be a major dividing line, as Anshuman mentions 
above. So for non-coherent memory, something very like HMM still has to exist...or so I believe, in 
the absence of seeing any better ideas. (16 proposed versions of HMM have gone by, and still no 
better ideas yet, so it's probably about right.)

We also need to work through the memory hot plug questions, and the pfn and struct pages questions: 
avoiding conflicts with real physical memory. I'm still hoping for something like "just put the 
device struct pages above the physical limit for CPU struct pages", but I approximately recall that 
there were a few CPU arch's that didn't like that (might be mis-remembering that point).

Beyond that, there is also: whether a CPU or device should move pages around, or map pages. That's 
often a fairly dynamic (runtime) question, depending on both the machine layout (there are a *lot* 
of subtle variations, and more are coming), and the workload.

Furthermore, similar questions apply to memory that can be shared peer-to-peer. So far, both those 
points are handled in device drivers, but as the kernel becomes more aware of high-speed, 
page-fault-capable remote devices, we may want to move some of this into the main kernel.

Also, as Anshuman pointed out in another thread, these topics go together (although it's unlikely to 
fit into a single hour, so maybe a couple of slots is better):

(1) [LSF/MM TOPIC/ATTEND] Memory Types
(2) [LSF/MM TOPIC] Un-addressable device memory and block/fs implications
(3) [LSF/MM TOPIC] Memory hotplug, ZONE_DEVICE, and the future of struct page
(4) [LSF/MM ATTEND] HMM, CDM and other infrastructure for device memory management

I'm interested in all of the above.

thanks
John Hubbard
NVIDIA

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
