Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id AA0F26B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 11:15:56 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so53930878pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:15:56 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id y9si14223054par.131.2015.01.30.08.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 08:15:55 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ000GDU0136JA0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 16:19:51 +0000 (GMT)
Message-id: <54CBAE2E.2030106@samsung.com>
Date: Fri, 30 Jan 2015 19:15:42 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 02/17] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-3-git-send-email-a.ryabinin@samsung.com>
 <20150129151224.4e7947af78605c199763102c@linux-foundation.org>
In-reply-to: <20150129151224.4e7947af78605c199763102c@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andy Lutomirski <luto@amacapital.net>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>

On 01/30/2015 02:12 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:11:46 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> This patch adds arch specific code for kernel address sanitizer.
>>
>> 16TB of virtual addressed used for shadow memory.
>> It's located in range [ffffec0000000000 - fffffc0000000000]
>> between vmemmap and %esp fixup stacks.
>>
>> At early stage we map whole shadow region with zero page.
>> Latter, after pages mapped to direct mapping address range
>> we unmap zero pages from corresponding shadow (see kasan_map_shadow())
>> and allocate and map a real shadow memory reusing vmemmap_populate()
>> function.
>>
>> Also replace __pa with __pa_nodebug before shadow initialized.
>> __pa with CONFIG_DEBUG_VIRTUAL=y make external function call (__phys_addr)
>> __phys_addr is instrumented, so __asan_load could be called before
>> shadow area initialized.
>>
>> ...
>>
>> --- a/lib/Kconfig.kasan
>> +++ b/lib/Kconfig.kasan
>> @@ -5,6 +5,7 @@ if HAVE_ARCH_KASAN
>>  
>>  config KASAN
>>  	bool "AddressSanitizer: runtime memory debugger"
>> +	depends on !MEMORY_HOTPLUG
>>  	help
>>  	  Enables address sanitizer - runtime memory debugger,
>>  	  designed to find out-of-bounds accesses and use-after-free bugs.
> 
> That's a significant restriction.  It has obvious runtime implications.
> It also means that `make allmodconfig' and `make allyesconfig' don't
> enable kasan, so compile coverage will be impacted.
> 
> This wasn't changelogged.  What's the reasoning and what has to be done
> to fix it?
> 

Yes, this is runtime dependency. Hot adding memory won't work.
Since we don't have shadow for hotplugged memory, kernel will crash on the first access to it.
To fix this we need to allocate shadow for new memory.

Perhaps it would be better to have a runtime warning instead of Kconfig dependecy?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
