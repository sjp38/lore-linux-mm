Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 8D52B6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 09:07:17 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: do not check for do_swap_account in mem_cgroup_{read,write,reset}
Date: Tue, 19 Mar 2013 14:06:55 +0100
Message-Id: <1363698415-12737-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

since 2d11085e (memcg: do not create memsw files if swap accounting
is disabled) memsw files are created only if memcg swap accounting is
enabled so there doesn't make any sense to check for it explicitely in
mem_cgroup_read, mem_cgroup_write and mem_cgroup_reset.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2e01167..f608546 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5091,9 +5091,6 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
 
-	if (!do_swap_account && type == _MEMSWAP)
-		return -EOPNOTSUPP;
-
 	switch (type) {
 	case _MEM:
 		if (name == RES_USAGE)
@@ -5329,9 +5326,6 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
 
-	if (!do_swap_account && type == _MEMSWAP)
-		return -EOPNOTSUPP;
-
 	switch (name) {
 	case RES_LIMIT:
 		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
@@ -5408,9 +5402,6 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 	type = MEMFILE_TYPE(event);
 	name = MEMFILE_ATTR(event);
 
-	if (!do_swap_account && type == _MEMSWAP)
-		return -EOPNOTSUPP;
-
 	switch (name) {
 	case RES_MAX_USAGE:
 		if (type == _MEM)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
