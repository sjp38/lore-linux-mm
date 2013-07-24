Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 776616B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 00:35:39 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 09:59:51 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 737BD394002D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 10:05:28 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O4aPDH42729572
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 10:06:25 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O4ZWTm029368
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:35:33 +1000
Date: Wed, 24 Jul 2013 12:35:31 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Fix potential NULL pointer dereference
Message-ID: <20130724043531.GA22357@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
 <20130724042208.GJ22680@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130724042208.GJ22680@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Libin <huawei.libin@huawei.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, wujianguo@huawei.com

On Wed, Jul 24, 2013 at 12:22:08PM +0800, Wanpeng Li wrote:
>On Wed, Jul 24, 2013 at 11:48:19AM +0800, Libin wrote:
>>find_vma may return NULL, thus check the return
>>value to avoid NULL pointer dereference.
>>
>
>When can this happen since down_read(&mm->mmap_sem) is held?
>

Between mmap_sem read lock released and write lock held I think.

>>Signed-off-by: Libin <huawei.libin@huawei.com>
>>---
>> mm/huge_memory.c | 2 ++
>> 1 file changed, 2 insertions(+)
>>
>>diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>index 243e710..d4423f4 100644
>>--- a/mm/huge_memory.c
>>+++ b/mm/huge_memory.c
>>@@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>> 		goto out;
>>
>> 	vma = find_vma(mm, address);
>>+	if (!vma)
>>+		goto out;
>> 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>> 	hend = vma->vm_end & HPAGE_PMD_MASK;
>> 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
>>-- 
>>1.8.2.1
>>
>>
>>--
>>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>the body to majordomo@kvack.org.  For more info on Linux MM,
>>see: http://www.linux-mm.org/ .
>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
