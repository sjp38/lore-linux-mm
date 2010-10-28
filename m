Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EF79F8D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:14:06 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o9SME05D020930
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 15:14:00 -0700
Received: from gwb15 (gwb15.prod.google.com [10.200.2.15])
	by hpaq12.eem.corp.google.com with ESMTP id o9SMDwlG007227
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 15:13:58 -0700
Received: by gwb15 with SMTP id 15so1783515gwb.31
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 15:13:58 -0700 (PDT)
Date: Thu, 28 Oct 2010 15:13:38 -0700
From: Mandeep Singh Baines <msb@chromium.org>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
Message-ID: <20101028221338.GA26494@google.com>
References: <20101028191523.GA14972@google.com>
 <4CC9EB84.9050406@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CC9EB84.9050406@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

Rik van Riel (riel@redhat.com) wrote:
> On 10/28/2010 03:15 PM, Mandeep Singh Baines wrote:
> 
> >+/*
> >+ * Check low watermark used to prevent fscache thrashing during low memory.
> >+ */
> >+static int file_is_low(struct zone *zone, struct scan_control *sc)
> >+{
> >+	unsigned long pages_min, active, inactive;
> >+
> >+	if (!scanning_global_lru(sc))
> >+		return false;
> >+
> >+	pages_min = min_filelist_kbytes>>  (PAGE_SHIFT - 10);
> >+	active = zone_page_state(zone, NR_ACTIVE_FILE);
> >+	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> >+
> >+	return ((active + inactive)<  pages_min);
> >+}
> 
> This is problematic.
> 

Yeah, just sending this out as an RFC for now in order to draw attention
to the issue. But the patch does solve our problem really well and would
probably help out for similar applications.

> It is quite possible for a NUMA system to have one zone
> legitimately low on page cache (because all the binaries
> and libraries got paged in on another NUMA node), without
> the system being anywhere near out of memory.
> 
> This patch looks like it could cause a false OOM kill
> in that scenario.
> 
> At the very minimum, you'd have to check that the system
> is low on page cache globally, not just locally.
> 
> You do point out a real problem though, and it would be
> nice to find a generic solution to it...
> 

Here's another patch I was playing with that helped but wasn't quite
as bulletproof or as easy to reason about as min_filelist_kbytes.

---

[PATCH] vmscan: add a configurable inactive_file_ratio

This patch adds a new tuning option which can control how aggressively
the working set is protected. By aggressively protecting the working set,
one sees less page faults and more responsiveness on low memory netbook
systems.

In commit 56e49d21, "vmscan: evict use-once pages first", Rik Van Riel,
added an inactive_file_is_low method which would protect the working
set by only scanning the file_active_list when there were more active
pages than inactive. This patch makes the ratio configurable via a
sysctl. The ratio controls how aggressively we protect the working
set and indirectly controls the working set time constant: the period
of time over which we examine whats in the working set.

Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 include/linux/mm.h |    2 ++
 kernel/sysctl.c    |   12 ++++++++++++
 mm/vmscan.c        |    7 ++++++-
 3 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..6f6db8e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -36,6 +36,8 @@ extern int sysctl_legacy_va_layout;
 #define sysctl_legacy_va_layout 0
 #endif
 
+extern int inactive_file_ratio;
+
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3a45c22..1fe3a81 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1320,6 +1320,18 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "inactive_file_ratio",
+		.data		= &inactive_file_ratio,
+		.maxlen		= sizeof(inactive_file_ratio),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
+
 
 /*
  * NOTE: do not add new entries to this table unless you have read
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0984dee..cdae972 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -130,6 +130,11 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
+/*
+ * Only start shrinking active file list when inactive is below this percentage.
+ */
+int inactive_file_ratio = 50;
+
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
@@ -1556,7 +1561,7 @@ static int inactive_file_is_low_global(struct zone *zone)
 	active = zone_page_state(zone, NR_ACTIVE_FILE);
 	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
 
-	return (active > inactive);
+	return ((inactive * 100)/(inactive + active) < inactive_file_ratio);
 }
 
 /**
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
