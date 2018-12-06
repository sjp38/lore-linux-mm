Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B16F6B79B7
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 06:33:03 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q63so62414pfi.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 03:33:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i5si82610pfo.189.2018.12.06.03.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 03:33:02 -0800 (PST)
Subject: Patch "mm: hide incomplete nr_indirectly_reclaimable in /proc/zoneinfo" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Thu, 06 Dec 2018 12:31:55 +0100
In-Reply-To: <20181030174649.16778-1-guro@fb.com>
Message-ID: <1544095915189163@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kernel-team@fb.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, guro@fb.com, linux-mm@kvack.org, vbabka@suse.cz, yongqin.liu@linaro.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    mm: hide incomplete nr_indirectly_reclaimable in /proc/zoneinfo

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     mm-hide-incomplete-nr_indirectly_reclaimable-in-proc-zoneinfo.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From guro@fb.com  Thu Dec  6 12:12:35 2018
From: Roman Gushchin <guro@fb.com>
Date: Tue, 30 Oct 2018 17:48:25 +0000
Subject: mm: hide incomplete nr_indirectly_reclaimable in /proc/zoneinfo
To: "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: Yongqin Liu <yongqin.liu@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, "Roman Gushchin" <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Message-ID: <20181030174649.16778-1-guro@fb.com>

From: Roman Gushchin <guro@fb.com>

[fixed differently upstream, this is a work-around to resolve it for 4.14.y]

Yongqin reported that /proc/zoneinfo format is broken in 4.14
due to commit 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable
in /proc/vmstat")

Node 0, zone      DMA
  per-node stats
      nr_inactive_anon 403
      nr_active_anon 89123
      nr_inactive_file 128887
      nr_active_file 47377
      nr_unevictable 2053
      nr_slab_reclaimable 7510
      nr_slab_unreclaimable 10775
      nr_isolated_anon 0
      nr_isolated_file 0
      <...>
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   6022
      nr_written   5985
                   74240
      ^^^^^^^^^^
  pages free     131656

The problem is caused by the nr_indirectly_reclaimable counter,
which is hidden from the /proc/vmstat, but not from the
/proc/zoneinfo. Let's fix this inconsistency and hide the
counter from /proc/zoneinfo exactly as from /proc/vmstat.

BTW, in 4.19+ the counter has been renamed and exported by
the commit b29940c1abd7 ("mm: rename and change semantics of
nr_indirectly_reclaimable_bytes"), so there is no such a problem
anymore.

Cc: <stable@vger.kernel.org> # 4.14.x-4.18.x
Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 mm/vmstat.c |    4 ++++
 1 file changed, 4 insertions(+)

--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1500,6 +1500,10 @@ static void zoneinfo_show_print(struct s
 	if (is_zone_first_populated(pgdat, zone)) {
 		seq_printf(m, "\n  per-node stats");
 		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+			/* Skip hidden vmstat items. */
+			if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+					 NR_VM_NUMA_STAT_ITEMS] == '\0')
+				continue;
 			seq_printf(m, "\n      %-12s %lu",
 				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
 				NR_VM_NUMA_STAT_ITEMS],


Patches currently in stable-queue which might be from guro@fb.com are

queue-4.14/mm-hide-incomplete-nr_indirectly_reclaimable-in-proc-zoneinfo.patch
