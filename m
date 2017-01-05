Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7ACF6B0260
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:16:16 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so119822572wjb.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:16:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jv4si84866386wjb.64.2017.01.05.02.16.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:16:15 -0800 (PST)
Date: Thu, 5 Jan 2017 11:16:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20170105101613.GG21618@dhcp22.suse.cz>
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-5-mhocko@kernel.org>
 <20170105060458.GC24371@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105060458.GC24371@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 05-01-17 15:04:58, Minchan Kim wrote:
> On Wed, Jan 04, 2017 at 11:19:39AM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> > from is file or anonymous but we do not know which LRU this is.
> > 
> > It is useful to know whether the list is active or inactive, since we
> > are using the same function to isolate pages from both of them and it's
> > hard to distinguish otherwise.
> > 
> > Chaneges since v1
> > - drop LRU_ prefix from names and use lowercase as per Vlastimil
> > - move and convert show_lru_name to mmflags.h EM magic as per Vlastimil
> > 
> > Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> > Acked-by: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  include/trace/events/mmflags.h |  8 ++++++++
> >  include/trace/events/vmscan.h  | 12 ++++++------
> >  mm/vmscan.c                    |  2 +-
> >  3 files changed, 15 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> > index aa4caa6914a9..6172afa2fd82 100644
> > --- a/include/trace/events/mmflags.h
> > +++ b/include/trace/events/mmflags.h
> > @@ -240,6 +240,13 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
> >  	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
> >  				EMe(ZONE_MOVABLE,"Movable")
> >  
> > +#define LRU_NAMES		\
> > +		EM (LRU_INACTIVE_ANON, "inactive_anon") \
> > +		EM (LRU_ACTIVE_ANON, "active_anon") \
> > +		EM (LRU_INACTIVE_FILE, "inactive_file") \
> > +		EM (LRU_ACTIVE_FILE, "active_file") \
> > +		EMe(LRU_UNEVICTABLE, "unevictable")
> > +
> >  /*
> >   * First define the enums in the above macros to be exported to userspace
> >   * via TRACE_DEFINE_ENUM().
> > @@ -253,6 +260,7 @@ COMPACTION_STATUS
> >  COMPACTION_PRIORITY
> >  COMPACTION_FEEDBACK
> >  ZONE_TYPE
> > +LRU_NAMES
> >  
> >  /*
> >   * Now redefine the EM() and EMe() macros to map the enums to the strings
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index 36c999f806bf..7ec59e0432c4 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -277,9 +277,9 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
> >  		unsigned long nr_skipped,
> >  		unsigned long nr_taken,
> >  		isolate_mode_t isolate_mode,
> > -		int file),
> > +		int lru),
> 
> It may break trace-vmscan-postprocess.pl. Other than that,

I wasn't aware of the script. And you are right it will break it. The
following should fix it. Btw. shrink_inactive_list tracepoint changes
will to be synced as well. I do not speak perl much but the following
should just work (untested yet).
---
diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index 8f961ef2b457..ba976805853a 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -112,8 +112,8 @@ my $regex_direct_end_default = 'nr_reclaimed=([0-9]*)';
 my $regex_kswapd_wake_default = 'nid=([0-9]*) order=([0-9]*)';
 my $regex_kswapd_sleep_default = 'nid=([0-9]*)';
 my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*)';
-my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) file=([0-9]*)';
-my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) zid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
+my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) classzone_idx=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_skipped=([0-9]*) nr_taken=([0-9]*) lru=([a-z_]*)';
+my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) nr_dirty=([0-9]*) nr_writeback=([0-9]*) nr_congested=([0-9]*) nr_immediate=([0-9]*) nr_activate=([0-9]*) nr_ref_keep=([0-9]*) nr_unmap_fail=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
 my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
 my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) flags=([A-Z_|]*)';
 
@@ -205,15 +205,15 @@ $regex_wakeup_kswapd = generate_traceevent_regex(
 $regex_lru_isolate = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_isolate",
 			$regex_lru_isolate_default,
-			"isolate_mode", "order",
-			"nr_requested", "nr_scanned", "nr_taken",
-			"file");
+			"isolate_mode", "classzone_idx", "order",
+			"nr_requested", "nr_scanned", "nr_skipped", "nr_taken",
+			"lru");
 $regex_lru_shrink_inactive = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_inactive",
 			$regex_lru_shrink_inactive_default,
-			"nid", "zid",
-			"nr_scanned", "nr_reclaimed", "priority",
-			"flags");
+			"nid", "nr_scanned", "nr_reclaimed", "nr_dirty", "nr_writeback",
+			"nr_congested", "nr_immediate", "nr_activate", "nr_ref_keep",
+			"nr_unmap_fail", "priority", "flags");
 $regex_lru_shrink_active = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_active",
 			$regex_lru_shrink_active_default,
@@ -381,8 +381,8 @@ sub process_events {
 				next;
 			}
 			my $isolate_mode = $1;
-			my $nr_scanned = $4;
-			my $file = $6;
+			my $nr_scanned = $5;
+			my $file = $8;
 
 			# To closer match vmstat scanning statistics, only count isolate_both
 			# and isolate_inactive as scanning. isolate_active is rotation
@@ -391,7 +391,7 @@ sub process_events {
 			# isolate_both     == 3
 			if ($isolate_mode != 2) {
 				$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
-				if ($file == 1) {
+				if ($file =~ /_file/) {
 					$perprocesspid{$process_pid}->{HIGH_NR_FILE_SCANNED} += $nr_scanned;
 				} else {
 					$perprocesspid{$process_pid}->{HIGH_NR_ANON_SCANNED} += $nr_scanned;
@@ -406,8 +406,8 @@ sub process_events {
 				next;
 			}
 
-			my $nr_reclaimed = $4;
-			my $flags = $6;
+			my $nr_reclaimed = $3;
+			my $flags = $12;
 			my $file = 0;
 			if ($flags =~ /RECLAIM_WB_FILE/) {
 				$file = 1;
 
> Acked-by: Minchan Kim <minchan@kernel.org>

Thanks
 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
