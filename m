Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44E686B025E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 10:06:04 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so104321608pad.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 07:06:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id bd2si42688974pab.107.2016.09.08.07.06.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 07:06:02 -0700 (PDT)
Subject: Re: [PATCH] Fix region lost in /proc/self/smaps
References: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
 <57D04192.5070704@intel.com>
 <8b800d72-9b28-237c-47a6-604d98a40315@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D1703E.4070504@intel.com>
Date: Thu, 8 Sep 2016 07:05:50 -0700
MIME-Version: 1.0
In-Reply-To: <8b800d72-9b28-237c-47a6-604d98a40315@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <guangrong.xiao@linux.intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com
Cc: gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 09/07/2016 08:36 PM, Xiao Guangrong wrote:>> The user will see two
VMAs in their output:
>>
>>     A: 0x1000->0x2000
>>     C: 0x1000->0x3000
>>
>> Will it confuse them to see the same virtual address range twice?  Or is
>> there something preventing that happening that I'm missing?
>>
> 
> You are right. Nothing can prevent it.
> 
> However, it is not easy to handle the case that the new VMA overlays
> with the old VMA
> already got by userspace. I think we have some choices:
> 1: One way is completely skipping the new VMA region as current kernel
> code does but i
>    do not think this is good as the later VMAs will be dropped.
> 
> 2: show the un-overlayed portion of new VMA. In your case, we just show
> the region
>    (0x2000 -> 0x3000), however, it can not work well if the VMA is a new
> created
>    region with different attributions.
> 
> 3: completely show the new VMA as this patch does.
> 
> Which one do you prefer?

I'd be willing to bet that #3 will break *somebody's* tooling.
Addresses going backwards is certainly screwy.  Imagine somebody using
smaps to search for address holes and doing hole_size=0x1000-0x2000.

#1 can lies about there being no mapping in place where there there may
have _always_ been a mapping and is very similar to the bug you were
originally fixing.  I think that throws it out.

#2 is our best bet, I think.  It's unfortunately also the most code.
It's also a bit of a fib because it'll show a mapping that never
actually existed, but I think this is OK.  I'm not sure what the
downside is that you're referring to, though.  Can you explain?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
