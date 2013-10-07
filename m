Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C4B3C6B004D
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 10:02:53 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so7381724pab.11
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 07:02:53 -0700 (PDT)
Message-ID: <5252BEFF.7040202@redhat.com>
Date: Mon, 07 Oct 2013 10:02:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/63] mm: Close races between THP migration and PMD numa
 clearing
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-9-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> THP migration uses the page lock to guard against parallel allocations
> but there are cases like this still open
> 
> Task A						Task B
> do_huge_pmd_numa_page				do_huge_pmd_numa_page
> lock_page
> mpol_misplaced == -1
> unlock_page
> goto clear_pmdnuma
> 						lock_page
> 						mpol_misplaced == 2
> 						migrate_misplaced_transhuge
> pmd = pmd_mknonnuma
> set_pmd_at
> 
> During hours of testing, one crashed with weird errors and while I have
> no direct evidence, I suspect something like the race above happened.
> This patch extends the page lock to being held until the pmd_numa is
> cleared to prevent migration starting in parallel while the pmd_numa is
> being cleared. It also flushes the old pmd entry and orders pagetable
> insertion before rmap insertion.
> 
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
