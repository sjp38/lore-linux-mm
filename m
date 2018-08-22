Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 411B86B23B1
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:32:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s18-v6so1401802wmh.0
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:32:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g40-v6sor393760wrd.15.2018.08.22.02.32.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 02:32:34 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH 4/5] mm/memory_hotplug: Tidy up node_states_clear_node
Date: Wed, 22 Aug 2018 11:32:25 +0200
Message-Id: <20180822093226.25987-5-osalvador@techadventures.net>
In-Reply-To: <20180822093226.25987-1-osalvador@techadventures.net>
References: <20180822093226.25987-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, malat@debian.org, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

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
This is wrong, so let us get rid of it.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0f2cf6941224..006a7b817724 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1564,12 +1564,10 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
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
