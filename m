Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2D096B23AB
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:32:33 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z77-v6so1272434wrb.20
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:32:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v17-v6sor386721wrd.55.2018.08.22.02.32.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 02:32:32 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH 0/5] Clean up node_states_check_changes_online/offline
Date: Wed, 22 Aug 2018 11:32:21 +0200
Message-Id: <20180822093226.25987-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, malat@debian.org, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patchset clean ups node_states_check_changes_online/offline
functions together with node_states_set/clear_node functions.

The main reason behind this patchset is that currently, these
functions are suboptimal and confusing.

For example, they contain wrong statements like:

if (N_MEMORY == N_NORMAL_MEMORY)
if (N_MEMORY =! N_NORMAL_MEMORY)
if (N_MEMORY != N_HIGH_MEMORY)
if (N_MEMORY == N_HIGH_MEMORY)

At least, I could not find anywhere where N_NORMAL_MEMORY gets
assigned to N_MEMORY, or the other way around.
Neither for the N_HIGH_MEMORY case.

My rough guess is that all that was meant to compare
N_NORMAL_MEMORY to N_HIGH_MEMORY, to see if we were on
CONFIG_HIGHMEM systems.

This went unnoticed because the if statements never got triggered,
so they were always silent.
For instance, let us take a look at node_states_clear_node

...
if ((N_MEMORY != N_NORMAL_MEMORY) &&
    (arg->status_change_nid_high >= 0))
        node_clear_state(node, N_HIGH_MEMORY);

if ((N_MEMORY != N_HIGH_MEMORY) &&
    (arg->status_change_nid >= 0))
        node_clear_state(node, N_MEMORY);
...

Since N_MEMORY will never be equal to neither N_HIGH_MEMORY nor
N_NORMAL_MEMORY, this justs proceeds normally.

Another case is node_states_check_changes_offline:

...
zone_last = ZONE_HIGHMEM;
if (N_MEMORY == N_HIGH_MEMORY)
        zone_last = ZONE_MOVABLE;
...

Since N_MEMORY will never be equal to N_HIGH_MEMORY, zone_last will
never be set to ZONE_MOVABLE.
But this is fine as the code works without that.

After I found all this, I tried to re-write the code in a more
understandable way, and I got rid of these confusing parts
on the way.

Another reason for this patchset is that there are some functions that are
called unconditionally when they should only be called under certain
conditions.

That is the case for:

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


I tried it out on x86_64 so far and everything worked.
But I would like to get feedback on this since I could be
missing something.

Oscar Salvador (5):
  mm/memory_hotplug: Spare unnecessary calls to node_set_state
  mm/memory_hotplug: Avoid node_set/clear_state(N_HIGH_MEMORY) when
    !CONFIG_HIGHMEM
  mm/memory_hotplug: Simplify node_states_check_changes_online
  mm/memory_hotplug: Tidy up node_states_clear_node
  mm/memory_hotplug: Simplify node_states_check_changes_offline

 mm/memory_hotplug.c | 146 +++++++++++++++++++++-------------------------------
 1 file changed, 60 insertions(+), 86 deletions(-)

-- 
2.13.6
