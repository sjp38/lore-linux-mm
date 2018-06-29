Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1798D6B000D
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:27:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id s3-v6so4904917plp.21
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 04:27:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a95-v6si8706691pla.401.2018.06.29.04.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 04:27:42 -0700 (PDT)
Message-ID: <5B36189E.5050204@intel.com>
Date: Fri, 29 Jun 2018 19:31:42 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v34 0/4] Virtio-balloon: support free page reporting
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com> <c4dd0a13-91fb-c0f5-b41f-54421fdacca9@redhat.com> <5B35ACD5.4090800@intel.com> <4840cbb7-dd3f-7540-6a7c-13427de2f0d1@redhat.com>
In-Reply-To: <4840cbb7-dd3f-7540-6a7c-13427de2f0d1@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, Andrea Arcangeli <aarcange@redhat.com>, Luiz Capitulino <lcapitulino@redhat.com>

On 06/29/2018 03:46 PM, David Hildenbrand wrote:
>>
>> I'm afraid it can't. For example, when we have a guest booted, without
>> too many memory activities. Assume the guest has 8GB free memory. The
>> arch_free_page there won't be able to capture the 8GB free pages since
>> there is no free() called. This results in no free pages reported to host.
>
> So, it takes some time from when the guest boots up until the balloon
> device was initialized and therefore page hinting can start. For that
> period, you won't get any arch_free_page()/page hinting callbacks, correct.
>
> However in the hypervisor, you can theoretically track which pages the
> guest actually touched ("dirty"), so you already know "which pages were
> never touched while booting up until virtio-balloon was brought to
> life". These, you can directly exclude from migration. No interface
> required.
>
> The remaining problem is pages that were touched ("allocated") by the
> guest during bootup but freed again, before virtio-balloon came up. One
> would have to measure how many pages these usually are, I would say it
> would not be that many (because recently freed pages are likely to be
> used again next for allocation). However, there are some pages not being
> reported.
>
> During the lifetime of the guest, this should not be a problem,
> eventually one of these pages would get allocated/freed again, so the
> problem "solves itself over time". You are looking into the special case
> of migrating the VM just after it has been started. But we have the
> exact same problem also for ordinary free page hinting, so we should
> rather solve that problem. It is not migration specific.
>
> If we are looking for an alternative to "problem solves itself",
> something like "if virtio-balloon comes up, it will report all free
> pages step by step using free page hinting, just like we would have from
> "arch_free_pages()"". This would be the same interface we are using for
> free page hinting - and it could even be made configurable in the guest.
>
> The current approach we are discussing internally for details about
> Nitesh's work ("how the magic inside arch_fee_pages() will work
> efficiently) would allow this as far as I can see just fine.
>
> There would be a tiny little window between virtio-balloon comes up and
> it has reported all free pages step by step, but that can be considered
> a very special corner case that I would argue is not worth it to be
> optimized.
>
> If I am missing something important here, sorry in advance :)
>

Probably I didn't explain that well. Please see my re-try:

That work is to monitor page allocation and free activities via 
arch_alloc_pages and arch_free_pages. It has per-CPU lists to record the 
pages that are freed to the mm free list, and the per-CPU lists dump the 
recorded pages to a global list when any of them is full.
So its own per-CPU list will only be able to get free pages when there 
is an mm free() function gets called. If we have 8GB free memory on the 
mm free list, but no application uses them and thus no mm free() calls 
are made. In that case, the arch_free_pages isn't called, and no free 
pages added to the per-CPU list, but we have 8G free memory right on the 
mm free list.
How would you guarantee the per-CPU lists have got all the free pages 
that the mm free lists have?

- I'm also worried about the overhead of maintaining so many per-CPU 
lists and the global list. For example, if we have applications 
frequently allocate and free 4KB pages, and each per-CPU list needs to 
implement the buddy algorithm to sort and merge neighbor pages. Today a 
server can have more than 100 CPUs, then there will be more than 100 
per-CPU lists which need to sync to a global list under a lock, I'm not 
sure if this would scale well.

- This seems to be a burden imposed on the core mm memory 
allocation/free path. The whole overhead needs to be carried during the 
whole system life cycle. What we actually expected is to just make one 
call to get the free page hints only when live migration happens.

Best,
Wei
