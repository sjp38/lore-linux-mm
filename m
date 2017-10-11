Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 978466B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 21:49:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p2so1295199pfk.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 18:49:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p14si9047971pgq.58.2017.10.10.18.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 18:49:54 -0700 (PDT)
Message-ID: <59DD7932.3070106@intel.com>
Date: Wed, 11 Oct 2017 09:51:46 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1506744354-20979-4-git-send-email-wei.w.wang@intel.com>	<20171009181612-mutt-send-email-mst@kernel.org>	<59DC76BA.7070202@intel.com>	<201710102008.FIG57851.QFJLMtVOFOHFOS@I-love.SAKURA.ne.jp>	<59DCBDE9.4050404@intel.com> <201710102209.DBE39528.MtFLOJQSFOFVOH@I-love.SAKURA.ne.jp>
In-Reply-To: <201710102209.DBE39528.MtFLOJQSFOFVOH@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mst@redhat.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 10/10/2017 09:09 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>>> And even if we could remove balloon_lock, you still cannot use
>>> __GFP_DIRECT_RECLAIM at xb_set_page(). I think you will need to use
>>> "whether it is safe to wait" flag from
>>> "[PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()" .
>> Without the lock being held, why couldn't we use __GFP_DIRECT_RECLAIM at
>> xb_set_page()?
> Because of dependency shown below.
>
> leak_balloon()
>    xb_set_page()
>      xb_preload(GFP_KERNEL)
>        kmalloc(GFP_KERNEL)
>          __alloc_pages_may_oom()
>            Takes oom_lock
>            out_of_memory()
>              blocking_notifier_call_chain()
>                leak_balloon()
>                  xb_set_page()
>                    xb_preload(GFP_KERNEL)
>                      kmalloc(GFP_KERNEL)
>                        __alloc_pages_may_oom()
>                          Fails to take oom_lock and loop forever

__alloc_pages_may_oom() uses mutex_trylock(&oom_lock).

I think the second __alloc_pages_may_oom() will not continue since the
first one is in progress.

>
> By the way, is xb_set_page() safe?
> Sleeping in the kernel with preemption disabled is a bug, isn't it?
> __radix_tree_preload() returns 0 with preemption disabled upon success.
> xb_preload() disables preemption if __radix_tree_preload() fails.
> Then, kmalloc() is called with preemption disabled, isn't it?
> But xb_set_page() calls xb_preload(GFP_KERNEL) which might sleep with
> preemption disabled.

Yes, I think that should not be expected, thanks.

I plan to change it like this:

bool xb_preload(gfp_t gfp)
{
         if (!this_cpu_read(ida_bitmap)) {
                 struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);

                 if (!bitmap)
                         return false;
                 bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
                 kfree(bitmap);
         }

         if (__radix_tree_preload(gfp, XB_PRELOAD_SIZE) < 0)
                 return false;

         return true;
}


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
