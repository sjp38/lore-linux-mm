Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 543406B0038
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 14:37:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m184so250288514qkb.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 11:37:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r24si14734180qkr.134.2016.08.22.11.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 11:37:09 -0700 (PDT)
Subject: Re: [PATCH v4] powerpc: Do not make the entire heap executable
References: <20160810130030.5268-1-dvlasenk@redhat.com>
 <874m6ejf81.fsf@linux.vnet.ibm.com>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <47a2e87e-5299-a009-8a65-5171b33967a1@redhat.com>
Date: Mon, 22 Aug 2016 20:37:05 +0200
MIME-Version: 1.0
In-Reply-To: <874m6ejf81.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Kees Cook <keescook@chromium.org>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/21/2016 05:47 PM, Aneesh Kumar K.V wrote:
> Denys Vlasenko <dvlasenk@redhat.com> writes:
>
>> On 32-bit powerpc the ELF PLT sections of binaries (built with --bss-plt,
>> or with a toolchain which defaults to it) look like this:
>>
>>   [17] .sbss             NOBITS          0002aff8 01aff8 000014 00  WA  0   0  4
>>   [18] .plt              NOBITS          0002b00c 01aff8 000084 00 WAX  0   0  4
>>   [19] .bss              NOBITS          0002b090 01aff8 0000a4 00  WA  0   0  4
>>
>> Which results in an ELF load header:
>>
>>   Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
>>   LOAD           0x019c70 0x00029c70 0x00029c70 0x01388 0x014c4 RWE 0x10000
>>
>> This is all correct, the load region containing the PLT is marked as
>> executable. Note that the PLT starts at 0002b00c but the file mapping ends at
>> 0002aff8, so the PLT falls in the 0 fill section described by the load header,
>> and after a page boundary.
>>
>> Unfortunately the generic ELF loader ignores the X bit in the load headers
>> when it creates the 0 filled non-file backed mappings. It assumes all of these
>> mappings are RW BSS sections, which is not the case for PPC.
>>
>> gcc/ld has an option (--secure-plt) to not do this, this is said to incur
>> a small performance penalty.
>>
>> Currently, to support 32-bit binaries with PLT in BSS kernel maps *entire
>> brk area* with executable rights for all binaries, even --secure-plt ones.
>
>
> Is this going to break any application ? I am asking because you
> mentioned the patch is lightly tested.

I booted powerpc64 machine with RHEL7 installation,
it did not catch fire.

> x86 do have a
>
> #define VM_DATA_DEFAULT_FLAGS \
> 	(((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0 ) | \
> 	 VM_READ | VM_WRITE | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
>
> ie, it can force a read implies exec mode. Do we need that ?

powerpc64 never had that. 32-bit mode may need it, since before
this patch all 32-bit tasks were unconditionally getting
VM_DATA_DEFAULT_FLAGS with VM_EXEC bit.

I'll send an updated patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
