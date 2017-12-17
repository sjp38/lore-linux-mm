Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6CC56B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 00:22:23 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id o17so3141365pli.7
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 21:22:23 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b9si7463569pli.725.2017.12.16.21.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 21:22:22 -0800 (PST)
Message-ID: <5A35FF89.8040500@intel.com>
Date: Sun, 17 Dec 2017 13:24:25 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com>	<1513079759-14169-4-git-send-email-wei.w.wang@intel.com>	<20171215184256.GA27160@bombadil.infradead.org>	<5A34F193.5040700@intel.com> <201712162028.FEB87079.FOJFMQHVOSLtFO@I-love.SAKURA.ne.jp>
In-Reply-To: <201712162028.FEB87079.FOJFMQHVOSLtFO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/16/2017 07:28 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> On 12/16/2017 02:42 AM, Matthew Wilcox wrote:
>>> On Tue, Dec 12, 2017 at 07:55:55PM +0800, Wei Wang wrote:
>>>> +int xb_preload_and_set_bit(struct xb *xb, unsigned long bit, gfp_t gfp);
>>> I'm struggling to understand when one would use this.  The xb_ API
>>> requires you to handle your own locking.  But specifying GFP flags
>>> here implies you can sleep.  So ... um ... there's no locking?
>> In the regular use cases, people would do xb_preload() before taking the
>> lock, and the xb_set/clear within the lock.
>>
>> In the virtio-balloon usage, we have a large number of bits to set with
>> the balloon_lock being held (we're not unlocking for each bit), so we
>> used the above wrapper to do preload and set within the balloon_lock,
>> and passed in GFP_NOWAIT to avoid sleeping. Probably we can change to
>> put this wrapper implementation to virtio-balloon, since it would not be
>> useful for the regular cases.
> GFP_NOWAIT is chosen in order not to try to OOM-kill something, isn't it?

Yes, I think that's right the issue we are discussing here (also 
discussed in the deadlock patch before): Suppose we use a sleep-able 
flag GFP_KERNEL, which gets the caller (fill_balloon or leak_balloon) 
into sleep with balloon_lock being held, and the memory reclaiming from 
GFP_KERNEL would fall into the OOM code path which first invokes the 
oom_notify-->leak_balloon to release some balloon memory, which needs to 
take the balloon_lock that is being held by the task who is sleeping.

So, using GFP_NOWAIT avoids sleeping to get memory through directly 
memory reclaiming, which could fall into that OOM code path that needs 
to take the balloon_lock.


> But passing GFP_NOWAIT means that we can handle allocation failure. There is
> no need to use preload approach when we can handle allocation failure.

I think the reason we need xb_preload is because radix tree insertion 
needs the memory being preallocated already (it couldn't suffer from 
memory failure during the process of inserting, probably because 
handling the failure there isn't easy, Matthew may know the backstory of 
this)

So, I think we can handle the memory failure with xb_preload, which 
stops going into the radix tree APIs, but shouldn't call radix tree APIs 
without the related memory preallocated.

Best,
Wei




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
