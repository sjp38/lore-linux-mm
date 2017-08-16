Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCBDD6B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:45:50 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id p138so14148993vkp.8
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:45:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z9si418044uac.164.2017.08.16.07.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 07:45:50 -0700 (PDT)
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <cover.1502219353.git.khalid.aziz@oracle.com>
 <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
 <20170815.215834.141971110430980112.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <dcf03dde-acd0-b7a3-cc5e-1e0fe98efbe8@oracle.com>
Date: Wed, 16 Aug 2017 08:44:58 -0600
MIME-Version: 1.0
In-Reply-To: <20170815.215834.141971110430980112.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

On 08/15/2017 10:58 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Wed,  9 Aug 2017 15:26:02 -0600
> 
>> +void adi_restore_tags(struct mm_struct *mm, struct vm_area_struct *vma,
>> +		      unsigned long addr, pte_t pte)
>> +{
>   ...
>> +	tag = tag_start(addr, tag_desc);
>> +	paddr = pte_val(pte) & _PAGE_PADDR_4V;
>> +	for (tmp = paddr; tmp < (paddr+PAGE_SIZE); tmp += adi_blksize()) {
>> +		version1 = (*tag) >> 4;
>> +		version2 = (*tag) & 0x0f;
>> +		*tag++ = 0;
>> +		asm volatile("stxa %0, [%1] %2\n\t"
>> +			:
>> +			: "r" (version1), "r" (tmp),
>> +			  "i" (ASI_MCD_REAL));
>> +		tmp += adi_blksize();
>> +		asm volatile("stxa %0, [%1] %2\n\t"
>> +			:
>> +			: "r" (version2), "r" (tmp),
>> +			  "i" (ASI_MCD_REAL));
>> +	}
>> +	asm volatile("membar #Sync\n\t");
> 
> You do a membar here.
> 
>> +		for (i = pfrom; i < (pfrom + PAGE_SIZE); i += adi_blksize()) {
>> +			asm volatile("ldxa [%1] %2, %0\n\t"
>> +					: "=r" (adi_tag)
>> +					:  "r" (i), "i" (ASI_MCD_REAL));
>> +			asm volatile("stxa %0, [%1] %2\n\t"
>> +					:
>> +					: "r" (adi_tag), "r" (pto),
>> +					  "i" (ASI_MCD_REAL));
> 
> But not here.
> 
> Is this OK?  I suspect you need to add a membar this this second piece
> of MCD tag storing code.

Hi Dave,

You are right. This tag storing code needs membar as well. I will add that.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
