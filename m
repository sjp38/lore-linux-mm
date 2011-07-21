Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 929626B0082
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:46:39 -0400 (EDT)
Message-Id: <cover.1311241300.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Thu, 21 Jul 2011 11:41:40 +0200
Subject: [PATCH 0/4] memcg: cleanup per-cpu charge caches + fix unnecessary reclaim if there are still cached charges
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

Hi,
this patchset cleans up per-cpu charge cache draining code and it fixes
an issue where we could reclaim from a group even though there are
caches with charges on other CPUs that can be used. Although the problem
is far from being critical it can bite us on large machines with many
CPUs.
I am sorry that I am mixing those two things but the fix depends on the
work done in the clean up patches so I hope it won't be confusing.
The reason is that I needed a sane implementation of sync draining code
and wanted to prevent from code duplication.

First two patches should be quite straightforward. Checking
stock->nr_pages is more general than excluding just the local CPU and
having targeted sync draining also makes a good sense to me.

The third one might require some discussion. AFAIU it should be safe but
others might see some issues. Anyway I have no issues to drop it because
the fix doesn't depend on it. I have put it before the fix just because
I wanted to have all cleanups in front.

Finally the fourth patch is the already mentioned fix. I do not think
I have ever seen any sane application (aka not artificially created
usecase) where we would trigger the behavior in a such way that the
performance would hurt or something similar but I have already seen a
pointless reclaim while we had caches on other CPUs. As the number of
CPUs grow I think the change makes quite a good sense.

The patchset is on top of the current Linus tree but it should apply on
top of the current mmotm tree as well.

Any thoughts comments?

Michal Hocko (4):
  memcg: do not try to drain per-cpu caches without pages
  memcg: unify sync and async per-cpu charge cache draining
  memcg: get rid of percpu_charge_mutex lock
  memcg: prevent from reclaiming if there are per-cpu cached charges

 mm/memcontrol.c |   73 +++++++++++++++++++++++++++++++------------------------
 1 files changed, 41 insertions(+), 32 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
