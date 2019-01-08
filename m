Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0893E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:19:34 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z10so1353266edz.15
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:19:33 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id y18-v6si7052368ejg.267.2019.01.08.01.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 01:19:32 -0800 (PST)
Subject: Re: [PATCH v2 2/2] powerpc: use probe_user_read()
References: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
 <e939991366b784ef13c7afcab51749e3b46327ac.1546932949.git.christophe.leroy@c-s.fr>
 <8a52b522-7b9d-e3d4-9c04-98292db11d85@redhat.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <7317788a-c92d-661a-a405-b726d8054bad@c-s.fr>
Date: Tue, 8 Jan 2019 10:19:31 +0100
MIME-Version: 1.0
In-Reply-To: <8a52b522-7b9d-e3d4-9c04-98292db11d85@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



Le 08/01/2019 à 10:04, David Hildenbrand a écrit :
> On 08.01.19 08:37, Christophe Leroy wrote:
>> Instead of opencoding, use probe_user_read() to failessly
>> read a user location.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>> ---
>>   v2: Using probe_user_read() instead of probe_user_address()
>>
>>   arch/powerpc/kernel/process.c   | 12 +-----------
>>   arch/powerpc/mm/fault.c         |  6 +-----
>>   arch/powerpc/perf/callchain.c   | 20 +++-----------------
>>   arch/powerpc/perf/core-book3s.c |  8 +-------
>>   arch/powerpc/sysdev/fsl_pci.c   | 10 ++++------
>>   5 files changed, 10 insertions(+), 46 deletions(-)
>>

[snip]

>> diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
>> index 918be816b097..c8a1b26489f5 100644
>> --- a/arch/powerpc/sysdev/fsl_pci.c
>> +++ b/arch/powerpc/sysdev/fsl_pci.c
>> @@ -1068,13 +1068,11 @@ int fsl_pci_mcheck_exception(struct pt_regs *regs)
>>   	addr += mfspr(SPRN_MCAR);
>>   
>>   	if (is_in_pci_mem_space(addr)) {
>> -		if (user_mode(regs)) {
>> -			pagefault_disable();
>> -			ret = get_user(inst, (__u32 __user *)regs->nip);
>> -			pagefault_enable();
>> -		} else {
>> +		if (user_mode(regs))
>> +			ret = probe_user_read(&inst, (void __user *)regs->nip,
>> +					      sizeof(inst));
> 
> What about also adding probe_user_address ?

Michael doesn't like it, see https://patchwork.ozlabs.org/patch/1007117/

Christophe

> 
>> +		else
>>   			ret = probe_kernel_address((void *)regs->nip, inst);
>> -		}
>>   
>>   		if (!ret && mcheck_handle_load(regs, inst)) {
>>   			regs->nip += 4;
>>
> 
> 
