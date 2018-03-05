Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF3C6B0022
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 16:26:48 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id c16so7761634pgv.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 13:26:48 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v32-v6si9877143plb.631.2018.03.05.13.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 13:26:47 -0800 (PST)
Subject: Re: [PATCH v12 10/11] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <d8602e35e65c8bf6df1a85166bf181536a6f3664.1519227112.git.khalid.aziz@oracle.com>
 <a59ece97-ba1f-dfb1-bfc8-b44ffd8edbca@linux.intel.com>
 <84931753-9a84-8624-adb8-95bd05d87d56@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <098cda37-0e3c-de44-5995-9e5f74b301c6@linux.intel.com>
Date: Mon, 5 Mar 2018 13:26:45 -0800
MIME-Version: 1.0
In-Reply-To: <84931753-9a84-8624-adb8-95bd05d87d56@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, akpm@linux-foundation.org
Cc: corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, rob.gardner@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, anthony.yznaga@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, allen.pais@oracle.com, tklauser@distanz.ch, shannon.nelson@oracle.com, vijay.ac.kumar@oracle.com, mhocko@suse.com, jack@suse.cz, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aarcange@redhat.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, gregkh@linuxfoundation.org, nagarathnam.muthusamy@oracle.com, linux@roeck-us.net, jane.chu@oracle.com, dan.j.williams@intel.com, jglisse@redhat.com, ktkhai@virtuozzo.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 01:14 PM, Khalid Aziz wrote:
> On 03/05/2018 12:22 PM, Dave Hansen wrote:
>> On 02/21/2018 09:15 AM, Khalid Aziz wrote:
>>> +#define arch_validate_prot(prot, addr) sparc_validate_prot(prot, addr)
>>> +static inline int sparc_validate_prot(unsigned long prot, unsigned
>>> long addr)
>>> +{
>>> +A A A  if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM |
>>> PROT_ADI))
>>> +A A A A A A A  return 0;
>>> +A A A  if (prot & PROT_ADI) {
>>> +A A A A A A A  if (!adi_capable())
>>> +A A A A A A A A A A A  return 0;
>>> +
>>> +A A A A A A A  if (addr) {
>>> +A A A A A A A A A A A  struct vm_area_struct *vma;
>>> +
>>> +A A A A A A A A A A A  vma = find_vma(current->mm, addr);
>>> +A A A A A A A A A A A  if (vma) {
>>> +A A A A A A A A A A A A A A A  /* ADI can not be enabled on PFN
>>> +A A A A A A A A A A A A A A A A  * mapped pages
>>> +A A A A A A A A A A A A A A A A  */
>>> +A A A A A A A A A A A A A A A  if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
>>> +A A A A A A A A A A A A A A A A A A A  return 0;
>>
>> You don't hold mmap_sem here.A  How can this work?
>>
> Are you suggesting that vma returned by find_vma() could be split or
> merged underneath me if I do not hold mmap_sem and thus make the flag
> check invalid? If so, that is a good point.

Um, yes.  You can't walk the vma tree without holding mmap_sem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
