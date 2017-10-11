Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA666B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 22:27:40 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j126so379814oib.9
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 19:27:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q8si1363212oic.191.2017.10.10.19.27.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 19:27:38 -0700 (PDT)
Message-Id: <201710110226.v9B2QGdx019779@www262.sakura.ne.jp>
Subject: Re: Re: [PATCH v16 3/5] virtio-balloon: =?ISO-2022-JP?B?VklSVElPX0JBTExP?=
 =?ISO-2022-JP?B?T05fRl9TRw==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 11 Oct 2017 11:26:16 +0900
References: <201710102209.DBE39528.MtFLOJQSFOFVOH@I-love.SAKURA.ne.jp> <59DD7932.3070106@intel.com>
In-Reply-To: <59DD7932.3070106@intel.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: mst@redhat.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Wei Wang wrote:
>On 10/10/2017 09:09 PM, Tetsuo Handa wrote:
>> Wei Wang wrote:
>>>> And even if we could remove balloon_lock, you still cannot use
>>>> __GFP_DIRECT_RECLAIM at xb_set_page(). I think you will need to use
>>>> "whether it is safe to wait" flag from
>>>> "[PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()" .
>>> Without the lock being held, why couldn't we use __GFP_DIRECT_RECLAIM at
>>> xb_set_page()?
>> Because of dependency shown below.
>>
>> leak_balloon()
>>    xb_set_page()
>>      xb_preload(GFP_KERNEL)
>>        kmalloc(GFP_KERNEL)
>>          __alloc_pages_may_oom()
>>            Takes oom_lock
>>            out_of_memory()
>>              blocking_notifier_call_chain()
>>                leak_balloon()
>>                  xb_set_page()
>>                    xb_preload(GFP_KERNEL)
>>                      kmalloc(GFP_KERNEL)
>>                        __alloc_pages_may_oom()
>>                          Fails to take oom_lock and loop forever
>
>__alloc_pages_may_oom() uses mutex_trylock(&oom_lock).

Yes. But this mutex_trylock(&oom_lock) is semantically mutex_lock(&oom_lock)
because __alloc_pages_slowpath() will continue looping until
mutex_trylock(&oom_lock) succeeds (or somebody releases memory).

>
>I think the second __alloc_pages_may_oom() will not continue since the
>first one is in progress.

The second __alloc_pages_may_oom() will be called repeatedly because
__alloc_pages_slowpath() will continue looping (unless somebody releases
memory).

>
>>
>> By the way, is xb_set_page() safe?
>> Sleeping in the kernel with preemption disabled is a bug, isn't it?
>> __radix_tree_preload() returns 0 with preemption disabled upon success.
>> xb_preload() disables preemption if __radix_tree_preload() fails.
>> Then, kmalloc() is called with preemption disabled, isn't it?
>> But xb_set_page() calls xb_preload(GFP_KERNEL) which might sleep with
>> preemption disabled.
>
>Yes, I think that should not be expected, thanks.
>
>I plan to change it like this:
>
>bool xb_preload(gfp_t gfp)
>{
>         if (!this_cpu_read(ida_bitmap)) {
>                 struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
>
>                 if (!bitmap)
>                         return false;
>                 bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
>                 kfree(bitmap);
>         }

Excuse me, but you are allocating per-CPU memory when running CPU might
change at this line? What happens if running CPU has changed at this line?
Will it work even with new CPU's ida_bitmap == NULL ?

>
>         if (__radix_tree_preload(gfp, XB_PRELOAD_SIZE) < 0)
>                 return false;
>
>         return true;
>}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
