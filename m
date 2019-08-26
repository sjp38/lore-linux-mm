Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01D42C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C0EE2070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="Jsoj0/fX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C0EE2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B17F76B000D; Mon, 26 Aug 2019 15:36:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A277A6B0010; Mon, 26 Aug 2019 15:36:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0446B0266; Mon, 26 Aug 2019 15:36:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0196.hostedemail.com [216.40.44.196])
	by kanga.kvack.org (Postfix) with ESMTP id 6A24A6B000D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:54 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1B521180AD7C3
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:54 +0000 (UTC)
X-FDA: 75865586748.24.star94_1f0b02abf5656
X-HE-Tag: star94_1f0b02abf5656
X-Filterd-Recvd-Size: 12057
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:53 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 8C1D642A6BD;
	Mon, 26 Aug 2019 12:37:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848257;
	bh=Who4g7lElisyXvFR2DXEmjxe6bECx81sFNRmtx5D5wk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Jsoj0/fXEwbzAOANpT/OYSU2tfItPLBjSxjXfTrqxmY4zIN6HUgfUAu+b84FYYRTq
	 BZhhhRgslAa2HTcldir1ArL7/Ru0rIEx9lN5PD4xj2DS+L+LEGcT2G5bo6sasBKhop
	 W4ec1RyweG5MYxp99a3eSMvUtQxW6UUUmWi3UG/VJcIbkbx+y04VWkkfmb+lyjVugG
	 p8fR4mmA3IUDamKXBYWX7SXddx2oi0WyoeNGdcQsOJf15vEqiOLeylTFnEZMmNXS40
	 3TDQewHVGDyhU47+opcrs+sSh6RruGxHeue7D8F8bnkGqflaz4Vp90OTzrhlqZIvG9
	 UTVWJlVXU/m1Q==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 791D542A6B7;
	Mon, 26 Aug 2019 12:37:37 -0700 (PDT)
From: Edward Chron <echron@arista.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Shakeel Butt <shakeelb@google.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	colona@arista.com,
	Edward Chron <echron@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Subject: [PATCH 04/10] mm/oom_debug: Add ARP and ND Table Summary usage
Date: Mon, 26 Aug 2019 12:36:32 -0700
Message-Id: <20190826193638.6638-5-echron@arista.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190826193638.6638-1-echron@arista.com>
References: <20190826193638.6638-1-echron@arista.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adds config options and code to support printing ARP Table usage and or
Neighbour Discovery Table usage when an OOM event occurs. This summarized
information provides the memory usage for each table when configured.

Configuring these two OOM Debug Options
---------------------------------------
Two OOM debug options: CONFIG_DEBUG_OOM_ARP_TBL, CONFIG_DEBUG_OOM_ND_TBL
To get the output for both tables they both must be configured.
The ARP Table uses the CONFIG_DEBUG_OOM_ARP_TBL kernel config option
and the ND Table uses the CONFIG_DEBUG_OOM_ND_TBL kernel config option
both of which are found in the kernel config under the entries:
Kernel hacking, Memory Debugging, OOM Debugging entry. The ARP Table and
ND Table are configured there with the options: DEBUG_OOM_ARP_TBL and
DEBUG_OOM_ND_TBL respectively.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
The oom debugfs base directory is found at: /sys/kernel/debug/oom.
The oom debugfs for this option are: arp_table_summary_ and
nd_table_summary_ and there is just one enable file for each.

Either option may be disabled or re-enabled using the debugfs entry for
the OOM debug option. The debugfs file to enable the ARP Table option
is found at: /sys/kernel/debug/oom/arp_table_summary_enabled
Similarly, the debugfs file to enable the ND Table option is found at:
/sys/kernel/debug/oom/nd_table_summary_enabled
For either option their enabled file's value determines whether the
facility is enabled or disabled for that option. A value of 1 is enabled
(default) and a value of 0 is disabled. When configured the default
setting is set to enabled. Each option will produce 1 line of output.

