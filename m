Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81EE56B0266
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 08:06:10 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k2so1466657wrg.3
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 05:06:10 -0800 (PST)
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id o27si465505wro.223.2018.01.11.05.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 05:06:08 -0800 (PST)
Subject: Re: [PATCH] mm, THP: vmf_insert_pfn_pud depends on
 CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
References: <1515660811-12293-1-git-send-email-aghiti@upmem.com>
 <20180111100620.GY1732@dhcp22.suse.cz>
From: Alexandre Ghiti <aghiti@upmem.com>
Message-ID: <71853228-0beb-1e69-df47-59fa1bc5bd2f@upmem.com>
Date: Thu, 11 Jan 2018 14:05:34 +0100
MIME-Version: 1.0
In-Reply-To: <20180111100620.GY1732@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, gregkh@linuxfoundation.org, n-horiguchi@ah.jp.nec.com, willy@linux.intel.com, mark.rutland@arm.com, linux-kernel@vger.kernel.org

On 11/01/2018 11:06, Michal Hocko wrote:
> On Thu 11-01-18 09:53:31, Alexandre Ghiti wrote:
>> The only definition of vmf_insert_pfn_pud depends on
>> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD being defined. Then its declaration in
>> include/linux/huge_mm.h should have the same restriction so that we do
>> not expose this function if CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is
>> not defined.
> Why is this a problem? Compiler should simply throw away any
> declarations which are not used?
It is not a big problem but surrounding the declaration with the #ifdef 
makes the compilation of external modules fail with an "error: implicit 
declaration of function vmf_insert_pfn_pud" if 
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is not defined. I think it is 
cleaner than generating a .ko which would not load anyway.

>
>> Signed-off-by: Alexandre Ghiti <aghiti@upmem.com>
>> ---
>>   include/linux/huge_mm.h | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index a8a1262..11794f6a 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -48,8 +48,10 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>>   			int prot_numa);
>>   int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>>   			pmd_t *pmd, pfn_t pfn, bool write);
>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
>>   int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>>   			pud_t *pud, pfn_t pfn, bool write);
>> +#endif
>>   enum transparent_hugepage_flag {
>>   	TRANSPARENT_HUGEPAGE_FLAG,
>>   	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>> -- 
>> 2.1.4
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
