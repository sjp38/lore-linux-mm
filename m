Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 67DAD6B0037
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:37:50 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8539581pab.4
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 22:37:50 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id uj6si30699440pab.63.2014.09.10.22.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 10 Sep 2014 22:37:49 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBQ00E892FOY350@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 11 Sep 2014 06:40:36 +0100 (BST)
Message-id: <5411339E.8080007@samsung.com>
Date: Thu, 11 Sep 2014 09:31:10 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
 <54111E99.7080309@zytor.com>
In-reply-to: <54111E99.7080309@zytor.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 09/11/2014 08:01 AM, H. Peter Anvin wrote:
> On 09/10/2014 07:31 AM, Andrey Ryabinin wrote:
>> This patch add arch specific code for kernel address sanitizer.
>>
>> 16TB of virtual addressed used for shadow memory.
>> It's located in range [0xffff800000000000 - 0xffff900000000000]
>> Therefore PAGE_OFFSET has to be changed from 0xffff880000000000
>> to 0xffff900000000000.
> 
> NAK on this.
> 
> 0xffff880000000000 is the lowest usable address because we have agreed
> to leave 0xffff800000000000-0xffff880000000000 for the hypervisor or
> other non-OS uses.
> 
> Bumping PAGE_OFFSET seems needlessly messy, why not just designate a
> zone higher up in memory?
> 

I already answered to Dave why I choose to place shadow bellow PAGE_OFFSET (answer copied bellow).
In short - yes, shadow could be higher. But for some sort of kernel bugs we could have confusing oopses in kasan kernel.

On 09/11/2014 12:30 AM, Andrey Ryabinin wrote:
> 2014-09-10 19:46 GMT+04:00 Dave Hansen <dave.hansen@intel.com>:
>>
>> Is there a reason this has to be _below_ the linear map?  Couldn't we
>> just carve some space out of the vmalloc() area for the kasan area?
>>
>
> Yes, there is a reason for this. For inline instrumentation we need to
> catch access to userspace without any additional check.
> This means that we need shadow of 1 << 61 bytes and we don't have so
> many addresses available. However, we could use
> hole between userspace and kernelspace for that. For any address
> between [0 - 0xffff800000000000], shadow address will be
> in this hole, so checking shadow value will produce general protection
> fault (GPF). We may even try handle GPF in a special way
> and print more user-friendly report (this will be under CONFIG_KASAN of course).
>
> But now I realized that we even if we put shadow in vmalloc, shadow
> addresses  corresponding to userspace addresses
> still will be in between userspace - kernelspace, so we also will get GPF.
> There is the only problem I see now in such approach. Lets consider
> that because of some bug in kernel we are trying to access
> memory slightly bellow 0xffff800000000000. In this case kasan will try
> to check some shadow which in fact is not a shadow byte at all.
> It's not a big deal though, kernel will crash anyway. In only means
> that debugging of such problems could be a little more complex
> than without kasan.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
