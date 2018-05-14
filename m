Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D84986B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:47:54 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y62-v6so15576488qkb.15
        for <linux-mm@kvack.org>; Mon, 14 May 2018 07:47:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l14-v6si1165639qvh.195.2018.05.14.07.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 07:47:53 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4EEiI37046766
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:47:53 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hyc97gsna-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:47:53 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 14 May 2018 15:47:50 +0100
Subject: Re: [PATCH v10 02/25] x86/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <87sh72jtmn.fsf@e105922-lin.cambridge.arm.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 14 May 2018 16:47:39 +0200
MIME-Version: 1.0
In-Reply-To: <87sh72jtmn.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <c289a58f-8afa-34c7-2624-c7bd2f6fcf48@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>, akpm@linux-foundation.org
Cc: mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 08/05/2018 13:04, Punit Agrawal wrote:
> Hi Laurent,
> 
> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> 
>> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT which turns on the
>> Speculative Page Fault handler when building for 64bit.
>>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  arch/x86/Kconfig | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index d8983df5a2bc..ebdeb48e4a4a 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -30,6 +30,7 @@ config X86_64
>>  	select MODULES_USE_ELF_RELA
>>  	select X86_DEV_DMA_OPS
>>  	select ARCH_HAS_SYSCALL_WRAPPER
>> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> 
> I'd suggest merging this patch with the one making changes to the
> architectural fault handler towards the end of the series.
> 
> The Kconfig change is closely tied to the architectural support for SPF
> and makes sense to be in a single patch.
> 
> If there's a good reason to keep them as separate patches, please move
> the architecture Kconfig changes after the patch adding fault handler
> changes.
> 
> It's better to enable the feature once the core infrastructure is merged
> rather than at the beginning of the series to avoid potential bad
> fallout from incomplete functionality during bisection.

Indeed bisection was the reason why Andrew asked me to push the configuration
enablement on top of the series (https://lkml.org/lkml/2017/10/10/1229).

I also think it would be better to have the architecture enablement in on patch
but that would mean that the code will not be build when bisecting without the
latest patch adding the per architecture code.

I'm fine with the both options.

Andrew, what do you think would be the best here ?

Thanks,
Laurent.

> 
> All the comments here definitely hold for the arm64 patches that you
> plan to include with the next update.
> 
> Thanks,
> Punit
> 
>>  
>>  #
>>  # Arch settings
> 
