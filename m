Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2D86B006E
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:34 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so1814288pab.10
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:33 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so1796452pab.6
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:31 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 14/14] vrange: Add vmstat counter about purged page
Date: Wed,  2 Oct 2013 17:51:43 -0700
Message-Id: <1380761503-14509-15-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch adds the number of purged page in vmstat so admin can see
how many of volatile pages are discarded by VM until now.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/vm_event_item.h |  2 ++
 mm/vmstat.c                   |  2 ++
 mm/vrange.c                   | 10 ++++++++++
 3 files changed, 14 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index bd6cf61..c4aea92 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,6 +25,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		PGDISCARD_DIRECT,
+		PGDISCARD_KSWAPD,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 20c2ef4..4f35f46 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -756,6 +756,8 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pgdiscard_direct",
+	"pgdiscard_kswapd",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
diff --git a/mm/vrange.c b/mm/vrange.c
index c30e3dd..8931fab 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -894,6 +894,10 @@ int discard_vpage(struct page *page)
 
 		if (page_freeze_refs(page, 1)) {
 			unlock_page(page);
+			if (current_is_kswapd())
+				count_vm_event(PGDISCARD_KSWAPD);
+			else
+				count_vm_event(PGDISCARD_DIRECT);
 			return 0;
 		}
 	}
@@ -1144,6 +1148,12 @@ static int discard_vrange(struct vrange *vrange)
 		ret = __discard_vrange_file(mapping, vrange, &nr_discard);
 	}
 
+	if (!ret) {
+		if (current_is_kswapd())
+			count_vm_events(PGDISCARD_KSWAPD, nr_discard);
+		else
+			count_vm_events(PGDISCARD_DIRECT, nr_discard);
+	}
 out:
 	__vroot_put(vroot);
 	return nr_discard;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
