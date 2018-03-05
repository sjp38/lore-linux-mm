Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0263E6B0012
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 16:20:26 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id o10so17136988iod.21
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 13:20:25 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f19si9411222ioe.291.2018.03.05.13.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 13:20:25 -0800 (PST)
Subject: Re: [PATCH v12 10/11] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <d8602e35e65c8bf6df1a85166bf181536a6f3664.1519227112.git.khalid.aziz@oracle.com>
 <a59ece97-ba1f-dfb1-bfc8-b44ffd8edbca@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <84931753-9a84-8624-adb8-95bd05d87d56@oracle.com>
Date: Mon, 5 Mar 2018 14:14:50 -0700
MIME-Version: 1.0
In-Reply-To: <a59ece97-ba1f-dfb1-bfc8-b44ffd8edbca@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, akpm@linux-foundation.org
Cc: corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, rob.gardner@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, anthony.yznaga@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, allen.pais@oracle.com, tklauser@distanz.ch, shannon.nelson@oracle.com, vijay.ac.kumar@oracle.com, mhocko@suse.com, jack@suse.cz, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aarcange@redhat.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, gregkh@linuxfoundation.org, nagarathnam.muthusamy@oracle.com, linux@roeck-us.net, jane.chu@oracle.com, dan.j.williams@intel.com, jglisse@redhat.com, ktkhai@virtuozzo.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 12:22 PM, Dave Hansen wrote:
> On 02/21/2018 09:15 AM, Khalid Aziz wrote:
>> +#define arch_validate_prot(prot, addr) sparc_validate_prot(prot, addr)
>> +static inline int sparc_validate_prot(unsigned long prot, unsigned long addr)
>> +{
>> +	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_ADI))
>> +		return 0;
>> +	if (prot & PROT_ADI) {
>> +		if (!adi_capable())
>> +			return 0;
>> +
>> +		if (addr) {
>> +			struct vm_area_struct *vma;
>> +
>> +			vma = find_vma(current->mm, addr);
>> +			if (vma) {
>> +				/* ADI can not be enabled on PFN
>> +				 * mapped pages
>> +				 */
>> +				if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
>> +					return 0;
> 
> You don't hold mmap_sem here.  How can this work?
>

Are you suggesting that vma returned by find_vma() could be split or 
merged underneath me if I do not hold mmap_sem and thus make the flag 
check invalid? If so, that is a good point.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
