Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E0D5D6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 22:00:51 -0400 (EDT)
Message-ID: <51F1D839.7050302@huawei.com>
Date: Fri, 26 Jul 2013 10:00:25 +0800
From: Libin <huawei.libin@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix potential NULL pointer dereference
References: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com> <20130725140106.GJ12818@dhcp22.suse.cz>
In-Reply-To: <20130725140106.GJ12818@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, wujianguo@huawei.com

On 2013/7/25 22:01, Michal Hocko wrote:
> On Wed 24-07-13 11:48:19, Libin wrote:
>> find_vma may return NULL, thus check the return
>> value to avoid NULL pointer dereference.
> 
> Please add a note that the check matters only because
> khugepaged_alloc_page drops mmap_sem.
> 

Thanks for your suggestion. I will add the information
and post the patch soon.

Regards,
Libin.

>> Signed-off-by: Libin <huawei.libin@huawei.com>
> 
> Other than that
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 
> + I guess this is worth backporting to the stable trees. This goes back
> to when khugepaged was introduced AFAICS.
> 
>> ---
>>  mm/huge_memory.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 243e710..d4423f4 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>>  		goto out;
>>  
>>  	vma = find_vma(mm, address);
>> +	if (!vma)
>> +		goto out;
>>  	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>>  	hend = vma->vm_end & HPAGE_PMD_MASK;
>>  	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
>> -- 
>> 1.8.2.1
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
