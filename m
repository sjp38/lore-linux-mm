Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id DE4D86B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 02:00:36 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id d205so54415797oia.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 23:00:36 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id i126si1555670oia.28.2016.03.09.23.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 23:00:36 -0800 (PST)
From: Jitendra Kolhe <jitendra.kolhe@hpe.com>
Subject: Re: [Qemu-devel] [RFC kernel 0/2]A PV solution for KVM live migration optimization
Date: Thu, 10 Mar 2016 12:31:32 +0530
Message-Id: <1457593292-30686-1-git-send-email-jitendra.kolhe@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: amit.shah@redhat.com
Cc: liang.z.li@intel.com, dgilbert@redhat.com, ehabkost@redhat.com, kvm@vger.kernel.org, mst@redhat.com, quintela@redhat.com, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, linux-mm@kvack.org, pbonzini@redhat.com, akpm@linux-foundation.org, virtualization@lists.linux-foundation.org, rth@twiddle.net, mohan_parthasarathy@hpe.com, simhan@hpe.com

On 3/8/2016 4:44 PM, Amit Shah wrote:
> On (Fri) 04 Mar 2016 [15:02:47], Jitendra Kolhe wrote:
>>>>
>>>> * Liang Li (liang.z.li@intel.com) wrote:
>>>>> The current QEMU live migration implementation mark the all the
>>>>> guest's RAM pages as dirtied in the ram bulk stage, all these pages
>>>>> will be processed and that takes quit a lot of CPU cycles.
>>>>>
>>>>> From guest's point of view, it doesn't care about the content in free
>>>>> pages. We can make use of this fact and skip processing the free pages
>>>>> in the ram bulk stage, it can save a lot CPU cycles and reduce the
>>>>> network traffic significantly while speed up the live migration
>>>>> process obviously.
>>>>>
>>>>> This patch set is the QEMU side implementation.
>>>>>
>>>>> The virtio-balloon is extended so that QEMU can get the free pages
>>>>> information from the guest through virtio.
>>>>>
>>>>> After getting the free pages information (a bitmap), QEMU can use it
>>>>> to filter out the guest's free pages in the ram bulk stage. This make
>>>>> the live migration process much more efficient.
>>>>
>>>> Hi,
>>>>   An interesting solution; I know a few different people have been looking at
>>>> how to speed up ballooned VM migration.
>>>>
>>>
>>> Ooh, different solutions for the same purpose, and both based on the balloon.
>>
>> We were also tying to address similar problem, without actually needing to modify
>> the guest driver. Please find patch details under mail with subject.
>> migration: skip sending ram pages released by virtio-balloon driver
>
> The scope of this patch series seems to be wider: don't send free
> pages to a dest at all, vs. don't send pages that are ballooned out.
>
> 		Amit

Hi,

Thanks for your response. The scope of this patch series doesna??t seem to take care 
of ballooned out pages. To balloon out a guest ram page the guest balloon driver does 
a alloc_page() and then return the guest pfn to Qemu, so ballooned out pages will not 
be seen as free ram pages by the guest.
Thus we will still end up scanning (for zero page) for ballooned out pages during 
migration. It would be ideal if we could have both solutions.

Thanks,
- Jitendra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
