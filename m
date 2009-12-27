Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EF6F360021B
	for <linux-mm@kvack.org>; Sat, 26 Dec 2009 21:09:11 -0500 (EST)
Received: by fxm28 with SMTP id 28so902240fxm.6
        for <linux-mm@kvack.org>; Sat, 26 Dec 2009 18:09:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v4 0/4] cgroup notifications API and memory thresholds
Date: Sun, 27 Dec 2009 04:08:58 +0200
Message-Id: <cover.1261858972.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

This patchset introduces eventfd-based API for notifications in cgroups and
implements memory notifications on top of it.

It uses statistics in memory controler to track memory usage.

Output of time(1) on building kernel on tmpfs:

Root cgroup before changes:
	make -j2  506.37 user 60.93s system 193% cpu 4:52.77 total
Non-root cgroup before changes:
	make -j2  507.14 user 62.66s system 193% cpu 4:54.74 total
Root cgroup after changes (0 thresholds):
	make -j2  507.13 user 62.20s system 193% cpu 4:53.55 total
Non-root cgroup after changes (0 thresholds):
	make -j2  507.70 user 64.20s system 193% cpu 4:55.70 total
Root cgroup after changes (1 thresholds, never crossed):
	make -j2  506.97 user 62.20s system 193% cpu 4:53.90 total
Non-root cgroup after changes (1 thresholds, never crossed):
	make -j2  507.55 user 64.08s system 193% cpu 4:55.63 total

Any comments?

v3 -> v4:
 - documentation.

v2 -> v3:
 - remove [RFC];
 - rebased to 2.6.33-rc2;
 - fixes based on comments;
 - fixed potential race on event removing;
 - use RCU-protected arrays to track trasholds.

v1 -> v2:
 - use statistics instead of res_counter to track resource usage;
 - fix bugs with locking.

v0 -> v1:
 - memsw support implemented.

Kirill A. Shutemov (4):
  cgroup: implement eventfd-based generic API for notifications
  memcg: extract mem_group_usage() from mem_cgroup_read()
  memcg: rework usage of stats by soft limit
  memcg: implement memory thresholds

 Documentation/cgroups/cgroups.txt |   20 ++
 Documentation/cgroups/memory.txt  |   19 ++-
 include/linux/cgroup.h            |   24 +++
 kernel/cgroup.c                   |  208 ++++++++++++++++++++++-
 mm/memcontrol.c                   |  348 ++++++++++++++++++++++++++++++++++---
 5 files changed, 590 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
