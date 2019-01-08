Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6509F8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:12:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 39so1361961edq.13
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:12:21 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id q47si2849711edd.98.2019.01.08.01.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 01:12:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 618841C223C
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:12:19 +0000 (GMT)
Date: Tue, 8 Jan 2019 09:12:17 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/25] Increase success rates and reduce latency of
 compaction v2
Message-ID: <20190108091217.GL31517@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190107154354.b0805ca15767fc7ea9e37545@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190107154354.b0805ca15767fc7ea9e37545@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Mon, Jan 07, 2019 at 03:43:54PM -0800, Andrew Morton wrote:
> On Fri,  4 Jan 2019 12:49:46 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > This series reduces scan rates and success rates of compaction, primarily
> > by using the free lists to shorten scans, better controlling of skip
> > information and whether multiple scanners can target the same block and
> > capturing pageblocks before being stolen by parallel requests. The series
> > is based on the 4.21/5.0 merge window after Andrew's tree had been merged.
> > It's known to rebase cleanly.
> > 
> > ...
> >
> >  include/linux/compaction.h |    3 +-
> >  include/linux/gfp.h        |    7 +-
> >  include/linux/mmzone.h     |    2 +
> >  include/linux/sched.h      |    4 +
> >  kernel/sched/core.c        |    3 +
> >  mm/compaction.c            | 1031 ++++++++++++++++++++++++++++++++++----------
> >  mm/internal.h              |   23 +-
> >  mm/migrate.c               |    2 +-
> >  mm/page_alloc.c            |   70 ++-
> >  9 files changed, 908 insertions(+), 237 deletions(-)
> 
> Boy that's a lot of material. 

It's unfortunate I know. It just turned out that there is a lot that had
to change to make the most important patches in the series work without
obvious side-effects.

> I just tossed it in there unread for
> now.  Do you have any suggestions as to how we can move ahead with
> getting this appropriately reviewed and tested?
> 

The main workloads that should see a difference are those that use
MADV_HUGEPAGE or change /sys/kernel/mm/transparent_hugepage/defrag. I'm
expecting MADV_HUGEPAGE is more common in practice. By default, there
should be little change as direct compaction is not used heavily for THP.
Although SLUB workloads might see a difference given a long enough uptime,
it will be relatively difficult to detect.

As this was partially motivated by the __GFP_THISNODE discussion, I
would like to hear from David if this series makes an impact, if any,
when starting Google workloads on a fragmented system.

Similarly, I would be interested in hearing if Andrea's KVM startup times
see any benefit. I'm expecting less here as I expect that workload is
still bound by reclaim thrashing the local node in reclaim. Still, a
confirmation would be nice and if there is any benefit then it's a plus
even if the workload gets reclaimed excessively.

Local tests didn't show up anything interesting *other* than what is
already in the changelogs as those workloads are specifically targetting
those paths. Intel LKP has not reported any regressions (functional or
performance) despite being on git.kernel.org for a few weeks. However,
as they are using default configurations, this is not much of a surprise.

Review is harder. Vlastimil would normally be the best fit as he has
worked on compaction but for him or for anyone else, I'm expecting they're
dealing with a backlog after the holidays.  I know I still have to get
to Vlastimil's recent series on THP allocations so I'm guilty of the same
crime with respect to review.

-- 
Mel Gorman
SUSE Labs
