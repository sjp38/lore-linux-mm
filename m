Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id EB0736B006E
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:07:09 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so14130469qeb.12
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:07:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hd1si8971967qcb.60.2013.12.03.15.07.08
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 15:07:09 -0800 (PST)
Message-ID: <529E641A.7040804@redhat.com>
Date: Tue, 03 Dec 2013 18:07:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-15-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/03/2013 03:52 AM, Mel Gorman wrote:
> NUMA PTE updates and NUMA PTE hinting faults can race against each other. The
> setting of the NUMA bit defers the TLB flush to reduce overhead. NUMA
> hinting faults do not flush the TLB as X86 at least does not cache TLB
> entries for !present PTEs. However, in the event that the two race a NUMA
> hinting fault may return with the TLB in an inconsistent state between
> different processors. This patch detects potential for races between the
> NUMA PTE scanner and fault handler and will flush the TLB for the affected
> range if there is a race.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 5dfd552..ccc814b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1662,6 +1662,39 @@ void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
>  	smp_rmb();
>  }
>  
> +unsigned long numa_fault_prepare(struct mm_struct *mm)
> +{
> +	/* Paired with task_numa_work */
> +	smp_rmb();
> +	return mm->numa_next_reset;
> +}

The patch that introduces mm->numa_next_reset, and the
patch that increments it, seem to be missing from your
series...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
