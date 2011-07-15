Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCFC6B007E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 07:14:01 -0400 (EDT)
Message-Id: <cover.1310732789.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Fri, 15 Jul 2011 14:26:29 +0200
Subject: [PATCH 0/2 v2 ] memcg: oom locking updates
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

Hi,
this a second version of a small patch series has two patches. While the
first one is a bug fix the other one is a cleanup which might be a bit
controversial and I have no problems to drop it if there is a resistance
against it.

I have experienced a serious starvation due the way how we handle
oom_lock counter currently and the first patch aims at fixing it.  The
issue can be reproduced quite easily on a machine with many CPUs and
many tasks fighting for a memory (e.g. 16CPU machine and 100 tasks each
allocating and touching 10MB anonymous memory in a tight loop within a
200MB group with swapoff and mem_control=0)

The other patch changes memcg_oom_mutext to spinlock. I have no hard
numbers to support why spinlock is better than mutex but it feels like
it is more suitable for the code paths we are using it at the moment. It
should also reduce context switches count for many contenders.

Changes since v1:
- reimplemented the lock in cooperation with Kamezawa to have 2 two
  entities for checking of the current oom state. oom_lock guarantees
  a single OOM in the current subtree and under_oom marks all groups
  that are under oom for oom notification
- udpated changelogs with test cases

Michal Hocko (2):
  memcg: make oom_lock 0 and 1 based rather than coutner
  memcg: change memcg_oom_mutex to spinlock

 mm/memcontrol.c |  104 +++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 79 insertions(+), 25 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
