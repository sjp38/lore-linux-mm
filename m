Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 234FC6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:56:03 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so36963558lbb.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 02:56:03 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id l2si10795518wmd.15.2016.06.22.02.55.59
        for <linux-mm@kvack.org>;
        Wed, 22 Jun 2016 02:56:01 -0700 (PDT)
Message-ID: <576A5FE4.3090108@huawei.com>
Date: Wed, 22 Jun 2016 17:52:36 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/huge_memory: fix the memory leak due to the race
References: <1466517956-13875-1-git-send-email-zhongjiang@huawei.com> <20160621143701.GA6139@node.shutemov.name> <57695AEB.8030509@huawei.com> <20160621152920.GA7760@node.shutemov.name>
In-Reply-To: <20160621152920.GA7760@node.shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/6/21 23:29, Kirill A. Shutemov wrote:
> On Tue, Jun 21, 2016 at 11:19:07PM +0800, zhong jiang wrote:
>> On 2016/6/21 22:37, Kirill A. Shutemov wrote:
>>> On Tue, Jun 21, 2016 at 10:05:56PM +0800, zhongjiang wrote:
>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>
>>>> with great pressure, I run some test cases. As a result, I found
>>>> that the THP is not freed, it is detected by check_mm().
>>>>
>>>> BUG: Bad rss-counter state mm:ffff8827edb70000 idx:1 val:512
>>>>
>>>> Consider the following race :
>>>>
>>>> 	CPU0                               CPU1
>>>>   __handle_mm_fault()
>>>>         wp_huge_pmd()
>>>>    	    do_huge_pmd_wp_page()
>>>> 		pmdp_huge_clear_flush_notify()
>>>>                 (pmd_none = true)
>>>> 					exit_mmap()
>>>> 					   unmap_vmas()
>>>> 					     zap_pmd_range()
>>>> 						pmd_none_or_trans_huge_or_clear_bad()
>>>> 						   (result in memory leak)
>>>>                 set_pmd_at()
>>>>
>>>> because of CPU0 have allocated huge page before pmdp_huge_clear_notify,
>>>> and it make the pmd entry to be null. Therefore, The memory leak can occur.
>>>>
>>>> The patch fix the scenario that the pmd entry can lead to be null.
>>> I don't think the scenario is possible.
>>>
>>> exit_mmap() called when all mm users have gone, so no parallel threads
>>> exist.
>>>
>>  Forget  this patch.  It 's my fault , it indeed don not exist.
>>  But I  hit the following problem.  we can see the memory leak when the process exit.
>>  
>>  
>>  Any suggestion will be apprecaited.
> Could you try this:
>
> http://lkml.kernel.org/r/20160621150433.GA7536@node.shutemov.name
 The patch I have seen ,  but I  don not think this patch  can fix so problem . if that race occur,  pmd entry points to
 the huge page will be changed ,  and freeze_page spilt pmd will fail. subsequent vm_bug_on() will fired.

 freeze_page()
     try_to_unmap()
         split_huge_pmd_address() (return fail) result in page_mapcount is not zero
 vm_bug_on()

               
             

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
