Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD616B0078
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 09:56:05 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so7146822pdj.30
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 06:56:04 -0700 (PDT)
Message-ID: <5252BD63.6060606@redhat.com>
Date: Mon, 07 Oct 2013 09:55:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/63] mm: Wait for THP migrations to complete during
 NUMA hinting faults
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-6-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> The locking for migrating THP is unusual. While normal page migration
> prevents parallel accesses using a migration PTE, THP migration relies on
> a combination of the page_table_lock, the page lock and the existance of
> the NUMA hinting PTE to guarantee safety but there is a bug in the scheme.
> 
> If a THP page is currently being migrated and another thread traps a
> fault on the same page it checks if the page is misplaced. If it is not,
> then pmd_numa is cleared. The problem is that it checks if the page is
> misplaced without holding the page lock meaning that the racing thread
> can be migrating the THP when the second thread clears the NUMA bit
> and faults a stale page.
> 
> This patch checks if the page is potentially being migrated and stalls
> using the lock_page if it is potentially being migrated before checking
> if the page is misplaced or not.
> 
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
