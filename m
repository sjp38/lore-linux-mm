Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B615F6B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 05:30:15 -0400 (EDT)
Date: Mon, 17 Jun 2013 10:30:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
Message-ID: <20130617093010.GH1875@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-2-git-send-email-aarcange@redhat.com>
 <20130606090430.GC1936@suse.de>
 <51B0C8D8.7070708@redhat.com>
 <51BB41EF.7080508@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51BB41EF.7080508@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Fri, Jun 14, 2013 at 12:16:47PM -0400, Rik van Riel wrote:
> On 06/06/2013 01:37 PM, Rik van Riel wrote:
> >On 06/06/2013 05:04 AM, Mel Gorman wrote:
> >>On Wed, Jun 05, 2013 at 05:10:31PM +0200, Andrea Arcangeli wrote:
> >>>Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> >>>thread allocates memory at the same time, it forces a premature
> >>>allocation into remote NUMA nodes even when there's plenty of clean
> >>>cache to reclaim in the local nodes.
> >>>
> >>>Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> >>
> >>Be aware that after this patch is applied that it is possible to have a
> >>situation like this
> >>
> >>1. 4 processes running on node 1
> >>2. Each process tries to allocate 30% of memory
> >>3. Each process reads the full buffer in a loop (stupid, just an example)
> >>
> >>In this situation the processes will continually interfere with each
> >>other until one of them gets migrated to another zone by the scheduler.
> >
> >This is a very good point.
> >
> >Andrea, I suspect we will need some kind of safeguard against
> >this problem.
> 
> Never mind me.
> 
> In __zone_reclaim we set the flags in swap_control so
> we never unmap pages or swap pages out at all by
> default, so this should not be an issue at all.
> 
> In order to get the problem illustrated above, the
> user will have to enable RECLAIM_SWAP through sysfs
> manually.
> 

For the mapped case and the default tuning for zone_reclaim_mode then
yes. If instead of allocating 30% of memory the processes are using using
buffered reads/writes then they'll reach each others page cache pages and
it's a very similar problem.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
