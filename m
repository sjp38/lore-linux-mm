Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31E296B0069
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 07:31:11 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g128so7981449itb.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 04:31:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b125si6359960ioa.188.2017.10.09.04.31.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 04:31:10 -0700 (PDT)
Subject: Re: [PATCH v16 1/5] lib/xbitmap: Introduce xbitmap
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-2-git-send-email-wei.w.wang@intel.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <3b575060-e30b-1afe-96a8-6a9f732d5528@I-love.SAKURA.ne.jp>
Date: Mon, 9 Oct 2017 20:30:00 +0900
MIME-Version: 1.0
In-Reply-To: <1506744354-20979-2-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 2017/09/30 13:05, Wei Wang wrote:
>  /**
> + *  xb_preload - preload for xb_set_bit()
> + *  @gfp_mask: allocation mask to use for preloading
> + *
> + * Preallocate memory to use for the next call to xb_set_bit(). This function
> + * returns with preemption disabled. It will be enabled by xb_preload_end().
> + */
> +void xb_preload(gfp_t gfp)
> +{
> +	if (__radix_tree_preload(gfp, XB_PRELOAD_SIZE) < 0)
> +		preempt_disable();
> +
> +	if (!this_cpu_read(ida_bitmap)) {
> +		struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
> +
> +		if (!bitmap)
> +			return;
> +		bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
> +		kfree(bitmap);
> +	}
> +}

I'm not sure whether this function is safe.

__radix_tree_preload() returns 0 with preemption disabled upon success.
xb_preload() disables preemption if __radix_tree_preload() fails.
Then, kmalloc() is called with preemption disabled, isn't it?
But xb_set_page() calls xb_preload(GFP_KERNEL) which might sleep...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
