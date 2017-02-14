Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 312CB6B0393
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:27:48 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id w144so188016526oiw.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 04:27:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 130si2648217ith.47.2017.02.14.04.27.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 04:27:47 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1ECNn6I055702
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:27:47 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28kv2dx9sg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:27:46 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 14 Feb 2017 22:27:44 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B56A83578057
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 23:27:41 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1ECRXL318350210
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 23:27:41 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1ECR9HZ026706
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 23:27:09 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 2/2] powerpc/mm/autonuma: Switch ppc64 to its own implementeation of saved write
In-Reply-To: <87y3x9kp8e.fsf@concordia.ellerman.id.au>
References: <1487050314-3892-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1487050314-3892-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <87y3x9kp8e.fsf@concordia.ellerman.id.au>
Date: Tue, 14 Feb 2017 17:56:44 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87d1elufej.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Michael Ellerman <mpe@ellerman.id.au> writes:

> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
>> diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
>> index 0735d5a8049f..8720a406bbbe 100644
>> --- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
>> +++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
>> @@ -16,6 +16,9 @@
>>  #include <asm/page.h>
>>  #include <asm/bug.h>
>>  
>> +#ifndef __ASSEMBLY__
>> +#include <linux/mmdebug.h>
>> +#endif
>
> I assume that's for the VM_BUG_ON() you add below. But if so wouldn't
> the #include be better placed in book3s/64/pgtable.h also?

mmu-hash.h has got a hack that is explained below

#ifndef __ASSEMBLY__
#include <linux/mmdebug.h>
#endif
/*
 * This is necessary to get the definition of PGTABLE_RANGE which we
 * need for various slices related matters. Note that this isn't the
 * complete pgtable.h but only a portion of it.
 */
#include <asm/book3s/64/pgtable.h>

This is the only place where we do that book3s/64/pgtable.h include this
way. Everybody should include asm/pgable.h which picks the righ version
based on different config option.

#
>
>> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> index fef738229a68..c684ef6cbd10 100644
>> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> @@ -512,6 +512,32 @@ static inline pte_t pte_mkhuge(pte_t pte)
>>  	return pte;
>>  }
>>  
>> +#define pte_mk_savedwrite pte_mk_savedwrite
>> +static inline pte_t pte_mk_savedwrite(pte_t pte)
>> +{
>> +	/*
>> +	 * Used by Autonuma subsystem to preserve the write bit
>> +	 * while marking the pte PROT_NONE. Only allow this
>> +	 * on PROT_NONE pte
>> +	 */
>> +	VM_BUG_ON((pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_RWX | _PAGE_PRIVILEGED)) !=
>> +		  cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED));
>> +	return __pte(pte_val(pte) & ~_PAGE_PRIVILEGED);
>> +}
>> +
>
>
> cheers

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
