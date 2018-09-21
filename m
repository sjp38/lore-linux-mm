Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53F138E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 09:26:44 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id v1-v6so2457655wmh.4
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 06:26:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o6-v6sor4220764wmg.12.2018.09.21.06.26.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 06:26:42 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v2 2/4] mm/memory_hotplug: Tidy up node_states_clear_node
Date: Fri, 21 Sep 2018 15:26:32 +0200
Message-Id: <20180921132634.10103-3-osalvador@techadventures.net>
In-Reply-To: <20180921132634.10103-1-osalvador@techadventures.net>
References: <20180921132634.10103-1-osalvador@techadventures.net>
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
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
---
 mm/memory_hotplug.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 63facfc57224..561c44761f95 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1582,12 +1582,10 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
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
