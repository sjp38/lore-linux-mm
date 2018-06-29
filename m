Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5896B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 23:47:51 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bf1-v6so4282699plb.2
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 20:47:51 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g66-v6si7212044pgc.350.2018.06.28.20.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 20:47:49 -0700 (PDT)
Message-ID: <5B35ACD5.4090800@intel.com>
Date: Fri, 29 Jun 2018 11:51:49 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v34 0/4] Virtio-balloon: support free page reporting
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com> <c4dd0a13-91fb-c0f5-b41f-54421fdacca9@redhat.com>
In-Reply-To: <c4dd0a13-91fb-c0f5-b41f-54421fdacca9@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On 06/27/2018 07:06 PM, David Hildenbrand wrote:
> On 25.06.2018 14:05, Wei Wang wrote:
>> This patch series is separated from the previous "Virtio-balloon
>> Enhancement" series. The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>> implemented by this series enables the virtio-balloon driver to report
>> hints of guest free pages to the host. It can be used to accelerate live
>> migration of VMs. Here is an introduction of this usage:
>>
>> Live migration needs to transfer the VM's memory from the source machine
>> to the destination round by round. For the 1st round, all the VM's memory
>> is transferred. From the 2nd round, only the pieces of memory that were
>> written by the guest (after the 1st round) are transferred. One method
>> that is popularly used by the hypervisor to track which part of memory is
>> written is to write-protect all the guest memory.
>>
>> This feature enables the optimization by skipping the transfer of guest
>> free pages during VM live migration. It is not concerned that the memory
>> pages are used after they are given to the hypervisor as a hint of the
>> free pages, because they will be tracked by the hypervisor and transferred
>> in the subsequent round if they are used and written.
>>
>> * Tests
>> - Test Environment
>>      Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
>>      Guest: 8G RAM, 4 vCPU
>>      Migration setup: migrate_set_speed 100G, migrate_set_downtime 2 second
>>
>> - Test Results
>>      - Idle Guest Live Migration Time (results are averaged over 10 runs):
>>          - Optimization v.s. Legacy = 284ms vs 1757ms --> ~84% reduction
>>      - Guest with Linux Compilation Workload (make bzImage -j4):
>>          - Live Migration Time (average)
>>            Optimization v.s. Legacy = 1402ms v.s. 2528ms --> ~44% reduction
>>          - Linux Compilation Time
>>            Optimization v.s. Legacy = 5min6s v.s. 5min12s
>>            --> no obvious difference
>>
> Being in version 34 already, this whole thing still looks and feels like
> a big hack to me. It might just be me, but especially if I read about
> assumptions like "QEMU will not hotplug memory during migration". This
> does not feel like a clean solution.
>
> I am still not sure if we really need this interface, especially as real
> free page hinting might be on its way.
>
> a) we perform free page hinting by setting all free pages
> (arch_free_page()) to zero. Migration will detect zero pages and
> minimize #pages to migrate. I don't think this is a good idea but Michel
> suggested to do a performance evaluation and Nitesh is looking into that
> right now.

The hypervisor doesn't get the zero pages for free. It pays lots of CPU 
utilization and memory bandwidth (there are some guys complaining abut 
this on the QEMU mailinglist)
In the above results, the legacy part already has the zero page feature 
in use.

>
> b) we perform free page hinting using something that Nitesh proposed. We
> get in QEMU blocks of free pages that we can MADV_FREE. In addition we
> could e.g. clear the dirty bit of these pages in the dirty bitmap, to
> hinder them from getting migrated. Right now the hinting mechanism is
> synchronous (called from arch_free_page()) but we might be able to
> convert it into something asynchronous.
>
> So we might be able to completely get rid of this interface. And looking
> at all the discussions and problems that already happened during the
> development of this series, I think we should rather look into how clean
> free page hinting might solve the same problem.
>
> If it can't be solved using free page hinting, fair enough.
>

I'm afraid it can't. For example, when we have a guest booted, without 
too many memory activities. Assume the guest has 8GB free memory. The 
arch_free_page there won't be able to capture the 8GB free pages since 
there is no free() called. This results in no free pages reported to host.

Best,
Wei
