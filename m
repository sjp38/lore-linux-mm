Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4E88E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:08:41 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i11-v6so5195641wrr.10
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:08:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y191-v6sor9532365wmc.9.2018.09.19.03.08.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 03:08:40 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 2/5] mm/memory_hotplug: Avoid node_set/clear_state(N_HIGH_MEMORY) when !CONFIG_HIGHMEM
Date: Wed, 19 Sep 2018 12:08:16 +0200
Message-Id: <20180919100819.25518-3-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-1-osalvador@techadventures.net>
References: <20180919100819.25518-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, yasu.isimatu@gmail.com, malat@debian.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Currently, when !CONFIG_HIGHMEM, status_change_nid_high is being set
to status_change_nid_normal, but on such systems N_HIGH_MEMORY falls
back to N_NORMAL_MEMORY.
That means that if status_change_nid_normal is not -1,
we will perform two calls to node_set_state for the same memory type.

Set status_change_nid_high to -1 for !CONFIG_HIGHMEM, so we skip the
double call in node_states_set_node.

The same goes for node_clear_state.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 63facfc57224..c2c7359bd0a7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -731,7 +731,11 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 	else
 		arg->status_change_nid_high = -1;
 #else
-	arg->status_change_nid_high = arg->status_change_nid_normal;
+	/*
+	 * When !CONFIG_HIGHMEM, N_HIGH_MEMORY equals N_NORMAL_MEMORY
+	 * so setting the node for N_NORMAL_MEMORY is enough.
+	 */
+	arg->status_change_nid_high = -1;
 #endif
 
 	/*
@@ -1555,7 +1559,11 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 	else
 		arg->status_change_nid_high = -1;
 #else
-	arg->status_change_nid_high = arg->status_change_nid_normal;
+	/*
+	 * When !CONFIG_HIGHMEM, N_HIGH_MEMORY equals N_NORMAL_MEMORY
+	 * so clearing the node for N_NORMAL_MEMORY is enough.
+	 */
+	arg->status_change_nid_high = -1;
 #endif
 
 	/*
-- 
2.13.6
