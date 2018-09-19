Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED8658E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:08:41 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g3-v6so2826643wrr.11
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:08:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10-v6sor15438814wrm.23.2018.09.19.03.08.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 03:08:40 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 3/5] mm/memory_hotplug: Tidy up node_states_clear_node
Date: Wed, 19 Sep 2018 12:08:17 +0200
Message-Id: <20180919100819.25518-4-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-1-osalvador@techadventures.net>
References: <20180919100819.25518-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, yasu.isimatu@gmail.com, malat@debian.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

node_states_clear has the following if statements:

if ((N_MEMORY != N_NORMAL_MEMORY) &&
    (arg->status_change_nid_high >= 0))
        ...

if ((N_MEMORY != N_HIGH_MEMORY) &&
    (arg->status_change_nid >= 0))
        ...

N_MEMORY can never be equal to neither N_NORMAL_MEMORY nor
N_HIGH_MEMORY.

Similar problem was found in [1].
Since this is wrong, let us get rid of it.

[1] https://patchwork.kernel.org/patch/10579155/

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c2c7359bd0a7..131c08106d54 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1590,12 +1590,10 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_normal >= 0)
 		node_clear_state(node, N_NORMAL_MEMORY);
 
-	if ((N_MEMORY != N_NORMAL_MEMORY) &&
-	    (arg->status_change_nid_high >= 0))
+	if (arg->status_change_nid_high >= 0)
 		node_clear_state(node, N_HIGH_MEMORY);
 
-	if ((N_MEMORY != N_HIGH_MEMORY) &&
-	    (arg->status_change_nid >= 0))
+	if (arg->status_change_nid >= 0)
 		node_clear_state(node, N_MEMORY);
 }
 
-- 
2.13.6
