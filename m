Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 62E8D6B009F
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:59:27 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id rp16so497684pbb.12
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:27 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id a3si900345pay.281.2014.03.04.19.59.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:59:26 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id r10so488788pdi.2
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:26 -0800 (PST)
Date: Tue, 4 Mar 2014 19:59:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 05/11] res_counter: remove interface for locked charging and
 uncharging
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1403041955250.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

The res_counter_{charge,uncharge}_locked() variants are not used in the
kernel outside of the resource counter code itself, so remove the
interface.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroups/resource_counter.txt | 12 ++----------
 include/linux/res_counter.h                |  6 +-----
 kernel/res_counter.c                       | 23 ++++++++++++-----------
 3 files changed, 15 insertions(+), 26 deletions(-)

diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
--- a/Documentation/cgroups/resource_counter.txt
+++ b/Documentation/cgroups/resource_counter.txt
@@ -76,15 +76,7 @@ to work with it.
 	limit_fail_at parameter is set to the particular res_counter element
 	where the charging failed.
 
- d. int res_counter_charge_locked
-			(struct res_counter *rc, unsigned long val, bool force)
-
-	The same as res_counter_charge(), but it must not acquire/release the
-	res_counter->lock internally (it must be called with res_counter->lock
-	held). The force parameter indicates whether we can bypass the limit.
-
- e. u64 res_counter_uncharge[_locked]
-			(struct res_counter *rc, unsigned long val)
+ d. u64 res_counter_uncharge(struct res_counter *rc, unsigned long val)
 
 	When a resource is released (freed) it should be de-accounted
 	from the resource counter it was accounted to.  This is called
@@ -93,7 +85,7 @@ to work with it.
 
 	The _locked routines imply that the res_counter->lock is taken.
 
- f. u64 res_counter_uncharge_until
+ e. u64 res_counter_uncharge_until
 		(struct res_counter *rc, struct res_counter *top,
 		 unsigned long val)
 
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -104,15 +104,13 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
  *       units, e.g. numbers, bytes, Kbytes, etc
  *
  * returns 0 on success and <0 if the counter->usage will exceed the
- * counter->limit _locked call expects the counter->lock to be taken
+ * counter->limit
  *
  * charge_nofail works the same, except that it charges the resource
  * counter unconditionally, and returns < 0 if the after the current
  * charge we are over limit.
  */
 
-int __must_check res_counter_charge_locked(struct res_counter *counter,
-					   unsigned long val, bool force);
 int __must_check res_counter_charge(struct res_counter *counter,
 		unsigned long val, struct res_counter **limit_fail_at);
 int res_counter_charge_nofail(struct res_counter *counter,
@@ -125,12 +123,10 @@ int res_counter_charge_nofail(struct res_counter *counter,
  * @val: the amount of the resource
  *
  * these calls check for usage underflow and show a warning on the console
- * _locked call expects the counter->lock to be taken
  *
  * returns the total charges still present in @counter.
  */
 
-u64 res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
 u64 res_counter_uncharge(struct res_counter *counter, unsigned long val);
 
 u64 res_counter_uncharge_until(struct res_counter *counter,
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -22,8 +22,18 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 	counter->parent = parent;
 }
 
-int res_counter_charge_locked(struct res_counter *counter, unsigned long val,
-			      bool force)
+static u64 res_counter_uncharge_locked(struct res_counter *counter,
+				       unsigned long val)
+{
+	if (WARN_ON(counter->usage < val))
+		val = counter->usage;
+
+	counter->usage -= val;
+	return counter->usage;
+}
+
+static int res_counter_charge_locked(struct res_counter *counter,
+				     unsigned long val, bool force)
 {
 	int ret = 0;
 
@@ -86,15 +96,6 @@ int res_counter_charge_nofail(struct res_counter *counter, unsigned long val,
 	return __res_counter_charge(counter, val, limit_fail_at, true);
 }
 
-u64 res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
-{
-	if (WARN_ON(counter->usage < val))
-		val = counter->usage;
-
-	counter->usage -= val;
-	return counter->usage;
-}
-
 u64 res_counter_uncharge_until(struct res_counter *counter,
 			       struct res_counter *top,
 			       unsigned long val)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
