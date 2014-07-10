Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 922026B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:18:04 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so10875219pab.6
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:18:04 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id bo1si48413018pbc.7.2014.07.10.05.18.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Jul 2014 05:18:03 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8H00GSVWTKFU30@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Jul 2014 13:17:44 +0100 (BST)
Message-id: <53BE8333.6060404@samsung.com>
Date: Thu, 10 Jul 2014 16:12:35 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer
 infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
 <53BDA568.5030607@intel.com>
In-reply-to: <53BDA568.5030607@intel.com>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/10/14 00:26, Dave Hansen wrote:
> On 07/09/2014 04:29 AM, Andrey Ryabinin wrote:
>> Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
>> mapping with a scale and offset to translate a memory address to its corresponding
>> shadow address.
>>
>> Here is function to translate address to corresponding shadow address:
>>
>>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>>      {
>>                 return ((addr - PAGE_OFFSET) >> KASAN_SHADOW_SCALE_SHIFT)
>>                              + kasan_shadow_start;
>>      }
> 
> How does this interact with vmalloc() addresses or those from a kmap()?
> 

It's used only for lowmem:

static inline bool addr_is_in_mem(unsigned long addr)
{
	return likely(addr >= PAGE_OFFSET && addr < (unsigned long)high_memory);
}



static __always_inline void check_memory_region(unsigned long addr,
						size_t size, bool write)
{

	....
	if (!addr_is_in_mem(addr))
		return;
	// check shadow here

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
