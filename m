Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 353D94405BD
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 21:13:00 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id h7so692171wjy.6
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 18:13:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u43si7287379wrb.327.2017.02.15.18.12.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 18:12:58 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1G23i3D075473
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 21:12:57 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28n1m0k6xy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 21:12:57 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 15 Feb 2017 19:12:56 -0700
Subject: Re: [PATCH 2/2] powerpc/mm/autonuma: Switch ppc64 to its own
 implementeation of saved write
References: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1486609259-6796-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20170215134627.315dd734bd0000393a680cc9@linux-foundation.org>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 16 Feb 2017 07:42:46 +0530
MIME-Version: 1.0
In-Reply-To: <20170215134627.315dd734bd0000393a680cc9@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <ac64eed6-06fc-642b-8e33-f4d6e6f4f0a5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org



On Thursday 16 February 2017 03:16 AM, Andrew Morton wrote:
> On Thu,  9 Feb 2017 08:30:59 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> With this our protnone becomes a present pte with READ/WRITE/EXEC bit cleared.
>> By default we also set _PAGE_PRIVILEGED on such pte. This is now used to help
>> us identify a protnone pte that as saved write bit. For such pte, we will clear
>> the _PAGE_PRIVILEGED bit. The pte still remain non-accessible from both user
>> and kernel.
> I don't see how these patches differ from the ones which are presently
> in -mm.
>
> It helps to have a [0/n] email for a patch series and to put a version
> number in there as well.
>
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
>> +#define pte_savedwrite pte_savedwrite
>> +static inline bool pte_savedwrite(pte_t pte)
>> +{
>> +	/*
>> +	 * Saved write ptes are prot none ptes that doesn't have
>> +	 * privileged bit sit. We mark prot none as one which has
>> +	 * present and pviliged bit set and RWX cleared. To mark
>> +	 * protnone which used to have _PAGE_WRITE set we clear
>> +	 * the privileged bit.
>> +	 */
>> +	return !(pte_raw(pte) & cpu_to_be64(_PAGE_RWX | _PAGE_PRIVILEGED));
>> +}
>> +
>>   static inline pte_t pte_mkdevmap(pte_t pte)
>>   {
>>   	return __pte(pte_val(pte) | _PAGE_SPECIAL|_PAGE_DEVMAP);
> arch/powerpc/include/asm/book3s/64/pgtable.h doesn't have
> pte_mkdevmap().  What tree are you patching here?
>
>

I did post a V2 of this for which you replied
https://lkml.kernel.org/r/20170214162008.bd592c747fc5e167c10ce7b8@linux-foundation.org

I actually found the issue with this patch. I will be sending V3 after 
more testing.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
