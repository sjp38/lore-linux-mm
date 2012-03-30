Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id D62236B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 04:06:01 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 1/7] split percpu_counter_sum
Date: Fri, 30 Mar 2012 10:04:39 +0200
Message-Id: <1333094685-5507-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1333094685-5507-1-git-send-email-glommer@parallels.com>
References: <1333094685-5507-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Li Zefan <lizefan@huawei.com>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>, Glauber Costa <glommer@parallels.com>

Split the locked part so we can do other operations with the counter
in other call sites.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 include/linux/percpu_counter.h |    1 +
 lib/percpu_counter.c           |   12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
index b9df9ed..8310548 100644
--- a/include/linux/percpu_counter.h
+++ b/include/linux/percpu_counter.h
@@ -40,6 +40,7 @@ void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
 s64 __percpu_counter_sum(struct percpu_counter *fbc);
+s64 __percpu_counter_sum_locked(struct percpu_counter *fbc);
 int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs);
 
 static inline void percpu_counter_add(struct percpu_counter *fbc, s64 amount)
diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
index f8a3f1a..0b6a672 100644
--- a/lib/percpu_counter.c
+++ b/lib/percpu_counter.c
@@ -93,17 +93,25 @@ EXPORT_SYMBOL(__percpu_counter_add);
  * Add up all the per-cpu counts, return the result.  This is a more accurate
  * but much slower version of percpu_counter_read_positive()
  */
-s64 __percpu_counter_sum(struct percpu_counter *fbc)
+s64 __percpu_counter_sum_locked(struct percpu_counter *fbc)
 {
 	s64 ret;
 	int cpu;
 
-	raw_spin_lock(&fbc->lock);
 	ret = fbc->count;
 	for_each_online_cpu(cpu) {
 		s32 *pcount = per_cpu_ptr(fbc->counters, cpu);
 		ret += *pcount;
 	}
+	return ret;
+}
+EXPORT_SYMBOL(__percpu_counter_sum_locked);
+
+s64 __percpu_counter_sum(struct percpu_counter *fbc)
+{
+	s64 ret;
+	raw_spin_lock(&fbc->lock);
+	ret = __percpu_counter_sum_locked(fbc);
 	raw_spin_unlock(&fbc->lock);
 	return ret;
 }
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
