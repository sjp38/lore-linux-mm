Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 390638E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 09:26:43 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 199-v6so2450206wme.1
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 06:26:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e14-v6sor20062277wrv.6.2018.09.21.06.26.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 06:26:41 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v2 0/4] Refactor node_states_check_changes_online/offline
Date: Fri, 21 Sep 2018 15:26:30 +0200
Message-Id: <20180921132634.10103-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, yasu.isimatu@gmail.com, malat@debian.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

v1 -> v2:
        - Address feedback from Pavel
        - Re-write patch4 his way, as it is better
        - Add Reviewed-by from Pavel

---

This patchset refactors/clean ups node_states_check_changes_online/offline
functions together with node_states_set/clear_node.

The main reason behind this patchset is that currently, these
functions are suboptimal and confusing.

For example, they contain wrong statements like:

if (N_MEMORY == N_NORMAL_MEMORY)
if (N_MEMORY =! N_NORMAL_MEMORY)
if (N_MEMORY != N_HIGH_MEMORY)
if (N_MEMORY == N_HIGH_MEMORY)

These comparasions are wrong, as N_MEMORY will never be equal
to either N_NORMAL_MEMORY or N_HIGH_MEMORY.
Although the statements do not "affect" the flow because in the way
they are placed, they are completely wrong and confusing.

I caught another misuse of this in [1].

Another thing that this patchset addresses is the fact that
some functions get called twice, or even unconditionally, without
any need.

Examples of this are:

- node_states_set_node()->node_set_state(node, N_MEMORY)

* node_states_set_node() gets called whenever we online pages,
  so we end up calling node_set_state(node, N_MEMORY) everytime.
  To avoid this, we should check if the node is already in node_state[N_MEMORY].

- node_states_set_node()->node_set_state(node, N_HIGH_MEMORY)

* On !CONFIG_HIGH_MEMORY, N_HIGH_MEMORY == N_NORMAL_MEMORY,
  but the current code sets:
  status_change_nid_high = status_change_nid_normal
  This means that we will call node_set_state(node, N_NORMAL_MEMORY) twice.
  The fix here is to set status_change_nid_normal = -1 on such systems,
  so we skip the second call.

[1] https://patchwork.kernel.org/patch/10579155/

Oscar Salvador (4):
  mm/memory_hotplug: Spare unnecessary calls to node_set_state
  mm/memory_hotplug: Tidy up node_states_clear_node
  mm/memory_hotplug: Simplify node_states_check_changes_online
  mm/memory_hotplug: Clean up node_states_check_changes_offline

 mm/memory_hotplug.c | 146 ++++++++++++++--------------------------------------
 1 file changed, 40 insertions(+), 106 deletions(-)

-- 
2.13.6
