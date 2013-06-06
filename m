Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C08CC6B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 05:04:34 -0400 (EDT)
Date: Thu, 6 Jun 2013 10:04:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
Message-ID: <20130606090430.GC1936@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1370445037-24144-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 05:10:31PM +0200, Andrea Arcangeli wrote:
> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> thread allocates memory at the same time, it forces a premature
> allocation into remote NUMA nodes even when there's plenty of clean
> cache to reclaim in the local nodes.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Be aware that after this patch is applied that it is possible to have a
situation like this

1. 4 processes running on node 1
2. Each process tries to allocate 30% of memory
3. Each process reads the full buffer in a loop (stupid, just an example)

In this situation the processes will continually interfere with each
other until one of them gets migrated to another zone by the scheduler.
Watch for excessive reclaim, swapping and page writes from reclaim context
as a result of this patch. A less stupid example is four file intensive
workloads running in one node interfering with each other.

Before this patch, one process would make forward progress and the others
would fall back to using remote memory until all 4 processes had all the
memory they need. At this point it is no longer allocating new pages or in
reclaim. Most users will not notice additional remote accesses but I bet
you they will notice swap/reclaim storms when there is plenty of memory
on other nodes.

Direct reclaim suffers a similar problem but to a much lesser extent.
Users of direct reclaim will fall back to other zones in the zonelist and
kswapd mitigates entry into direct reclaim in a number of cases.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
