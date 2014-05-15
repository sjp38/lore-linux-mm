Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 321CF6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 23:46:25 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id la4so3764897vcb.27
        for <linux-mm@kvack.org>; Wed, 14 May 2014 20:46:25 -0700 (PDT)
Received: from mail-ve0-x22d.google.com (mail-ve0-x22d.google.com [2607:f8b0:400c:c01::22d])
        by mx.google.com with ESMTPS id ui2si687463vdc.118.2014.05.14.20.46.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 20:46:24 -0700 (PDT)
Received: by mail-ve0-f173.google.com with SMTP id pa12so593427veb.4
        for <linux-mm@kvack.org>; Wed, 14 May 2014 20:46:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAL_JsqLncBaJ=uceovX80U1JPU8SW3KWKXW3PiVR8Kbnykcvpg@mail.gmail.com>
References: <1400055532-13134-1-git-send-email-superlibj8301@gmail.com>
	<1400055532-13134-2-git-send-email-superlibj8301@gmail.com>
	<CAL_JsqLncBaJ=uceovX80U1JPU8SW3KWKXW3PiVR8Kbnykcvpg@mail.gmail.com>
Date: Thu, 15 May 2014 11:46:24 +0800
Message-ID: <CAHPCO9HALgpevhYVYQ5yS8JR66CBD5j=7uk5QQ-4n9ftsA2KTQ@mail.gmail.com>
Subject: Re: [PATCHv2 1/2] mm/vmalloc: Add IO mapping space reused interface support.
From: Richard Lee <superlibj8301@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robherring2@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@arndb.de>, Laura Abbott <lauraa@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, d.hatayama@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nicolas Pitre <nico@fluxnic.net>

On Thu, May 15, 2014 at 12:06 AM, Rob Herring <robherring2@gmail.com> wrote:
> Adding Nico...
>
> On Wed, May 14, 2014 at 3:18 AM, Richard Lee <superlibj8301@gmail.com> wrote:
>> For the IO mapping, the same physical address space maybe
>> mapped more than one time, for example, in some SoCs:
>>   - 0x20001000 ~ 0x20001400 --> 1KB for Dev1
>>   - 0x20001400 ~ 0x20001800 --> 1KB for Dev2
>>   and the page size is 4KB.
>>
>> Then both Dev1 and Dev2 will do ioremap operations, and the IO
>> vmalloc area's virtual address will be aligned down to 4KB, and
>> the size will be aligned up to 4KB. That's to say, only one
>> 4KB size's vmalloc area could contain Dev1 and Dev2 IO mapping area
>> at the same time.
>>
>> For this case, we can ioremap only one time, and the later ioremap
>> operation will just return the exist vmalloc area.
>
> We already have similar reuse tracking for the static mappings on ARM.
> I'm wondering if either that can be reused for ioremap as well or this
> can replace the static mapping tracking. It seems silly to have 2
> lists to search for finding an existing mapping.
>

Yes, it is.

Maybe there is one way to reuse the ARM's static mapping tracking, or one
new global way to replace it.



> But there is a fundamental problem with your approach. You do not and
> cannot check the memory type of the mapping. If you look at the static
> mapping code, it only reuses mappings if the memory type match. While
> having aliases with different memory types is bad on ARMv6+, I assume
> there are some cases that do that given the static mapping code
> handles that case. We would at least want to detect and warn if we
> didn't want to allow different attributes rather than just return a
> mapping with whatever attributes the first mapping used.
>

You are right, maybe an alternative is defining one call back for each
individual
ARCH or other ways.


Thanks very much for you comments, they are very important for me.

BRs,
Richard Lee


> Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
