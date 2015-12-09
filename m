Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 065546B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:53:28 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so30975247pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:53:27 -0800 (PST)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.14])
        by mx.google.com with ESMTPS id s20si13157798pfa.146.2015.12.09.06.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 06:53:27 -0800 (PST)
Message-ID: <56684062.9090505@sigmadesigns.com>
Date: Wed, 9 Dec 2015 15:53:22 +0100
From: Sebastian Frias <sebastian_frias@sigmadesigns.com>
MIME-Version: 1.0
Subject: Re: m(un)map kmalloc buffers to userspace
References: <5667128B.3080704@sigmadesigns.com> <20151209135544.GE30907@dhcp22.suse.cz> <566835B6.9010605@sigmadesigns.com> <20151209143207.GF30907@dhcp22.suse.cz>
In-Reply-To: <20151209143207.GF30907@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2015 03:32 PM, Michal Hocko wrote:
> On Wed 09-12-15 15:07:50, Marc Gonzalez wrote:
>> On 09/12/2015 14:55, Michal Hocko wrote:
>>> On Tue 08-12-15 18:25:31, Sebastian Frias wrote:
>>>> Hi,
>>>>
>>>> We are porting a driver from Linux 3.4.39+ to 4.1.13+, CPU is Cortex-A9.
>>>>
>>>> The driver maps kmalloc'ed memory to user space.
>>>
>>> This sounds like a terrible idea to me. Why don't you simply use the
>>> page allocator directly? Try to imagine what would happen if you mmaped
>>> a kmalloc with a size which is not page aligned? mmaped memory uses
>>> whole page granularity.
>>
>> According to the source code, this kernel module calls
>>
>>    kmalloc(1 << 17, GFP_KERNEL | __GFP_REPEAT);
>
> So I guess you are mapping with 32pages granularity? If this is really
> needed for internal usage you can use highorder page and map its
> subpages directly.
>
>> I suppose kmalloc() would return page-aligned memory?
>
> I do not think there is any guarantee like that. AFAIK you only get
> guarantee for the natural word alignment. Slab allocator is allowed
> to use larger allocation and put its metadata or whatever before the
> returned pointer.
>

Thanks for your answer.
Do you have any suggestions regarding the rest of the questions? 
(copy/pasted below for convenience)

2) Now that VM_RESERVED was removed, is there another recommended flag 
to replace it for the purposes above?
3) Since it was working before, we suppose that something that was 
previously done by default on the kernel it is not done anymore, could 
that be a remap_pfn_range during mmap or kmalloc?
4) We tried using remap_pfn_range inside mmap and while it seems to 
work, we still get occasional crashes due to corrupted memory (in this 
case the behaviour is the same between 4.1 and 3.4 when using the same 
modified driver), are we missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
