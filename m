Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 5351C6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 04:21:22 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH 0/2] reuse vmpressure for in-kernel events
Date: Tue, 23 Apr 2013 12:22:07 +0400
Message-Id: <1366705329-9426-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

During the past weeks, it became clear to us that the shrinker interface we
have right now works very well for some particular types of users, but not that
well for others. The later are usually people interested in one-shot
notifications, that were forced to adapt themselves to the count+scan behavior
of shrinkers. To do so, they had no choice than to greatly abuse the shrinker
interface producing little monsters all over.

During LSF/MM, one of the proposals that popped out during our session was to
reuse Anton Voronstsov's vmpressure for this. They are designed for userspace
consumption, but also provide a well-stablished, cgroup-aware entry point for
notifications.

I am demonstrating this interface by registering a memcg event that tries to
get rid of all dead caches in the system. We never used a shrinker for that
because it didn't feel too natural. The new interface integrates quite nicely,
though.

Please note that due to my lack of understanding of each shrinker user, I will
stay away from converting the actual users, you are all welcome to do so.

Glauber Costa (2):
  vmpressure: in-kernel notifications
  memcg: reap dead memcgs under pressure

 include/linux/vmpressure.h |  6 ++++
 mm/memcontrol.c            | 81 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmpressure.c            | 48 ++++++++++++++++++++++++---
 3 files changed, 128 insertions(+), 7 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
