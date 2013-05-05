Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D54E06B0197
	for <linux-mm@kvack.org>; Sun,  5 May 2013 11:42:36 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id jh10so1656628pab.3
        for <linux-mm@kvack.org>; Sun, 05 May 2013 08:42:36 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 1/3] memcg: correct RESOURCE_MAX to ULLONG_MAX and rename it to a better one
Date: Sun,  5 May 2013 23:41:17 +0800
Message-Id: <1367768477-4360-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, mhocko@suse.cz, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

Current RESOURCE_MAX(unlimited) is ULONG_MAX, but we can set a bigger value
than it which is strange. This patch fix it to UULONG_MAX.

Notice that this change will affect user output of default *.limit_in_bytes:
before change:
$ cat /memcg/memory.limit_in_bytes
9223372036854775807

after change:
$ cat /memcg/memory.limit_in_bytes
18446744073709551615

But it doesn't alter the API in term of input - we can still use
"echo -1 > *.limit_in_bytes" to reset the numbers to "unlimited".

Thanks the suggestions from Andrew and Daisuke Nishimura!

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 include/linux/res_counter.h |    2 +-
 kernel/res_counter.c        |    8 ++++----
 mm/memcontrol.c             |    4 ++--
 net/ipv4/tcp_memcontrol.c   |   10 +++++-----
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index c230994..d7e9056 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -54,7 +54,7 @@ struct res_counter {
 	struct res_counter *parent;
 };
 
-#define RESOURCE_MAX (unsigned long long)LLONG_MAX
+#define RES_COUNTER_MAX ULLONG_MAX
 
 /**
  * Helpers to interact with userspace
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index ff55247..3f0417f 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -17,8 +17,8 @@
 void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
-	counter->limit = RESOURCE_MAX;
-	counter->soft_limit = RESOURCE_MAX;
+	counter->limit = RES_COUNTER_MAX;
+	counter->soft_limit = RES_COUNTER_MAX;
 	counter->parent = parent;
 }
 
@@ -182,12 +182,12 @@ int res_counter_memparse_write_strategy(const char *buf,
 {
 	char *end;
 
-	/* return RESOURCE_MAX(unlimited) if "-1" is specified */
+	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
 	if (*buf == '-') {
 		*res = simple_strtoull(buf + 1, &end, 10);
 		if (*res != 1 || *end != '\0')
 			return -EINVAL;
-		*res = RESOURCE_MAX;
+		*res = RES_COUNTER_MAX;
 		return 0;
 	}
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cd940b1..d328798 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5261,7 +5261,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 	 */
 	mutex_lock(&memcg_create_mutex);
 	mutex_lock(&set_limit_mutex);
-	if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
+	if (!memcg->kmem_account_flags && val != RES_COUNTER_MAX) {
 		if (cgroup_task_count(cont) || memcg_has_children(memcg)) {
 			ret = -EBUSY;
 			goto out;
@@ -5271,7 +5271,7 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 
 		ret = memcg_update_cache_sizes(memcg);
 		if (ret) {
-			res_counter_set_limit(&memcg->kmem, RESOURCE_MAX);
+			res_counter_set_limit(&memcg->kmem, RES_COUNTER_MAX);
 			goto out;
 		}
 		static_key_slow_inc(&memcg_kmem_enabled_key);
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index b6f3583..21f810d 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -90,8 +90,8 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 	if (!cg_proto)
 		return -EINVAL;
 
-	if (val > RESOURCE_MAX)
-		val = RESOURCE_MAX;
+	if (val > RES_COUNTER_MAX)
+		val = RES_COUNTER_MAX;
 
 	tcp = tcp_from_cgproto(cg_proto);
 
@@ -104,9 +104,9 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 		tcp->tcp_prot_mem[i] = min_t(long, val >> PAGE_SHIFT,
 					     net->ipv4.sysctl_tcp_mem[i]);
 
-	if (val == RESOURCE_MAX)
+	if (val == RES_COUNTER_MAX)
 		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
-	else if (val != RESOURCE_MAX) {
+	else if (val != RES_COUNTER_MAX) {
 		/*
 		 * The active bit needs to be written after the static_key
 		 * update. This is what guarantees that the socket activation
@@ -190,7 +190,7 @@ static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
 
 	switch (cft->private) {
 	case RES_LIMIT:
-		val = tcp_read_stat(memcg, RES_LIMIT, RESOURCE_MAX);
+		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
 		break;
 	case RES_USAGE:
 		val = tcp_read_usage(memcg);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
