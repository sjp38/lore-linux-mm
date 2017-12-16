Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D87F46B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 05:10:32 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id i7so1978788plt.3
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:10:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y5si5874863pgy.156.2017.12.16.02.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 02:10:31 -0800 (PST)
Message-ID: <5A34F193.5040700@intel.com>
Date: Sat, 16 Dec 2017 18:12:35 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com> <1513079759-14169-4-git-send-email-wei.w.wang@intel.com> <20171215184256.GA27160@bombadil.infradead.org>
In-Reply-To: <20171215184256.GA27160@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/16/2017 02:42 AM, Matthew Wilcox wrote:
> On Tue, Dec 12, 2017 at 07:55:55PM +0800, Wei Wang wrote:
>> +int xb_preload_and_set_bit(struct xb *xb, unsigned long bit, gfp_t gfp);
> I'm struggling to understand when one would use this.  The xb_ API
> requires you to handle your own locking.  But specifying GFP flags
> here implies you can sleep.  So ... um ... there's no locking?

In the regular use cases, people would do xb_preload() before taking the 
lock, and the xb_set/clear within the lock.

In the virtio-balloon usage, we have a large number of bits to set with 
the balloon_lock being held (we're not unlocking for each bit), so we 
used the above wrapper to do preload and set within the balloon_lock, 
and passed in GFP_NOWAIT to avoid sleeping. Probably we can change to 
put this wrapper implementation to virtio-balloon, since it would not be 
useful for the regular cases.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
