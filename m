Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B83E6B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 00:11:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j5so12099223pfb.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 21:11:00 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id g7si723782plk.69.2017.03.14.21.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 21:10:59 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: Change generic FALLBACK zonelist creation process
References: <1d67f38b-548f-26a2-23f5-240d6747f286@linux.vnet.ibm.com>
 <20170308092146.5264-1-khandual@linux.vnet.ibm.com>
 <0f787fb7-e299-9afb-8c87-4afdb937fdbb@nvidia.com>
 <13c1a501-0ab9-898c-f749-efecca787661@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <aa0233a3-ccea-2a08-7937-6d762cfdab57@nvidia.com>
Date: Tue, 14 Mar 2017 21:10:58 -0700
MIME-Version: 1.0
In-Reply-To: <13c1a501-0ab9-898c-f749-efecca787661@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

On 03/14/2017 06:33 AM, Anshuman Khandual wrote:
> On 03/08/2017 04:37 PM, John Hubbard wrote:
[...]
>> There was a discussion, on an earlier version of this patchset, in which
>> someone pointed out that a slight over-allocation on a device that has
>> much more memory than the CPU has, could use up system memory. Your
>> latest approach here does not address this.
>
> Hmm, I dont remember this. Could you please be more specific and point
> me to the discussion on this.

That idea came from Dave Hansen, who was commenting on your RFC V2 patch:

https://lkml.org/lkml/2017/1/30/894

..."A device who got its memory usage off by 1% could start to starve the rest of the system..."

>
>>
>> I'm thinking that, until oversubscription between NUMA nodes is more
>> fully implemented in a way that can be properly controlled, you'd
>
> I did not get you. What does over subscription mean in this context ?
> FALLBACK zonelist on each node has memory from every node including
> it's own. Hence the allocation request targeted towards any node is
> symmetrical with respect to from where the memory will be allocated.
>

Here, I was referring to the lack of support in the kernel today, for allocating X+N bytes on a NUMA 
node, when that node only has X bytes associated with it. Currently, the system uses a fallback node 
list to try to allocate on other nodes, in that case, but that's not idea. If it NUMA allocation 
instead supported "oversubscription", it could allow the allocation to succeed, and then fault and 
evict (to other nodes) to support a working set that is larger than the physical memory that the 
node has.

This is what GPUs do today, in order to handle work loads that are too large for GPU memory. This 
enables a whole other level of applications that the user can run.

Maybe there are other ways to get the same result, so if others have ideas, please chime in. I'm 
assuming for now that this sort of thing will just be required in the coming months.

>> probably better just not fallback to system memory. In other words, a
>> CDM node really is *isolated* from other nodes--no automatic use in
>> either direction.
>
> That is debatable. With this proposed solution the CDM FALLBACK
> zonelist contains system RAM zones as fallback option which will
> be used in case CDM memory is depleted. IMHO, I think thats the
> right thing to do as it still maintains the symmetry to some
> extent.
>

Yes, it's worth discussing. Again, Dave's note applies here.

>>
>> Also, naming and purpose: maybe this is a "Limited NUMA Node", rather
>> than a Coherent Device Memory node. Because: the real point of this
>> thing is to limit the normal operation of NUMA, just enough to work with
>> what I am *told* is memory-that-is-too-fragile-for-kernel-use (I remain
>> soemwhat on the fence, there, even though you did talk me into it
>> earlier, heh).
>
> :) Naming can be debated later after we all agree on the proposal
> in principle. We have already discussed about kernel memory on CDM
> in detail.

OK.

thanks,
John Hubbard
NVIDIA

>
>>
>> On process: it would probably help if you gathered up previous
>> discussion points and carefully, concisely addressed each one,
>> somewhere, (maybe in a cover letter). Because otherwise, it's too easy
>> for earlier, important problems to be forgotten. And reviewers don't
>> want to have to repeat themselves, of course.
>
> Will do.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
