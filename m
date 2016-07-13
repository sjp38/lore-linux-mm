Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B78116B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:08:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so28267119wmr.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:08:13 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id l64si1413780wml.10.2016.07.13.00.08.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 00:08:12 -0700 (PDT)
Message-ID: <5785E764.8050304@huawei.com>
Date: Wed, 13 Jul 2016 15:01:56 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] kexec: add a pmd huge entry condition during the
 page table
References: <1468299403-27954-1-git-send-email-zhongjiang@huawei.com> <1468299403-27954-2-git-send-email-zhongjiang@huawei.com> <87a8hm3lme.fsf@x220.int.ebiederm.org>
In-Reply-To: <87a8hm3lme.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: dyoung@redhat.com, horms@verge.net.au, vgoyal@redhat.com, yinghai@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, kexec@lists.infradead.org

On 2016/7/12 23:46, Eric W. Biederman wrote:
> zhongjiang <zhongjiang@huawei.com> writes:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when image is loaded into kernel, we need set up page table for it. and 
>> all valid pfn also set up new mapping. it will tend to establish a pmd 
>> page table in the form of a large page if pud_present is true. relocate_kernel 
>> points to code segment can locate in the pmd huge entry in init_transtion_pgtable. 
>> therefore, we need to take the situation into account.
> I can see how in theory this might be necessary but when is a kernel virtual
> address on x86_64 that is above 0x8000000000000000 in conflict with an
> identity mapped physicall address that are all below 0x8000000000000000?
>
> If anything the code could be simplified to always assume those mappings
> are unoccupied.
>
> Did you run into an actual failure somewhere?
>
> Eric
>
   I  do not understand what you trying to say,  Maybe I miss your point.
  
  The key is how to ensure that relocate_kernel points to the pmd entry is not huge page.
 
  Thanks
  zhongjiang
 
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  arch/x86/kernel/machine_kexec_64.c | 20 ++++++++++++++++++--
>>  1 file changed, 18 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
>> index 5a294e4..c33e344 100644
>> --- a/arch/x86/kernel/machine_kexec_64.c
>> +++ b/arch/x86/kernel/machine_kexec_64.c
>> @@ -14,6 +14,7 @@
>>  #include <linux/gfp.h>
>>  #include <linux/reboot.h>
>>  #include <linux/numa.h>
>> +#include <linux/hugetlb.h>
>>  #include <linux/ftrace.h>
>>  #include <linux/io.h>
>>  #include <linux/suspend.h>
>> @@ -34,6 +35,17 @@ static struct kexec_file_ops *kexec_file_loaders[] = {
>>  };
>>  #endif
>>  
>> +static void split_pmd(pmd_t *pmd, pte_t *pte)
>> +{
>> +	unsigned long pfn = pmd_pfn(*pmd);
>> +	int i = 0;
>> +
>> +	do {
>> +		set_pte(pte, pfn_pte(pfn, PAGE_KERNEL_EXEC));
>> +		pfn++;
>> +	} while (pte++, i++, i < PTRS_PER_PTE);
>> +}
>> +
>>  static void free_transition_pgtable(struct kimage *image)
>>  {
>>  	free_page((unsigned long)image->arch.pud);
>> @@ -68,15 +80,19 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
>>  		set_pud(pud, __pud(__pa(pmd) | _KERNPG_TABLE));
>>  	}
>>  	pmd = pmd_offset(pud, vaddr);
>> -	if (!pmd_present(*pmd)) {
>> +	if (!pmd_present(*pmd) || pmd_huge(*pmd)) {
>>  		pte = (pte_t *)get_zeroed_page(GFP_KERNEL);
>>  		if (!pte)
>>  			goto err;
>>  		image->arch.pte = pte;
>> -		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
>> +		if (pmd_huge(*pmd))
>> +			split_pmd(pmd, pte);
>> +		else
>> +			set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
>>  	}
>>  	pte = pte_offset_kernel(pmd, vaddr);
>>  	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC));
>> +
>>  	return 0;
>>  err:
>>  	free_transition_pgtable(image);
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
