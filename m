Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51CC26B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 23:41:49 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vp2so75508590pab.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 20:41:49 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z1si37681338pab.287.2016.09.07.20.41.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 20:41:48 -0700 (PDT)
Subject: Re: [PATCH] Fix region lost in /proc/self/smaps
References: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
 <57D04192.5070704@intel.com>
From: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Message-ID: <8b800d72-9b28-237c-47a6-604d98a40315@linux.intel.com>
Date: Thu, 8 Sep 2016 11:36:11 +0800
MIME-Version: 1.0
In-Reply-To: <57D04192.5070704@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com
Cc: gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com



On 09/08/2016 12:34 AM, Dave Hansen wrote:
> On 09/06/2016 11:51 PM, Xiao Guangrong wrote:
>> In order to fix this bug, we make 'file->version' indicate the next VMA
>> we want to handle
>
> This new approach makes it more likely that we'll skip a new VMA that
> gets inserted in between the read()s.  But, I guess that's OK.  We don't
> exactly claim to be giving super up-to-date data at the time of read().

Yes, I completely agree with you. :)

>
> With the old code, was there also a case that we could print out the
> same virtual address range more than once?  It seems like that could
> happen if we had a VMA split between two reads.

Yes.

>
> I think this introduces one oddity: if you have a VMA merge between two
> reads(), you might get the same virtual address range twice in your
> output.  This didn't happen before because we would have just skipped
> over the area that got merged.
>
> Take two example VMAs:
>
> 	vma-A: (0x1000 -> 0x2000)
> 	vma-B: (0x2000 -> 0x3000)
>
> read() #1: prints vma-A, sets m->version=0x2000
>
> Now, merge A/B to make C:
>
> 	vma-C: (0x1000 -> 0x3000)
>
> read() #2: find_vma(m->version=0x2000), returns vma-C, prints vma-C
>
> The user will see two VMAs in their output:
>
> 	A: 0x1000->0x2000
> 	C: 0x1000->0x3000
>
> Will it confuse them to see the same virtual address range twice?  Or is
> there something preventing that happening that I'm missing?
>

You are right. Nothing can prevent it.

However, it is not easy to handle the case that the new VMA overlays with the old VMA
already got by userspace. I think we have some choices:
1: One way is completely skipping the new VMA region as current kernel code does but i
    do not think this is good as the later VMAs will be dropped.

2: show the un-overlayed portion of new VMA. In your case, we just show the region
    (0x2000 -> 0x3000), however, it can not work well if the VMA is a new created
    region with different attributions.

3: completely show the new VMA as this patch does.

Which one do you prefer?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
