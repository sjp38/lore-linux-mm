Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 95FB06B007E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 08:59:53 -0400 (EDT)
Message-Id: <cover.1310561078.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Wed, 13 Jul 2011 14:44:38 +0200
Subject: [PATCH 0/2] memcg: oom locking updates
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

Hi,
this small patch series has two patches. While the first one is a bug
fix the other one is a cleanup which might be a bit controversial.

I have experienced a serious starvation due the way how we handle
oom_lock counter currently and the first patch aims at fixing it.  The
issue can be reproduced quite easily on a machine with many CPUs and
many tasks fighting for a memory (e.g. 100 tasks each allocating and
touching 10MB anonymous memory in a tight loop within a 200MB group with
swapoff and mem_control=0)

I have no hard numbers to support why spinlock is better than mutex for
the second patch but it feels like it is more suitable for the code
paths we are using it at the moment. It should also reduce context
switches count for many contenders.

Michal Hocko (2):
  memcg: make oom_lock 0 and 1 based rather than coutner
  memcg: change memcg_oom_mutex to spinlock

 mm/memcontrol.c |   42 ++++++++++++++++++++++++++----------------
 1 files changed, 26 insertions(+), 16 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
