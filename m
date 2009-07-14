Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2F14C6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 20:22:18 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6E0nLPc028082
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 14 Jul 2009 09:49:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FB3945DE51
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:49:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB7D145DE4F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:49:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC4591DB8041
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:49:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C132E08004
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:49:20 +0900 (JST)
Date: Tue, 14 Jul 2009 09:47:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Resource usage threshold notification addition to
 res_counter (v3)
Message-Id: <20090714094729.45d4dff4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830907131736w4397d336xad733f274c812690@mail.gmail.com>
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	<1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
	<1247530581-31416-2-git-send-email-vbuzov@embeddedalley.com>
	<6599ad830907131736w4397d336xad733f274c812690@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: Vladislav Buzov <vbuzov@embeddedalley.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Linux memory management list <linux-mm@kvack.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009 17:36:40 -0700
Paul Menage <menage@google.com> wrote:

> As I mentioned in another thread, I think that associating the
> threshold with the res_counter rather than with each individual waiter
> is a mistake, since it creates global state and makes it hard to have
> multiple waiters on the same cgroup.
> 
Ah, Hmm...maybe yes. 

But the problem is "hierarchy". (even if this usage notifier don't handle it.)

While we charge as following res_coutner+hierarchy

	res_counter_A			+ PAGE_SIZE
		res_counter_B			+ PAGE_SIZE
			res_counter_C			+ PAGE_SIZE

Checking "where we exceeds" in smart way is not very easy. Balbir's soft limit does
similar check but it's not very smart, either I think.

If there are prural thesholds (notifer, softlimit, etc...), this is worth to be
tried. Hmm...if not, size of res_coutner excees 128bytes and we'll see terrible counter.
Any idea ?

Thanks,
-Kame


> Paul
> 
> On Mon, Jul 13, 2009 at 5:16 PM, Vladislav
> Buzov<vbuzov@embeddedalley.com> wrote:
> > This patch updates the Resource Counter to add a configurable resource usage
> > threshold notification mechanism.
> >
> > Signed-off-by: Vladislav Buzov <vbuzov@embeddedalley.com>
> > Signed-off-by: Dan Malek <dan@embeddedalley.com>
> > ---
> > A Documentation/cgroups/resource_counter.txt | A  21 ++++++++-
> > A include/linux/res_counter.h A  A  A  A  A  A  A  A | A  69 ++++++++++++++++++++++++++++
> > A kernel/res_counter.c A  A  A  A  A  A  A  A  A  A  A  | A  A 7 +++
> > A 3 files changed, 95 insertions(+), 2 deletions(-)
> >
> > diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
> > index 95b24d7..1369dff 100644
> > --- a/Documentation/cgroups/resource_counter.txt
> > +++ b/Documentation/cgroups/resource_counter.txt
> > @@ -39,7 +39,20 @@ to work with it.
> > A  A  A  A The failcnt stands for "failures counter". This is the number of
> > A  A  A  A resource allocation attempts that failed.
> >
> > - c. spinlock_t lock
> > + e. unsigned long long threshold
> > +
> > + A  A  A  The resource usage threshold to notify the resouce controller. This is
> > + A  A  A  the minimal difference between the resource limit and current usage
> > + A  A  A  to fire a notification.
> > +
> > + f. void (*threshold_notifier)(struct res_counter *counter)
> > +
> > + A  A  A  The threshold notification callback installed by the resource
> > + A  A  A  controller. Called when the usage reaches or exceeds the threshold.
> > + A  A  A  Should be fast and not sleep because called when interrupts are
> > + A  A  A  disabled.
> > +
> > + g. spinlock_t lock
> >
> > A  A  A  A Protects changes of the above values.
> >
> > @@ -140,6 +153,7 @@ counter fields. They are recommended to adhere to the following rules:
> > A  A  A  A usage A  A  A  A  A  usage_in_<unit_of_measurement>
> > A  A  A  A max_usage A  A  A  max_usage_in_<unit_of_measurement>
> > A  A  A  A limit A  A  A  A  A  limit_in_<unit_of_measurement>
> > + A  A  A  threshold A  A  A  notify_threshold_in_<unit_of_measurement>
> > A  A  A  A failcnt A  A  A  A  failcnt
> > A  A  A  A lock A  A  A  A  A  A no file :)
> >
> > @@ -153,9 +167,12 @@ counter fields. They are recommended to adhere to the following rules:
> > A  A  A  A usage A  A  A  A  A  prohibited
> > A  A  A  A max_usage A  A  A  reset to usage
> > A  A  A  A limit A  A  A  A  A  set the limit
> > + A  A  A  threshold A  A  A  set the threshold
> > A  A  A  A failcnt A  A  A  A  reset to zero
> >
> > -
> > + d. Notification is enabled by installing the threshold notifier callback. It
> > + A  A is up to the resouce controller to communicate the notification to user
> > + A  A space tasks.
> >
> > A 5. Usage example
> >
> > diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> > index 511f42f..5ec98d7 100644
> > --- a/include/linux/res_counter.h
> > +++ b/include/linux/res_counter.h
> > @@ -9,6 +9,11 @@
> > A *
> > A * Author: Pavel Emelianov <xemul@openvz.org>
> > A *
> > + * Resouce usage threshold notification update
> > + * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
> > + * Author: Dan Malek <dan@embeddedalley.com>
> > + * Author: Vladislav Buzov <vbuzov@embeddedalley.com>
> > + *
> > A * See Documentation/cgroups/resource_counter.txt for more
> > A * info about what this counter is.
> > A */
> > @@ -35,6 +40,19 @@ struct res_counter {
> > A  A  A  A  */
> > A  A  A  A unsigned long long limit;
> > A  A  A  A /*
> > + A  A  A  A * the resource usage threshold to notify the resouce controller. This
> > + A  A  A  A * is the minimal difference between the resource limit and current
> > + A  A  A  A * usage to fire a notification.
> > + A  A  A  A */
> > + A  A  A  unsigned long long threshold;
> > + A  A  A  /*
> > + A  A  A  A * the threshold notification callback installed by the resource
> > + A  A  A  A * controller. Called when the usage reaches or exceeds the threshold.
> > + A  A  A  A * Should be fast and not sleep because called when interrupts are
> > + A  A  A  A * disabled.
> > + A  A  A  A */
> > + A  A  A  void (*threshold_notifier)(struct res_counter *counter);
> > + A  A  A  /*
> > A  A  A  A  * the number of unsuccessful attempts to consume the resource
> > A  A  A  A  */
> > A  A  A  A unsigned long long failcnt;
> > @@ -87,6 +105,7 @@ enum {
> > A  A  A  A RES_MAX_USAGE,
> > A  A  A  A RES_LIMIT,
> > A  A  A  A RES_FAILCNT,
> > + A  A  A  RES_THRESHOLD,
> > A };
> >
> > A /*
> > @@ -132,6 +151,21 @@ static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
> > A  A  A  A return false;
> > A }
> >
> > +static inline bool res_counter_threshold_check_locked(struct res_counter *cnt)
> > +{
> > + A  A  A  if (cnt->usage + cnt->threshold < cnt->limit)
> > + A  A  A  A  A  A  A  return true;
> > +
> > + A  A  A  return false;
> > +}
> > +
> > +static inline void res_counter_threshold_notify_locked(struct res_counter *cnt)
> > +{
> > + A  A  A  if (!res_counter_threshold_check_locked(cnt) &&
> > + A  A  A  A  A  cnt->threshold_notifier)
> > + A  A  A  A  A  A  A  cnt->threshold_notifier(cnt);
> > +}
> > +
> > A /*
> > A * Helper function to detect if the cgroup is within it's limit or
> > A * not. It's currently called from cgroup_rss_prepare()
> > @@ -147,6 +181,21 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
> > A  A  A  A return ret;
> > A }
> >
> > +/*
> > + * Helper function to detect if the cgroup usage is under it's threshold or
> > + * not.
> > + */
> > +static inline bool res_counter_check_under_threshold(struct res_counter *cnt)
> > +{
> > + A  A  A  bool ret;
> > + A  A  A  unsigned long flags;
> > +
> > + A  A  A  spin_lock_irqsave(&cnt->lock, flags);
> > + A  A  A  ret = res_counter_threshold_check_locked(cnt);
> > + A  A  A  spin_unlock_irqrestore(&cnt->lock, flags);
> > + A  A  A  return ret;
> > +}
> > +
> > A static inline void res_counter_reset_max(struct res_counter *cnt)
> > A {
> > A  A  A  A unsigned long flags;
> > @@ -174,6 +223,26 @@ static inline int res_counter_set_limit(struct res_counter *cnt,
> > A  A  A  A spin_lock_irqsave(&cnt->lock, flags);
> > A  A  A  A if (cnt->usage <= limit) {
> > A  A  A  A  A  A  A  A cnt->limit = limit;
> > + A  A  A  A  A  A  A  if (limit <= cnt->threshold)
> > + A  A  A  A  A  A  A  A  A  A  A  cnt->threshold = 0;
> > + A  A  A  A  A  A  A  else
> > + A  A  A  A  A  A  A  A  A  A  A  res_counter_threshold_notify_locked(cnt);
> > + A  A  A  A  A  A  A  ret = 0;
> > + A  A  A  }
> > + A  A  A  spin_unlock_irqrestore(&cnt->lock, flags);
> > + A  A  A  return ret;
> > +}
> > +
> > +static inline int res_counter_set_threshold(struct res_counter *cnt,
> > + A  A  A  A  A  A  A  unsigned long long threshold)
> > +{
> > + A  A  A  unsigned long flags;
> > + A  A  A  int ret = -EINVAL;
> > +
> > + A  A  A  spin_lock_irqsave(&cnt->lock, flags);
> > + A  A  A  if (cnt->limit > threshold) {
> > + A  A  A  A  A  A  A  cnt->threshold = threshold;
> > + A  A  A  A  A  A  A  res_counter_threshold_notify_locked(cnt);
> > A  A  A  A  A  A  A  A ret = 0;
> > A  A  A  A }
> > A  A  A  A spin_unlock_irqrestore(&cnt->lock, flags);
> > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> > index e1338f0..9b36748 100644
> > --- a/kernel/res_counter.c
> > +++ b/kernel/res_counter.c
> > @@ -5,6 +5,10 @@
> > A *
> > A * Author: Pavel Emelianov <xemul@openvz.org>
> > A *
> > + * Resouce usage threshold notification update
> > + * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
> > + * Author: Dan Malek <dan@embeddedalley.com>
> > + * Author: Vladislav Buzov <vbuzov@embeddedalley.com>
> > A */
> >
> > A #include <linux/types.h>
> > @@ -32,6 +36,7 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> > A  A  A  A counter->usage += val;
> > A  A  A  A if (counter->usage > counter->max_usage)
> > A  A  A  A  A  A  A  A counter->max_usage = counter->usage;
> > + A  A  A  res_counter_threshold_notify_locked(counter);
> > A  A  A  A return 0;
> > A }
> >
> > @@ -101,6 +106,8 @@ res_counter_member(struct res_counter *counter, int member)
> > A  A  A  A  A  A  A  A return &counter->limit;
> > A  A  A  A case RES_FAILCNT:
> > A  A  A  A  A  A  A  A return &counter->failcnt;
> > + A  A  A  case RES_THRESHOLD:
> > + A  A  A  A  A  A  A  return &counter->threshold;
> > A  A  A  A };
> >
> > A  A  A  A BUG();
> > --
> > 1.5.6.3
> >
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
