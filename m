Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74FD26B0006
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 00:27:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a13-v6so5422149pfo.22
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 21:27:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w16-v6si12037813plk.79.2018.06.29.21.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 21:27:30 -0700 (PDT)
Message-ID: <5B370797.1090700@intel.com>
Date: Sat, 30 Jun 2018 12:31:19 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v34 0/4] Virtio-balloon: support free page reporting
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On 06/25/2018 08:05 PM, Wei Wang wrote:
> This patch series is separated from the previous "Virtio-balloon
> Enhancement" series. The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT,
> implemented by this series enables the virtio-balloon driver to report
> hints of guest free pages to the host. It can be used to accelerate live
> migration of VMs. Here is an introduction of this usage:
>
> Live migration needs to transfer the VM's memory from the source machine
> to the destination round by round. For the 1st round, all the VM's memory
> is transferred. From the 2nd round, only the pieces of memory that were
> written by the guest (after the 1st round) are transferred. One method
> that is popularly used by the hypervisor to track which part of memory is
> written is to write-protect all the guest memory.
>
> This feature enables the optimization by skipping the transfer of guest
> free pages during VM live migration. It is not concerned that the memory
> pages are used after they are given to the hypervisor as a hint of the
> free pages, because they will be tracked by the hypervisor and transferred
> in the subsequent round if they are used and written.
>
> * Tests
> - Test Environment
>      Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
>      Guest: 8G RAM, 4 vCPU
>      Migration setup: migrate_set_speed 100G, migrate_set_downtime 2 second
>
> - Test Results
>      - Idle Guest Live Migration Time (results are averaged over 10 runs):
>          - Optimization v.s. Legacy = 284ms vs 1757ms --> ~84% reduction

According to Michael's comments, add one more set of data here:

Enabling page poison with value=0, and enable KSM.

The legacy live migration time is 1806ms (averaged across 10 runs), 
compared to the case with this optimization feature in use (i.e. 284ms), 
there is still around ~84% reduction.


Best,
Wei
