Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id A65326B0175
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:54:48 -0400 (EDT)
Date: Thu, 13 Sep 2012 15:54:50 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
Message-ID: <20120913155450.7634148f@cuia.bos.redhat.com>
In-Reply-To: <20120913154824.44cc0e28@cuia.bos.redhat.com>
References: <20120822124032.GA12647@alpha.arachsys.com>
	<5034D437.8070106@redhat.com>
	<20120822144150.GA1400@alpha.arachsys.com>
	<5034F8F4.3080301@redhat.com>
	<20120825174550.GA8619@alpha.arachsys.com>
	<50391564.30401@redhat.com>
	<20120826105803.GA377@alpha.arachsys.com>
	<20120906092039.GA19234@alpha.arachsys.com>
	<20120912105659.GA23818@alpha.arachsys.com>
	<20120912122541.GO11266@suse.de>
	<20120912164615.GA14173@alpha.arachsys.com>
	<20120913154824.44cc0e28@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Mel Gorman <mgorman@suse.de>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

Argh. And of course I send out the version from _before_ the compile test,
instead of the one after! I am not used to caffeine any more and have had
way too much tea...

---8<---

Make the "skip ahead" logic in compaction resistant to compaction
wrapping around to the end of the zone.  This can lead to less
efficient compaction when one thread has wrapped around to the
end of the zone, and another simultaneous compactor has not done
so yet. However, it should ensure that we do not suffer quadratic
behaviour any more.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Richard Davies <richard@daviesmail.org>

diff --git a/mm/compaction.c b/mm/compaction.c
index 771775d..0656759 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -431,6 +431,24 @@ static bool suitable_migration_target(struct page *page)
 }
 
 /*
+ * We scan the zone in a circular fashion, starting at
+ * zone->compact_cached_free_pfn. Be careful not to skip if
+ * one compacting thread has just wrapped back to the end of the
+ * zone, but another thread has not.
+ */
+static bool compaction_may_skip(struct zone *zone,
+				struct compact_control *cc)
+{
+	if (!cc->wrapped && zone->compact_cached_free_pfn < cc->start_free_pfn)
+		return true;
+
+	if (cc->wrapped && zone->compact_cached_free_pfn > cc->start_free_pfn)
+		return true;
+
+	return false;
+}
+
+/*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
  */
@@ -471,13 +489,9 @@ static void isolate_freepages(struct zone *zone,
 
 		/*
 		 * Skip ahead if another thread is compacting in the area
-		 * simultaneously. If we wrapped around, we can only skip
-		 * ahead if zone->compact_cached_free_pfn also wrapped to
-		 * above our starting point.
+		 * simultaneously, and has finished with this page block.
 		 */
-		if (cc->order > 0 && (!cc->wrapped ||
-				      zone->compact_cached_free_pfn >
-				      cc->start_free_pfn))
+		if (cc->order > 0 && compaction_may_skip(zone, cc))
 			pfn = min(pfn, zone->compact_cached_free_pfn);
 
 		if (!pfn_valid(pfn))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
