Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id D563C6B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 15:34:12 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id b67so47544679qgb.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 12:34:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si11407132qhc.9.2016.02.11.12.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 12:34:12 -0800 (PST)
Date: Thu, 11 Feb 2016 15:34:04 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: Unhelpful caching decisions, possibly related to
 active/inactive sizing
Message-ID: <20160211153404.42055b27@cuia.usersys.redhat.com>
In-Reply-To: <20160209224256.GA29872@cmpxchg.org>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
	<20160209224256.GA29872@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andres Freund <andres@anarazel.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, 9 Feb 2016 17:42:56 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Feb 09, 2016 at 05:52:40PM +0100, Andres Freund wrote:

> > Rik asked me about active/inactive sizing in /proc/meminfo:
> > Active:          7860556 kB
> > Inactive:        5395644 kB
> > Active(anon):    2874936 kB
> > Inactive(anon):   432308 kB
> > Active(file):    4985620 kB
> > Inactive(file):  4963336 kB

> Yes, a generous minimum size of the inactive list made sense when it
> was the exclusive staging area to tell use-once pages from use-many
> pages. Now that we have refault information to detect use-many with
> arbitrary inactive list size, this minimum is no longer reasonable.
> 
> The new minimum should be smaller, but big enough for applications to
> actually use the data in their pages between fault and eviction
> (i.e. it needs to take the aggregate readahead window into account),
> and big enough for active pages that are speculatively challenged
> during workingset changes to get re-activated without incurring IO.
> 
> However, I don't think it makes sense to dynamically adjust the
> balance between the active and the inactive cache during refaults.

Johannes, does this patch look ok to you?

Andres, does this patch work for you?

-----8<-----
Subject: mm,vmscan: reduce size of inactive file list

The inactive file list should still be large enough to contain
readahead windows and freshly written file data, but it no
longer is the only source for detecting multiple accesses to
file pages. The workingset refault measurement code causes
recently evicted file pages that get accessed again after a
shorter interval to be promoted directly to the active list.

With that mechanism in place, we can afford to (on a larger
system) dedicate more memory to the active file list, so we
can actually cache more of the frequently used file pages
in memory, and not have them pushed out by streaming writes,
once-used streaming file reads, etc.

This can help things like database workloads, where only
half the page cache can currently be used to cache the
database working set. This patch automatically increases
that fraction on larger systems, using the same ratio that
has already been used for anonymous memory.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Andres Freund <andres@anarazel.de>
---
 mm/vmscan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb3dd37ccd7c..0a316c41bf80 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1928,13 +1928,14 @@ static inline bool inactive_anon_is_low(struct lruvec *lruvec)
  */
 static bool inactive_file_is_low(struct lruvec *lruvec)
 {
+	struct zone *zone = lruvec_zone(lruvec);
 	unsigned long inactive;
 	unsigned long active;
 
 	inactive = get_lru_size(lruvec, LRU_INACTIVE_FILE);
 	active = get_lru_size(lruvec, LRU_ACTIVE_FILE);
 
-	return active > inactive;
+	return inactive * zone->inactive_ratio < active;
 }
 
 static bool inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
