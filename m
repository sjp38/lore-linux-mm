Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86DDE6B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 23:15:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u144so1203296pgb.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 20:15:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g1si5121850plp.633.2017.10.10.20.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 20:14:59 -0700 (PDT)
Message-ID: <59DD8D27.5010601@intel.com>
Date: Wed, 11 Oct 2017 11:16:55 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <201710102209.DBE39528.MtFLOJQSFOFVOH@I-love.SAKURA.ne.jp> <59DD7932.3070106@intel.com> <201710110226.v9B2QGdx019779@www262.sakura.ne.jp>
In-Reply-To: <201710110226.v9B2QGdx019779@www262.sakura.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mst@redhat.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 10/11/2017 10:26 AM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> On 10/10/2017 09:09 PM, Tetsuo Handa wrote:
>>> Wei Wang wrote:
>>>>> And even if we could remove balloon_lock, you still cannot use
>>>>> __GFP_DIRECT_RECLAIM at xb_set_page(). I think you will need to use
>>>>> "whether it is safe to wait" flag from
>>>>> "[PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()" .
>>>> Without the lock being held, why couldn't we use __GFP_DIRECT_RECLAIM at
>>>> xb_set_page()?
>>> Because of dependency shown below.
>>>
>>> leak_balloon()
>>>    xb_set_page()
>>>      xb_preload(GFP_KERNEL)
>>>        kmalloc(GFP_KERNEL)
>>>          __alloc_pages_may_oom()
>>>            Takes oom_lock
>>>            out_of_memory()
>>>              blocking_notifier_call_chain()
>>>                leak_balloon()
>>>                  xb_set_page()
>>>                    xb_preload(GFP_KERNEL)
>>>                      kmalloc(GFP_KERNEL)
>>>                        __alloc_pages_may_oom()
>>>                          Fails to take oom_lock and loop forever
>> __alloc_pages_may_oom() uses mutex_trylock(&oom_lock).
> Yes. But this mutex_trylock(&oom_lock) is semantically mutex_lock(&oom_lock)
> because __alloc_pages_slowpath() will continue looping until
> mutex_trylock(&oom_lock) succeeds (or somebody releases memory).
>
>> I think the second __alloc_pages_may_oom() will not continue since the
>> first one is in progress.
> The second __alloc_pages_may_oom() will be called repeatedly because
> __alloc_pages_slowpath() will continue looping (unless somebody releases
> memory).
>

OK, I see, thanks. So, the point is that the OOM code path should not
have memory allocation, and the
old leak_balloon (without the F_SG feature) don't need xb_preload(). I
think one solution would be to let
the OOM uses the old leak_balloon() code path, and we can add one more
parameter to leak_balloon
to control that:

leak_balloon(struct virtio_balloon *vb, size_t num, bool oom)



>>> By the way, is xb_set_page() safe?
>>> Sleeping in the kernel with preemption disabled is a bug, isn't it?
>>> __radix_tree_preload() returns 0 with preemption disabled upon success.
>>> xb_preload() disables preemption if __radix_tree_preload() fails.
>>> Then, kmalloc() is called with preemption disabled, isn't it?
>>> But xb_set_page() calls xb_preload(GFP_KERNEL) which might sleep with
>>> preemption disabled.
>> Yes, I think that should not be expected, thanks.
>>
>> I plan to change it like this:
>>
>> bool xb_preload(gfp_t gfp)
>> {
>>         if (!this_cpu_read(ida_bitmap)) {
>>                 struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
>>
>>                 if (!bitmap)
>>                         return false;
>>                 bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
>>                 kfree(bitmap);
>>         }
> Excuse me, but you are allocating per-CPU memory when running CPU might
> change at this line? What happens if running CPU has changed at this line?
> Will it work even with new CPU's ida_bitmap == NULL ?
>


Yes, it will be detected in xb_set_bit(): when ida_bitmap = NULL on the
new CPU, xb_set_bit() will
return -EAGAIN to the caller, and the caller should restart from
xb_preload().

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