Content and format of ARP and Neighbour Discovery Tables Summary Output
-----------------------------------------------------------------------
  One line of output each for ARP and ND that includes:
  - Table name
  - Table size (max # entries)
  - Key Length
  - Entry Size
  - Number of Entries
  - Last Flush (in seconds)
  - hash grows
  - entry allocations
  - entry destroys
  - Number lookups
  - Number of lookup hits
  - Resolution failures
  - Garbage Collection Forced Runs
  - Table Full
  - Proxy Queue Length

Sample Output:
-------------
Here is sample output for both the ARP table and ND table:

Jul 23 23:26:34 yuorsystem kernel: neighbour: Table: arp_tbl size:   256
 keyLen:  4 entrySize: 360 entries:     9 lastFlush:  1721s
 hGrows:     1 allocs:     9 destroys:     0 lookups:   204 hits:   199
 resFailed:    38 gcRuns/Forced: 111 /  0 tblFull:  0 proxyQlen:  0

Jul 23 23:26:34 yuorsystem kernel: neighbour: Table:  nd_tbl size:   128
 keyLen: 16 entrySize: 368 entries:     6 lastFlush:  1720s
 hGrows:     0 allocs:     7 destroys:     1 lookups:     0 hits:     0
 resFailed:     0 gcRuns/Forced: 110 /  0 tblFull:  0 proxyQlen:  0


Signed-off-by: Edward Chron <echron@arista.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 include/net/neighbour.h | 12 +++++++
 mm/Kconfig.debug        | 26 ++++++++++++++
 mm/oom_kill_debug.c     | 38 ++++++++++++++++++++
 net/core/neighbour.c    | 78 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 154 insertions(+)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 50a67bd6a434..35fdecff2724 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -569,4 +569,16 @@ static inline void neigh_update_is_router(struct nei=
ghbour *neigh, u32 flags,
 		*notify =3D 1;
 	}
 }
+
+#if defined(CONFIG_DEBUG_OOM_ARP_TBL) || defined(CONFIG_DEBUG_OOM_ND_TBL=
)
+/**
+ * Routine used to print arp table and neighbour table statistics.
+ * Output goes to dmesg along with all the other OOM related messages
+ * when the config options DEBUG_OOM_ARP_TBL and DEBUG_ND_TBL are set to
+ * yes, for the ARP table and Neighbour discovery table respectively.
+ */
+extern void neightbl_print_stats(const char * const tblname,
+				 struct neigh_table * const neightable);
+#endif /* CONFIG_DEBUG_OOM_ARP_TBL || CONFIG_DEBUG_OOM_ND_TBL */
+
 #endif
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index fcbc5f9aa146..fe4bb5ce0a6d 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -163,3 +163,29 @@ config DEBUG_OOM_TASKS_SUMMARY
 	  A value of 1 is enabled (default) and a value of 0 is disabled.
=20
 	  If unsure, say N.
+
+config DEBUG_OOM_ARP_TBL
+	bool "Debug OOM ARP Table"
+	depends on DEBUG_OOM
+	help
+	  When enabled, documents kernel memory usage by the ARP Table
+	  entries at the time of an OOM event. Output is one line of
+	  summarzied ARP Table usage. If configured it is enabled/disabled
+	  by setting the enabled file entry in the debugfs OOM interface
+	  at: /sys/kernel/debug/oom/arp_table_summary_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  If unsure, say N.
+
+config DEBUG_OOM_ND_TBL
+	bool "Debug OOM ND Table"
+	depends on DEBUG_OOM
+	help
+	  When enabled, documents kernel memory usage by the ND Table
+	  entries at the time of an OOM event. Output is one line of
+	  summarzied ND Table usage. If configured it is enabled/disabled
+	  by setting the enabled file entry in the debugfs OOM interface
+	  at: /sys/kernel/debug/oom/nd_table_summary_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  If unsure, say N.
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index 395b3307f822..c4a9117633fd 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -156,6 +156,16 @@
 #include <linux/sched/stat.h>
 #endif
=20
+#if defined(CONFIG_INET) && defined(CONFIG_DEBUG_OOM_ARP_TBL)
+#include <net/arp.h>
+#endif
+#if defined(CONFIG_IPV6) && defined(CONFIG_DEBUG_OOM_ND_TBL)
+#include <net/ndisc.h>
+#endif
+#if defined(CONFIG_DEBUG_OOM_ARP_TBL) || defined(CONFIG_DEBUG_OOM_ND_TBL=
)
+#include <net/neighbour.h>
+#endif
+
 #define OOMD_MAX_FNAME 48
 #define OOMD_MAX_OPTNAME 32
=20
@@ -192,6 +202,18 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "tasks_summary_",
 		.support_tpercent =3D false,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_ARP_TBL
+	{
+		.option_name	=3D "arp_table_summary_",
+		.support_tpercent =3D false,
+	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_ND_TBL
+	{
+		.option_name	=3D "nd_table_summary_",
+		.support_tpercent =3D false,
+	},
 #endif
 	{}
 };
