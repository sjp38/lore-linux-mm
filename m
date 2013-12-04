Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f44.google.com (mail-qe0-f44.google.com [209.85.128.44])
	by kanga.kvack.org (Postfix) with ESMTP id A3B126B0039
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 00:20:13 -0500 (EST)
Received: by mail-qe0-f44.google.com with SMTP id nd7so14984690qeb.17
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:13 -0800 (PST)
Received: from mail-yh0-x229.google.com (mail-yh0-x229.google.com [2607:f8b0:4002:c01::229])
        by mx.google.com with ESMTPS id t1si11419051qeq.70.2013.12.03.21.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 21:20:12 -0800 (PST)
Received: by mail-yh0-f41.google.com with SMTP id f11so10981512yha.14
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:12 -0800 (PST)
Date: Tue, 3 Dec 2013 21:20:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 5/8] res_counter: remove interface for locked charging and
 uncharging
In-Reply-To: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1312032118230.29733@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

The res_counter_{charge,uncharge}_locked() variants are not used in the
kernel outside of the resource counter code itself, so remove the
interface.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroups/resource_counter.txt | 14 ++------------
 include/linux/res_counter.h                |  6 +-----
 kernel/res_counter.c                       | 23 ++++++++++++-----------
 3 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
--- a/Documentation/cgroups/resource_counter.txt
+++ b/Documentation/cgroups/resource_counter.txt
@@ -76,24 +76,14 @@ to work with it.
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
 	"uncharging". The return value of this function indicate the amount
 	of charges still present in the counter.
 
-	The _locked routines imply that the res_counter->lock is taken.
-
- f. u64 res_counter_uncharge_until
+ e. u64 res_counter_uncharge_until
 		(struct res_counter *rc, struct res_counter *top,
 		 unsinged long val)
 
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
