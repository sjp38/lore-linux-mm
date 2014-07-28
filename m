Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id EE78F6B003C
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:32:09 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so9618701pdb.13
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:32:09 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x2si6564926pdd.439.2014.07.28.02.32.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 02:32:08 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 6/6] memcg: iterator: do not skip offline css
Date: Mon, 28 Jul 2014 13:31:28 +0400
Message-ID: <8406fefb5d1d05c775ff27613c49e104ecd7f409.1406536261.git.vdavydov@parallels.com>
In-Reply-To: <cover.1406536261.git.vdavydov@parallels.com>
References: <cover.1406536261.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, david@fromorbit.com, viro@zeniv.linux.org.uk, gthelen@google.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

After offline, memcg may still host kmem objects, which must be shrinked
on memory pressure.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1030bba4b94f..bf55088f0152 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1100,8 +1100,7 @@ skip_node:
 	 */
 	if (next_css) {
 		if ((next_css == &root->css) ||
-		    ((next_css->flags & CSS_ONLINE) &&
-		     css_tryget_online(next_css)))
+		    css_tryget(next_css))
 			return mem_cgroup_from_css(next_css);
 
 		prev_css = next_css;
@@ -1147,7 +1146,7 @@ mem_cgroup_iter_load(struct mem_cgroup_reclaim_iter *iter,
 		 * would be returned all the time.
 		 */
 		if (position && position != root &&
-		    !css_tryget_online(&position->css))
+		    !css_tryget(&position->css))
 			position = NULL;
 	}
 	return position;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
