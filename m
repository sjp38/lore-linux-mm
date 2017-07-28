Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 572FC280393
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:43:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g71so15326405wmg.13
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 00:43:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d19si16501263wrb.486.2017.07.28.00.43.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 00:43:02 -0700 (PDT)
Date: Fri, 28 Jul 2017 08:42:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 2/2] mm: migrate: fix barriers around tlb_flush_pending
Message-ID: <20170728074256.7xsnoldtfuh7ywir@suse.de>
References: <20170727114015.3452-1-namit@vmware.com>
 <20170727114015.3452-3-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170727114015.3452-3-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, nadav.amit@gmail.com, riel@redhat.com, luto@kernel.org

On Thu, Jul 27, 2017 at 04:40:15AM -0700, Nadav Amit wrote:
> Reading tlb_flush_pending while the page-table lock is taken does not
> require a barrier, since the lock/unlock already acts as a barrier.
> Removing the barrier in mm_tlb_flush_pending() to address this issue.
> 
> However, migrate_misplaced_transhuge_page() calls mm_tlb_flush_pending()
> while the page-table lock is already released, which may present a
> problem on architectures with weak memory model (PPC). To deal with this
> case, a new parameter is added to mm_tlb_flush_pending() to indicate
> if it is read without the page-table lock taken, and calling
> smp_mb__after_unlock_lock() in this case.
> 
> Signed-off-by: Nadav Amit <namit@vmware.com>

Conditional locking based on function arguements are often considered
extremely hazardous. Conditional barriers are even more troublesome because
it's simply too easy to get wrong.

Revert b0943d61b8fa420180f92f64ef67662b4f6cc493 instead of this patch. It's
not a clean revert but conflicts are due to comment changes. It moves
the check back under the PTL and the impact is marginal given that
it a spurious TLB flush will only occur when potentially racing with
change_prot_range. Since that commit went in, a lot of changes have happened
that alter the scan rate of automatic NUMA balancing so it shouldn't be a
serious issue. It's certainly a nicer option than using conditional barriers.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
