Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id F0D936B02AF
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 13:49:51 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id c123-v6so9372464ywf.9
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 10:49:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 1-v6si14154228ywk.98.2018.10.30.10.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 10:49:50 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: hide incomplete nr_indirectly_reclaimable in
 /proc/zoneinfo
Date: Tue, 30 Oct 2018 17:48:25 +0000
Message-ID: <20181030174649.16778-1-guro@fb.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: Yongqin Liu <yongqin.liu@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Roman
 Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

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
Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vms=
tat")
Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/vmstat.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 527ae727d547..6389e876c7a7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1500,6 +1500,10 @@ static void zoneinfo_show_print(struct seq_file *m, =
pg_data_t *pgdat,
 	if (is_zone_first_populated(pgdat, zone)) {
 		seq_printf(m, "\n  per-node stats");
 		for (i =3D 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+			/* Skip hidden vmstat items. */
+			if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+					 NR_VM_NUMA_STAT_ITEMS] =3D=3D '\0')
+				continue;
 			seq_printf(m, "\n      %-12s %lu",
 				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
 				NR_VM_NUMA_STAT_ITEMS],
--=20
2.17.2
