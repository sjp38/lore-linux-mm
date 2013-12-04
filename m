Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id BB58B6B0037
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 09:33:57 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so11257548yhl.6
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 06:33:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r49si3584761yho.217.2013.12.04.06.33.56
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 06:33:56 -0800 (PST)
Message-ID: <529F3D51.1090203@redhat.com>
Date: Wed, 04 Dec 2013 09:33:53 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-15-git-send-email-mgorman@suse.de> <529E641A.7040804@redhat.com> <20131203234637.GS11295@suse.de>
In-Reply-To: <20131203234637.GS11295@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/03/2013 06:46 PM, Mel Gorman wrote:
> On Tue, Dec 03, 2013 at 06:07:06PM -0500, Rik van Riel wrote:
>> On 12/03/2013 03:52 AM, Mel Gorman wrote:
>>> NUMA PTE updates and NUMA PTE hinting faults can race against each other. The
>>> setting of the NUMA bit defers the TLB flush to reduce overhead. NUMA
>>> hinting faults do not flush the TLB as X86 at least does not cache TLB
>>> entries for !present PTEs. However, in the event that the two race a NUMA
>>> hinting fault may return with the TLB in an inconsistent state between
>>> different processors. This patch detects potential for races between the
>>> NUMA PTE scanner and fault handler and will flush the TLB for the affected
>>> range if there is a race.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>
>>> diff --git a/mm/migrate.c b/mm/migrate.c
>>> index 5dfd552..ccc814b 100644
>>> --- a/mm/migrate.c
>>> +++ b/mm/migrate.c
>>> @@ -1662,6 +1662,39 @@ void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
>>>  	smp_rmb();
>>>  }
>>>  
>>> +unsigned long numa_fault_prepare(struct mm_struct *mm)
>>> +{
>>> +	/* Paired with task_numa_work */
>>> +	smp_rmb();
>>> +	return mm->numa_next_reset;
>>> +}
>>
>> The patch that introduces mm->numa_next_reset, and the
>> patch that increments it, seem to be missing from your
>> series...
>>
> 
> Damn. s/numa_next_reset/numa_next_scan/ in that patch

How does that protect against the race?

Would it not be possible for task_numa_work to have a longer
runtime than the numa fault?

In other words, task_numa_work can increment numa_next_scan
before the numa fault starts, and still be doing its thing
when numa_fault_commit is run...

At that point, numa_fault_commit will not be seeing an
increment in numa_next_scan, and we are relying completely
on the batched tlb flush by the change_prot_numa.

Is that scenario a problem, or is it ok?

And, why? :)


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
