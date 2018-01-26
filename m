Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F14F46B0007
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 21:09:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u26so7408349pfi.3
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 18:09:04 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e8-v6si2956452pls.595.2018.01.25.18.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 18:09:03 -0800 (PST)
Message-ID: <5A6A8E56.90408@intel.com>
Date: Fri, 26 Jan 2018 10:11:34 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v25 1/2 RESEND] mm: support reporting free page blocks
References: <1516873107-34950-1-git-send-email-wei.w.wang@intel.com> <20180125144124.7e9f6e2156b1b940b07aecfc@linux-foundation.org>
In-Reply-To: <20180125144124.7e9f6e2156b1b940b07aecfc@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/26/2018 06:41 AM, Andrew Morton wrote:
> On Thu, 25 Jan 2018 17:38:27 +0800 Wei Wang <wei.w.wang@intel.com> wrote:
>
>> This patch adds support to walk through the free page blocks in the
>> system and report them via a callback function. Some page blocks may
>> leave the free list after zone->lock is released, so it is the caller's
>> responsibility to either detect or prevent the use of such pages.
>>
>> One use example of this patch is to accelerate live migration by skipping
>> the transfer of free pages reported from the guest. A popular method used
>> by the hypervisor to track which part of memory is written during live
>> migration is to write-protect all the guest memory. So, those pages that
>> are reported as free pages but are written after the report function
>> returns will be captured by the hypervisor, and they will be added to the
>> next round of memory transfer.
> It would be useful if we had some quantitative testing results, so we
> can see the real-world benefits from this change?
>

Sure. Thanks for the reminder, I think I'll also attach this to the 
cover letter:

Without this feature, locally live migrating an 8G idle guest takes 
~2286 ms. With this featrue, it takes ~260 ms, which reduces the 
migration time to ~11%.

Idle guest means a guest which doesn't run any specific workloads after 
boots. The improvement depends on how much free memory the guest has, 
idle guest is a good case to show the improvement. From the optimization 
point of view, having something is better than nothing, IMHO. If the 
guest has less free memory, the improvement will be less, but still 
better than no improvement.

Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
