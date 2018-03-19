Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2736B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 07:19:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w14-v6so2499717plp.13
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 04:19:43 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id o1-v6si11945196plk.138.2018.03.19.04.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Mar 2018 04:19:42 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 3/5] powerpc/mm/32: Use page_is_ram to check for RAM
In-Reply-To: <874llcha6p.fsf@concordia.ellerman.id.au>
References: <20180222121516.23415-1-j.neuschaefer@gmx.net> <20180222121516.23415-4-j.neuschaefer@gmx.net> <874llcha6p.fsf@concordia.ellerman.id.au>
Date: Mon, 19 Mar 2018 22:19:32 +1100
Message-ID: <87y3iofh2z.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Joel Stanley <joel@jms.id.au>, Guenter Roeck <linux@roeck-us.net>

Michael Ellerman <mpe@ellerman.id.au> writes:
> Jonathan Neusch=C3=A4fer <j.neuschaefer@gmx.net> writes:
>
>> Signed-off-by: Jonathan Neusch=C3=A4fer <j.neuschaefer@gmx.net>
>> ---
>>  arch/powerpc/mm/pgtable_32.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
>> index d35d9ad3c1cd..d54e1a9c1c99 100644
>> --- a/arch/powerpc/mm/pgtable_32.c
>> +++ b/arch/powerpc/mm/pgtable_32.c
>> @@ -145,9 +145,8 @@ __ioremap_caller(phys_addr_t addr, unsigned long siz=
e, unsigned long flags,
>>  #ifndef CONFIG_CRASH_DUMP
>>  	/*
>>  	 * Don't allow anybody to remap normal RAM that we're using.
>> -	 * mem_init() sets high_memory so only do the check after that.
>>  	 */
>> -	if (slab_is_available() && (p < virt_to_phys(high_memory)) &&
>> +	if (page_is_ram(__phys_to_pfn(p)) &&
>>  	    !(__allow_ioremap_reserved && memblock_is_region_reserved(p, size)=
)) {
>>  		printk("__ioremap(): phys addr 0x%llx is RAM lr %ps\n",
>>  		       (unsigned long long)p, __builtin_return_address(0));
>
>
> This is killing my p5020ds (Freescale e5500) unfortunately:

Duh, I should actually read the patch :)

This is a 32-bit system with 4G of RAM, so not all of RAM is mapped,
some of it is highem which is why removing the test against high_memory
above breaks it.

So I need the high_memory test on this system.

I'm not clear why it was a problem for you on the Wii, do you even build
the Wii kernel with HIGHMEM enabled?

cheers
