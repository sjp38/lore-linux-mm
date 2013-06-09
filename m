Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E04736B0031
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 08:46:09 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id dy20so2713175lab.37
        for <linux-mm@kvack.org>; Sun, 09 Jun 2013 05:46:08 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v2 0/2] do not account memory used for cache creation
Date: Sun,  9 Jun 2013 16:45:52 +0400
Message-Id: <1370781954-9972-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suze.cz, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@openvz.org>

The memory we used to hold the memcg arrays is currently accounted to
the current memcg. But that creates a problem, because that memory can
only be freed after the last user is gone. Our only way to know which is
the last user, is to hook up to freeing time, but the fact that we still
have some in flight kmallocs will prevent freeing to happen. I believe
therefore to be just easier to account this memory as global overhead.

>From my last submission, Michal rightfully noted that this will break
when SLUB is used and allocations are big enough, since those will bypass
the cache mechanism and go directly to the page allocator. To fix this,
we need an extra patch that instructs the memcg kmem page charging to check
the bypass flag as well.

Glauber Costa (2):
  memcg: also test for skip accounting at the page allocation level
  memcg: do not account memory used for cache creation

 mm/memcontrol.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
