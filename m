Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C01BE6B009A
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:08:44 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hq4so3814049wib.5
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:08:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t2si4533870wiz.3.2013.12.09.06.08.43
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:08:43 -0800 (PST)
Message-ID: <52A5CEE6.2080609@redhat.com>
Date: Mon, 09 Dec 2013 09:08:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/18] mm: numa: Serialise parallel get_user_page against
 THP migration
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:08 AM, Mel Gorman wrote:
> Base pages are unmapped and flushed from cache and TLB during normal page
> migration and replaced with a migration entry that causes any parallel or
> gup to block until migration completes. THP does not unmap pages due to
> a lack of support for migration entries at a PMD level. This allows races
> with get_user_pages and get_user_pages_fast which commit 3f926ab94 ("mm:
> Close races between THP migration and PMD numa clearing") made worse by
> introducing a pmd_clear_flush().
> 
> This patch forces get_user_page (fast and normal) on a pmd_numa page to
> go through the slow get_user_page path where it will serialise against THP
> migration and properly account for the NUMA hinting fault. On the migration
> side the page table lock is taken for each PTE update.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
