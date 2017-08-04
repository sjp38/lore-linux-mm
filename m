Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9D9B2803E9
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 10:01:56 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x3so1354290oia.8
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 07:01:56 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r124si1189082oig.441.2017.08.04.07.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 07:01:55 -0700 (PDT)
Subject: Re: [v5 11/15] arm64/kasan: explicitly zero kasan shadow memory
References: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
 <1501795433-982645-12-git-send-email-pasha.tatashin@oracle.com>
 <CAKv+Gu_V_T56qPS=c3kq73TLFwqpP4YHtggCrjGRmgW1itq3pQ@mail.gmail.com>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <85cce150-74b7-c89b-678c-8fdd0be6c066@oracle.com>
Date: Fri, 4 Aug 2017 10:01:15 -0400
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_V_T56qPS=c3kq73TLFwqpP4YHtggCrjGRmgW1itq3pQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, willy@infradead.org, mhocko@kernel.org

Hi Ard,

Thank you very much for reviewing this. I will fix the bug you found in 
the next iteration.
>> +zero_vemmap_populated_memory(void)
> 
> Typo here: vemmap -> vmemmap

Yeap, will rename here, and in Intel variant.

> 
>> +{
>> +       struct memblock_region *reg;
>> +       u64 start, end;
>> +
>> +       for_each_memblock(memory, reg) {
>> +               start = __phys_to_virt(reg->base);
>> +               end = __phys_to_virt(reg->base + reg->size);
>> +
>> +               if (start >= end)
> How would this ever be true? And why is it a stop condition?

Yes this is a stop condition. Also look at the way kasan allocates its 
shadow memory in this file kasan_init():

187  	for_each_memblock(memory, reg) {
188  		void *start = (void *)__phys_to_virt(reg->base);
189  		void *end = (void *)__phys_to_virt(reg->base + reg->size);
190
191  		if (start >= end)
192  			break;
...
200  		vmemmap_populate(...)

>> +
> 
> Are you missing a couple of kasan_mem_to_shadow() calls here? I can't
> believe your intention is to wipe all of DRAM.

True. Thank you for catching this bug. I have not really tested on arm, 
only compiled for sanity checking. Need to figure out how to configure 
qemu to run most generic arm code. I tested on x86 and sparc both real 
and qemu hardware.

> 
> KASAN uses vmemmap_populate as a convenience: kasan has nothing to do
> with vmemmap, but the function already existed and happened to do what
> KASAN requires.
> 
> Given that that will no longer be the case, it would be far better to
> stop using vmemmap_populate altogether, and clone it into a KASAN
> specific version (with an appropriate name) with the zeroing folded
> into it.

I agree, but this would be outside of the scope of this project.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
