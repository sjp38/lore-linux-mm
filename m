Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 82EE06B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 12:35:18 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so499020pdb.25
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 09:35:18 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id fe10si1277968pad.167.2014.10.01.09.35.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 01 Oct 2014 09:35:17 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NCR00A55Y7IBC70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 01 Oct 2014 17:38:06 +0100 (BST)
Message-id: <542C2BA2.2020206@samsung.com>
Date: Wed, 01 Oct 2014 20:28:18 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
 <54111E99.7080309@zytor.com> <5411339E.8080007@samsung.com>
 <542C1E5A.4000202@zytor.com>
In-reply-to: <542C1E5A.4000202@zytor.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 10/01/2014 07:31 PM, H. Peter Anvin wrote:
> On 09/10/2014 10:31 PM, Andrey Ryabinin wrote:
>> On 09/11/2014 08:01 AM, H. Peter Anvin wrote:
>>> On 09/10/2014 07:31 AM, Andrey Ryabinin wrote:
>>>> This patch add arch specific code for kernel address sanitizer.
>>>>
>>>> 16TB of virtual addressed used for shadow memory.
>>>> It's located in range [0xffff800000000000 - 0xffff900000000000]
>>>> Therefore PAGE_OFFSET has to be changed from 0xffff880000000000
>>>> to 0xffff900000000000.
>>>
>>> NAK on this.
>>>
>>> 0xffff880000000000 is the lowest usable address because we have agreed
>>> to leave 0xffff800000000000-0xffff880000000000 for the hypervisor or
>>> other non-OS uses.
>>>
>>> Bumping PAGE_OFFSET seems needlessly messy, why not just designate a
>>> zone higher up in memory?
>>>
>>
>> I already answered to Dave why I choose to place shadow bellow PAGE_OFFSET (answer copied bellow).
>> In short - yes, shadow could be higher. But for some sort of kernel bugs we could have confusing oopses in kasan kernel.
>>
> 
> Confusing how?  I presume you are talking about something trying to
> touch a non-canonical address, which is usually a very blatant type of bug.
> 
> 	-hpa
> 

For those kinds of bugs we normally get general protection fault.

With inline instrumented kasan we could get either general protection fault,
or unhandled page fault on "kasan_mem_to_shadow(non_canonical_address)" address.
I assume that the last case could be a bit confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