@@ -203,6 +225,12 @@ enum oom_debug_options_index {
 #endif
 #ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
 	TASKS_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_ARP_TBL
+	ARP_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_ND_TBL
+	ND_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -351,6 +379,16 @@ u32 oom_kill_debug_oom_event_is(void)
 		oom_kill_debug_system_summary_prt();
 #endif
=20
+#if defined(CONFIG_INET) && defined(CONFIG_DEBUG_OOM_ARP_TBL)
+	if (oom_kill_debug_enabled(ARP_STATE))
+		neightbl_print_stats("arp_tbl", &arp_tbl);
+#endif
+
+#if defined(CONFIG_IPV6) && defined(CONFIG_DEBUG_OOM_ND_TBL)
+	if (oom_kill_debug_enabled(ND_STATE))
+		neightbl_print_stats("nd_tbl", &nd_tbl);
+#endif
+
 #ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
 	if (oom_kill_debug_enabled(TASKS_STATE))
 		oom_kill_debug_tasks_summary_print();
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f79e61c570ea..9f5a579542a9 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -3735,3 +3735,81 @@ static int __init neigh_init(void)
 }
=20
 subsys_initcall(neigh_init);
+
+#if defined(CONFIG_DEBUG_OOM_ARP_TBL) || defined(CONFIG_DEBUG_OOM_ND_TBL=
)
+void neightbl_print_stats(const char * const tblname,
+			  struct neigh_table * const tbl)
+{
+	struct neigh_hash_table *nht;
+	struct ndt_stats ndst;
+	u32 now;
+	u32 flush_delta;
+	u32 tblsize;
+	u16 key_len;
+	u16 entry_size;
+	u32 entries;
+	u32 last_flush;    /* delta to now in msecs */
+	u32 hash_shift;
+	u32 proxy_qlen;
+	int cpu;
+
+	read_lock_bh(&tbl->lock);
+	now =3D jiffies;
+	flush_delta =3D now - tbl->last_flush;
+
+	key_len =3D tbl->key_len;
+	if (tbl->entry_size)
+		entry_size =3D tbl->entry_size;
+	else
+		entry_size =3D ALIGN(offsetof(struct neighbour, primary_key) +
+				   key_len, NEIGH_PRIV_ALIGN);
+
+	entries =3D atomic_read(&tbl->entries);
+	if (entries =3D=3D 0)
+		goto out_tbl_unlock;
+
+	/* last flush was last_flush seconds ago */
+	last_flush =3D jiffies_to_msecs(flush_delta) / 1000;
+	proxy_qlen =3D tbl->proxy_queue.qlen;
+
+	rcu_read_lock_bh();
+	nht =3D rcu_dereference_bh(tbl->nht);
+	if (nht)
+		hash_shift =3D nht->hash_shift + 1;
+	rcu_read_unlock_bh();
+	if (!nht)
+		goto out_tbl_unlock;
+
+	memset(&ndst, 0, sizeof(ndst));
+	for_each_possible_cpu(cpu) {
+		struct neigh_statistics *st;
+
+		st =3D per_cpu_ptr(tbl->stats, cpu);
+		ndst.ndts_allocs		+=3D st->allocs;
+		ndst.ndts_destroys		+=3D st->destroys;
+		ndst.ndts_hash_grows		+=3D st->hash_grows;
+		ndst.ndts_res_failed		+=3D st->res_failed;
+		ndst.ndts_lookups		+=3D st->lookups;
+		ndst.ndts_hits			+=3D st->hits;
+		ndst.ndts_periodic_gc_runs	+=3D st->periodic_gc_runs;
+		ndst.ndts_forced_gc_runs	+=3D st->forced_gc_runs;
+		ndst.ndts_table_fulls		+=3D st->table_fulls;
+	}
+
+	read_unlock_bh(&tbl->lock);
+	tblsize =3D (1 << hash_shift) * sizeof(struct neighbour *);
+	if (tblsize > PAGE_SIZE)
+		tblsize =3D get_order(tblsize);
+
+	pr_info("Table:%7s size:%5u keyLen:%2hu entrySize:%3hu entries:%5u last=
Flush:%5us hGrows:%5llu allocs:%5llu destroys:%5llu lookups:%5llu hits:%5=
llu resFailed:%5llu gcRuns/Forced:%3llu / %2llu tblFull:%2llu proxyQlen:%=
2u\n",
+		tblname, tblsize, key_len, entry_size, entries, last_flush,
+		ndst.ndts_hash_grows, ndst.ndts_allocs, ndst.ndts_destroys,
+		ndst.ndts_lookups, ndst.ndts_hits, ndst.ndts_res_failed,
+		ndst.ndts_periodic_gc_runs, ndst.ndts_forced_gc_runs,
+		ndst.ndts_table_fulls, proxy_qlen);
+	return;
+
+out_tbl_unlock:
+	read_unlock_bh(&tbl->lock);
+}
+#endif /* CONFIG_DEBUG_OOM_ARP_TBL || CONFIG_DEBUG_OOM_ND_TBL */
--=20
2.20.1


