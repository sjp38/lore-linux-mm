Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id EDF0B6B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 21:27:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 11:11:38 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A97F42BB0051
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 11:27:00 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6H1BZUh8782142
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 11:11:36 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6H1Qw84003754
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 11:26:59 +1000
Date: Wed, 17 Jul 2013 09:26:57 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/18] mm: numa: Account for THP numa hinting faults on
 the correct node
Message-ID: <20130717012657.GA1602@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-4-git-send-email-mgorman@suse.de>
 <CAJd=RBD7UR5Fo8u3YtXf-h4dzZhWazMX8YJ0=3dSabcef=w66w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBD7UR5Fo8u3YtXf-h4dzZhWazMX8YJ0=3dSabcef=w66w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 17, 2013 at 08:33:13AM +0800, Hillf Danton wrote:
>On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
>> THP NUMA hinting fault on pages that are not migrated are being
>> accounted for incorrectly. Currently the fault will be counted as if the
>> task was running on a node local to the page which is not necessarily
>> true.
>>

Hi Hillf,

>Can you please run test again without this correction and check the difference?
>

I think the essential point is which node NUMA hinting faults counts should 
be accumulated to when thp pages are not migrated. Counts are accounted as 
local numa hinting fault before this patch, it's not always true and there's 
bad influence when determine the preferred node with the most numa hinting 
faults.

Regards,
Wanpeng Li 

>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>> ---
>>  mm/huge_memory.c | 10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index e2f7f5aa..e4a79fa 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1293,7 +1293,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>         struct page *page;
>>         unsigned long haddr = addr & HPAGE_PMD_MASK;
>>         int target_nid;
>> -       int current_nid = -1;
>> +       int src_nid = -1;
>>         bool migrated;
>>
>>         spin_lock(&mm->page_table_lock);
>> @@ -1302,9 +1302,9 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>
>>         page = pmd_page(pmd);
>>         get_page(page);
>> -       current_nid = page_to_nid(page);
>> +       src_nid = numa_node_id();
>>         count_vm_numa_event(NUMA_HINT_FAULTS);
>> -       if (current_nid == numa_node_id())
>> +       if (src_nid == page_to_nid(page))
>>                 count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
>>
>>         target_nid = mpol_misplaced(page, vma, haddr);
>> @@ -1346,8 +1346,8 @@ clear_pmdnuma:
>>         update_mmu_cache_pmd(vma, addr, pmdp);
>>  out_unlock:
>>         spin_unlock(&mm->page_table_lock);
>> -       if (current_nid != -1)
>> -               task_numa_fault(current_nid, HPAGE_PMD_NR, false);
>> +       if (src_nid != -1)
>> +               task_numa_fault(src_nid, HPAGE_PMD_NR, false);
>>         return 0;
>>  }
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
