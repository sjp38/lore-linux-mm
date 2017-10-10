Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 744826B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 09:10:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a8so8726411pfc.6
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 06:10:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t23si6735312ioe.229.2017.10.10.06.10.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 06:10:42 -0700 (PDT)
Subject: Re: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1506744354-20979-4-git-send-email-wei.w.wang@intel.com>
	<20171009181612-mutt-send-email-mst@kernel.org>
	<59DC76BA.7070202@intel.com>
	<201710102008.FIG57851.QFJLMtVOFOHFOS@I-love.SAKURA.ne.jp>
	<59DCBDE9.4050404@intel.com>
In-Reply-To: <59DCBDE9.4050404@intel.com>
Message-Id: <201710102209.DBE39528.MtFLOJQSFOFVOH@I-love.SAKURA.ne.jp>
Date: Tue, 10 Oct 2017 22:09:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, mst@redhat.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Wei Wang wrote:
> > And even if we could remove balloon_lock, you still cannot use
> > __GFP_DIRECT_RECLAIM at xb_set_page(). I think you will need to use
> > "whether it is safe to wait" flag from
> > "[PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()" .
> 
> Without the lock being held, why couldn't we use __GFP_DIRECT_RECLAIM at 
> xb_set_page()?

Because of dependency shown below.

leak_balloon()
  xb_set_page()
    xb_preload(GFP_KERNEL)
      kmalloc(GFP_KERNEL)
        __alloc_pages_may_oom()
          Takes oom_lock
          out_of_memory()
            blocking_notifier_call_chain()
              leak_balloon()
                xb_set_page()
                  xb_preload(GFP_KERNEL)
                    kmalloc(GFP_KERNEL)
                      __alloc_pages_may_oom()
                        Fails to take oom_lock and loop forever

By the way, is xb_set_page() safe?
Sleeping in the kernel with preemption disabled is a bug, isn't it?
__radix_tree_preload() returns 0 with preemption disabled upon success.
xb_preload() disables preemption if __radix_tree_preload() fails.
Then, kmalloc() is called with preemption disabled, isn't it?
But xb_set_page() calls xb_preload(GFP_KERNEL) which might sleep with
preemption disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
