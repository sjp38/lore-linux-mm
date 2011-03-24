Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 57E0F8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:12:34 -0400 (EDT)
Date: Thu, 24 Mar 2011 14:12:14 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: + mm-add-vm-counters-for-transparent-hugepages.patch added to
 -mm tree
Message-ID: <20110324131214.GB2310@cmpxchg.org>
References: <201103050008.p2508U6M011956@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201103050008.p2508U6M011956@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ak@linux.intel.com, aarcange@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 04, 2011 at 04:08:30PM -0800, akpm@linux-foundation.org wrote:
> diff -puN mm/vmstat.c~mm-add-vm-counters-for-transparent-hugepages mm/vmstat.c
> --- a/mm/vmstat.c~mm-add-vm-counters-for-transparent-hugepages
> +++ a/mm/vmstat.c
> @@ -946,6 +946,14 @@ static const char * const vmstat_text[] 
>  	"unevictable_pgs_stranded",
>  	"unevictable_pgs_mlockfreed",
>  #endif
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	"thp_fault_alloc",
> +	"thp_fault_fallback",
> +	"thp_collapse_alloc",
> +	"thp_collapse_alloc_failed",
> +	"thp_split",
> +#endif
>  };

This first #endif in this hunk does not belong to the unevictable
counters, as one could be easily trapped into assuming, it's the
higher level 'vm event counters enabled'.  The thp event name strings
should be part of that block as well.

Since there are no zone stat items after the event counters, the only
misbehaviour for now would be having those strings defined on a THP &&
!VM_EVENT_COUNTERS config.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/vmstat.c b/mm/vmstat.c
index fca991c..5db50e8 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -959,7 +959,6 @@ static const char * const vmstat_text[] = {
 	"unevictable_pgs_cleared",
 	"unevictable_pgs_stranded",
 	"unevictable_pgs_mlockfreed",
-#endif
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	"thp_fault_alloc",
@@ -968,6 +967,8 @@ static const char * const vmstat_text[] = {
 	"thp_collapse_alloc_failed",
 	"thp_split",
 #endif
+
+#endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
