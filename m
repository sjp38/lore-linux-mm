Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5576B23AC
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:32:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s18-v6so1390180wmc.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:32:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5-v6sor338492wme.55.2018.08.22.02.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 02:32:33 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH 2/5] mm/memory_hotplug: Avoid node_set/clear_state(N_HIGH_MEMORY) when !CONFIG_HIGHMEM
Date: Wed, 22 Aug 2018 11:32:23 +0200
Message-Id: <20180822093226.25987-3-osalvador@techadventures.net>
In-Reply-To: <20180822093226.25987-1-osalvador@techadventures.net>
References: <20180822093226.25987-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, malat@debian.org, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Currently, when !CONFIG_HIGHMEM, status_change_nid_high is being set
to status_change_nid_normal, but on such systems, N_HIGH_MEMORY equals
N_NORMAL_MEMORY.
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
index 4a89915e1467..1cfd0b5a9cc7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -724,7 +724,11 @@ static void node_states_check_changes_online(unsigned long nr_pages,
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
@@ -1547,7 +1551,11 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
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
