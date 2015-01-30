Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6B56B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 11:04:48 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so53804038pab.9
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:04:48 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id pv10si14081477pdb.223.2015.01.30.08.04.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 08:04:47 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIZ0022OZILZCA0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 16:08:46 +0000 (GMT)
Message-id: <54CBAB92.6090108@samsung.com>
Date: Fri, 30 Jan 2015 19:04:34 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 01/17] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-2-git-send-email-a.ryabinin@samsung.com>
 <20150129151213.09d1f9e0a01490712d0eb071@linux-foundation.org>
In-reply-to: <20150129151213.09d1f9e0a01490712d0eb071@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On 01/30/2015 02:12 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:11:45 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
>> fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
>>
>> KASAN uses compile-time instrumentation for checking every memory access,
>> therefore GCC >= v4.9.2 required.
>>
>> ...
>>
>> Based on work by Andrey Konovalov <adech.fo@gmail.com>
> 
> Can we obtain Andrey's signed-off-by: please?
>  

I'll ask.

...

>> +static __always_inline bool memory_is_poisoned_1(unsigned long addr)
> 
> What's with all the __always_inline in this file?  When I remove them
> all, kasan.o .text falls from 8294 bytes down to 4543 bytes.  That's
> massive, and quite possibly faster.
> 
> If there's some magical functional reason for this then can we please
> get a nice prominent comment into this code apologetically explaining
> it?
> 

The main reason is performance. __always_inline especially needed for check_memory_region()
and memory_is_poisoned() to optimize away switch in memory_is_poisoned():

	if (__builtin_constant_p(size)) {
		switch (size) {
		case 1:
			return memory_is_poisoned_1(addr);
		case 2:
			return memory_is_poisoned_2(addr);
		case 4:
			return memory_is_poisoned_4(addr);
		case 8:
			return memory_is_poisoned_8(addr);
		case 16:
			return memory_is_poisoned_16(addr);
		default:
			BUILD_BUG();
		}
	}

Always inlining memory_is_poisoned_x() gives additionally about 7%-10%.

According to my simple testing __always_inline gives about 20% versus
not inlined version of kasan.c


...

>> +
>> +void __asan_loadN(unsigned long addr, size_t size)
>> +{
>> +	check_memory_region(addr, size, false);
>> +}
>> +EXPORT_SYMBOL(__asan_loadN);
>> +
>> +__attribute__((alias("__asan_loadN")))
> 
> Maybe we need a __alias.  Like __packed and various other helpers.
> 

Ok.

....

>> +
>> +static __always_inline void kasan_report(unsigned long addr,
>> +					size_t size,
>> +					bool is_write)
> 
> Again, why the inline?  This is presumably not a hotpath and
> kasan_report has sixish call sites.
> 

The reason of __always_inline here is to get correct _RET_IP_.
I could pass it from above and drop always inline here.

> 
>> +{
>> +	struct access_info info;
>> +
>> +	if (likely(!kasan_enabled()))
>> +		return;
>> +
>> +	info.access_addr = addr;
>> +	info.access_size = size;
>> +	info.is_write = is_write;
>> +	info.ip = _RET_IP_;
>> +	kasan_report_error(&info);
>> +}
>>
...

>> +
>> +static void print_address_description(struct access_info *info)
>> +{
>> +	dump_stack();
>> +}
> 
> dump_stack() uses KERN_INFO but the callers or
> print_address_description() use KERN_ERR.  This means that at some
> settings of `dmesg -n', the kasan output will have large missing
> chunks.
> 
> Please test this and deide how bad it is.  A proper fix will be
> somewhat messy (new_dump_stack(KERN_ERR)).
> 

This new_dump_stack() could be useful in other places.
E.g. object_err()/slab_err() in SLUB also use pr_err() + dump_stack() combination.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
