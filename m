Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 8DDE66B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:34:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9D3F43EE0C2
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:34:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E97D45DE61
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:34:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 07B7445DE59
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:34:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DEC82E08006
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:34:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88528E08008
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:34:44 +0900 (JST)
Message-ID: <4FB0DF4A.5010506@jp.fujitsu.com>
Date: Mon, 14 May 2012 19:32:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] add res_counter_uncharge_until()
References: <4FACDED0.3020400@jp.fujitsu.com> <4FACE01A.4040405@jp.fujitsu.com> <20120511141945.c487e94c.akpm@linux-foundation.org> <4FB05B8F.8020408@jp.fujitsu.com> <CAFTL4hwGEhyxZO0sXx5gVyK_xjhMQEbHojJbHzQmVKafNyVWtw@mail.gmail.com>
In-Reply-To: <CAFTL4hwGEhyxZO0sXx5gVyK_xjhMQEbHojJbHzQmVKafNyVWtw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/05/14 19:08), Frederic Weisbecker wrote:

> 2012/5/14 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> (2012/05/12 6:19), Andrew Morton wrote:
>>
>>> On Fri, 11 May 2012 18:47:06 +0900
>>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>
>>>> From: Frederic Weisbecker <fweisbec@gmail.com>
>>>>
>>>> At killing res_counter which is a child of other counter,
>>>> we need to do
>>>>      res_counter_uncharge(child, xxx)
>>>>      res_counter_charge(parent, xxx)
>>>>
>>>> This is not atomic and wasting cpu. This patch adds
>>>> res_counter_uncharge_until(). This function's uncharge propagates
>>>> to ancestors until specified res_counter.
>>>>
>>>>      res_counter_uncharge_until(child, parent, xxx)
>>>>
>>>> Now, ops is atomic and efficient.
>>>>
>>>> Changelog since v2
>>>>  - removed unnecessary lines.
>>>>  - Fixed 'From' , this patch comes from his series. Please signed-off-by if good.
>>>>
>>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>
>>> Frederic's Signed-off-by: is unavaliable?
>>>
>>
>> I didn't add his Signed-off because I modified his orignal patch a little...
>> I dropped res_counter_charge_until() because it's not used in this series,
>> I have no justification for adding it.
>> The idea of res_counter_uncharge_until() is from his patch.
> 
> The property of Signed-off-by is that as long as you
> carry/relay/modify a patch, you add your
> own signed-off-by. But you can't remove the signed off by of somebody
> in the chain.
> 

> Even if you did a change in the patch, you need to preserve the chain.
> 

Oh, sorry. 

> There may be some special cases with "Original-patch-from:" tags used when
> one heavily inspire from a patch without taking much of its original code.
> 


Is this ok ?

==
[PATCH 2/6] memcg: add res_counter_uncharge_until()

From: Frederic Weisbecker <fweisbec@gmail.com>

At killing res_counter which is a child of other counter,
we need to do
	res_counter_uncharge(child, xxx)
	res_counter_charge(parent, xxx)

This is not atomic and wasting cpu. This patch adds
res_counter_uncharge_until(). This function's uncharge propagates
to ancestors until specified res_counter.

	res_counter_uncharge_until(child, parent, xxx)

Now, ops is atomic and efficient.

Changelog since v2
 - removed unnecessary lines.
 - added 'From' , this patch comes from his one.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/resource_counter.txt |    8 ++++++++
 include/linux/res_counter.h                |    3 +++
 kernel/res_counter.c                       |   10 ++++++++--
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
index 95b24d7..703103a 100644
--- a/Documentation/cgroups/resource_counter.txt
+++ b/Documentation/cgroups/resource_counter.txt
@@ -92,6 +92,14 @@ to work with it.
 
 	The _locked routines imply that the res_counter->lock is taken.
 
+ f. void res_counter_uncharge_until
+		(struct res_counter *rc, struct res_counter *top,
+		 unsinged long val)
+
+	Almost same as res_cunter_uncharge() but propagation of uncharge
+	stops when rc == top. This is useful when kill a res_coutner in
+	child cgroup.
+
  2.1 Other accounting routines
 
     There are more routines that may help you with common needs, like
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index da81af0..d11c1cd 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -135,6 +135,9 @@ int __must_check res_counter_charge_nofail(struct res_counter *counter,
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
 void res_counter_uncharge(struct res_counter *counter, unsigned long val);
 
+void res_counter_uncharge_until(struct res_counter *counter,
+				struct res_counter *top,
+				unsigned long val);
 /**
  * res_counter_margin - calculate chargeable space of a counter
  * @cnt: the counter
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index d508363..d9ea45e 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -99,13 +99,15 @@ void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
 	counter->usage -= val;
 }
 
-void res_counter_uncharge(struct res_counter *counter, unsigned long val)
+void res_counter_uncharge_until(struct res_counter *counter,
+				struct res_counter *top,
+				unsigned long val)
 {
 	unsigned long flags;
 	struct res_counter *c;
 
 	local_irq_save(flags);
-	for (c = counter; c != NULL; c = c->parent) {
+	for (c = counter; c != top; c = c->parent) {
 		spin_lock(&c->lock);
 		res_counter_uncharge_locked(c, val);
 		spin_unlock(&c->lock);
@@ -113,6 +115,10 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	local_irq_restore(flags);
 }
 
+void res_counter_uncharge(struct res_counter *counter, unsigned long val)
+{
+	res_counter_uncharge_until(counter, NULL, val);
+}
 
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
-- 
1.7.4.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
