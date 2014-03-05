Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1345F6B00A0
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:59:29 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id z10so488044pdj.32
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:29 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id wq4si921830pbc.197.2014.03.04.19.59.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:59:29 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id kl14so511007pab.4
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:28 -0800 (PST)
Date: Tue, 4 Mar 2014 19:59:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 06/11] res_counter: add interface for maximum nofail charge
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1403041955460.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

For memcg oom reserves, we'll need a resource counter interface that will
not fail when exceeding the memcg limit like res_counter_charge_nofail,
but only to a ceiling.

This patch adds res_counter_charge_nofail_max() that will exceed the
resource counter but only to a maximum defined value.  If it fails to
charge the resource, it returns -ENOMEM.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/res_counter.h | 10 +++++++++-
 kernel/res_counter.c        | 27 +++++++++++++++++++++------
 2 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -107,14 +107,22 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
  * counter->limit
  *
  * charge_nofail works the same, except that it charges the resource
- * counter unconditionally, and returns < 0 if the after the current
+ * counter unconditionally, and returns < 0 if after the current
  * charge we are over limit.
+ *
+ * charge_nofail_max is the same as charge_nofail, except that the
+ * resource counter usage can only exceed the limit by the max
+ * difference.  Unlike charge_nofail, charge_nofail_max returns < 0
+ * only if the current charge fails because of the max difference.
  */
 
 int __must_check res_counter_charge(struct res_counter *counter,
 		unsigned long val, struct res_counter **limit_fail_at);
 int res_counter_charge_nofail(struct res_counter *counter,
 		unsigned long val, struct res_counter **limit_fail_at);
+int res_counter_charge_nofail_max(struct res_counter *counter,
+		unsigned long val, struct res_counter **limit_fail_at,
+		unsigned long max);
 
 /*
  * uncharge - tell that some portion of the resource is released
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -33,15 +33,19 @@ static u64 res_counter_uncharge_locked(struct res_counter *counter,
 }
 
 static int res_counter_charge_locked(struct res_counter *counter,
-				     unsigned long val, bool force)
+				     unsigned long val, bool force,
+				     unsigned long max)
 {
 	int ret = 0;
 
 	if (counter->usage + val > counter->limit) {
 		counter->failcnt++;
-		ret = -ENOMEM;
+		if (max == ULONG_MAX)
+			ret = -ENOMEM;
 		if (!force)
 			return ret;
+		if (counter->usage + val - counter->limit > max)
+			return -ENOMEM;
 	}
 
 	counter->usage += val;
@@ -51,7 +55,8 @@ static int res_counter_charge_locked(struct res_counter *counter,
 }
 
 static int __res_counter_charge(struct res_counter *counter, unsigned long val,
-				struct res_counter **limit_fail_at, bool force)
+				struct res_counter **limit_fail_at, bool force,
+				unsigned long max)
 {
 	int ret, r;
 	unsigned long flags;
@@ -62,7 +67,7 @@ static int __res_counter_charge(struct res_counter *counter, unsigned long val,
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
-		r = res_counter_charge_locked(c, val, force);
+		r = res_counter_charge_locked(c, val, force, max);
 		spin_unlock(&c->lock);
 		if (r < 0 && !ret) {
 			ret = r;
@@ -87,13 +92,23 @@ static int __res_counter_charge(struct res_counter *counter, unsigned long val,
 int res_counter_charge(struct res_counter *counter, unsigned long val,
 			struct res_counter **limit_fail_at)
 {
-	return __res_counter_charge(counter, val, limit_fail_at, false);
+	return __res_counter_charge(counter, val, limit_fail_at, false,
+				    ULONG_MAX);
 }
 
 int res_counter_charge_nofail(struct res_counter *counter, unsigned long val,
 			      struct res_counter **limit_fail_at)
 {
-	return __res_counter_charge(counter, val, limit_fail_at, true);
+	return __res_counter_charge(counter, val, limit_fail_at, true,
+				    ULONG_MAX);
+}
+
+int res_counter_charge_nofail_max(struct res_counter *counter,
+				  unsigned long val,
+				  struct res_counter **limit_fail_at,
+				  unsigned long max)
+{
+	return __res_counter_charge(counter, val, limit_fail_at, true, max);
 }
 
 u64 res_counter_uncharge_until(struct res_counter *counter,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
