Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BDB2E6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 20:09:44 -0400 (EDT)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id n6E0ah4l032716
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 17:36:44 -0700
Received: from fxm10 (fxm10.prod.google.com [10.184.13.10])
	by spaceape13.eur.corp.google.com with ESMTP id n6E0aejo020634
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 17:36:41 -0700
Received: by fxm10 with SMTP id 10so34245fxm.7
        for <linux-mm@kvack.org>; Mon, 13 Jul 2009 17:36:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1247530581-31416-2-git-send-email-vbuzov@embeddedalley.com>
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	 <1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
	 <1247530581-31416-2-git-send-email-vbuzov@embeddedalley.com>
Date: Mon, 13 Jul 2009 17:36:40 -0700
Message-ID: <6599ad830907131736w4397d336xad733f274c812690@mail.gmail.com>
Subject: Re: [PATCH 1/2] Resource usage threshold notification addition to
	res_counter (v3)
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Vladislav Buzov <vbuzov@embeddedalley.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Linux memory management list <linux-mm@kvack.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

As I mentioned in another thread, I think that associating the
threshold with the res_counter rather than with each individual waiter
is a mistake, since it creates global state and makes it hard to have
multiple waiters on the same cgroup.

Paul

On Mon, Jul 13, 2009 at 5:16 PM, Vladislav
Buzov<vbuzov@embeddedalley.com> wrote:
> This patch updates the Resource Counter to add a configurable resource us=
age
> threshold notification mechanism.
>
> Signed-off-by: Vladislav Buzov <vbuzov@embeddedalley.com>
> Signed-off-by: Dan Malek <dan@embeddedalley.com>
> ---
> =A0Documentation/cgroups/resource_counter.txt | =A0 21 ++++++++-
> =A0include/linux/res_counter.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 69 ++=
++++++++++++++++++++++++++
> =A0kernel/res_counter.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A07 +++
> =A03 files changed, 95 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/c=
groups/resource_counter.txt
> index 95b24d7..1369dff 100644
> --- a/Documentation/cgroups/resource_counter.txt
> +++ b/Documentation/cgroups/resource_counter.txt
> @@ -39,7 +39,20 @@ to work with it.
> =A0 =A0 =A0 =A0The failcnt stands for "failures counter". This is the num=
ber of
> =A0 =A0 =A0 =A0resource allocation attempts that failed.
>
> - c. spinlock_t lock
> + e. unsigned long long threshold
> +
> + =A0 =A0 =A0 The resource usage threshold to notify the resouce controll=
er. This is
> + =A0 =A0 =A0 the minimal difference between the resource limit and curre=
nt usage
> + =A0 =A0 =A0 to fire a notification.
> +
> + f. void (*threshold_notifier)(struct res_counter *counter)
> +
> + =A0 =A0 =A0 The threshold notification callback installed by the resour=
ce
> + =A0 =A0 =A0 controller. Called when the usage reaches or exceeds the th=
reshold.
> + =A0 =A0 =A0 Should be fast and not sleep because called when interrupts=
 are
> + =A0 =A0 =A0 disabled.
> +
> + g. spinlock_t lock
>
> =A0 =A0 =A0 =A0Protects changes of the above values.
>
> @@ -140,6 +153,7 @@ counter fields. They are recommended to adhere to the=
 following rules:
> =A0 =A0 =A0 =A0usage =A0 =A0 =A0 =A0 =A0 usage_in_<unit_of_measurement>
> =A0 =A0 =A0 =A0max_usage =A0 =A0 =A0 max_usage_in_<unit_of_measurement>
> =A0 =A0 =A0 =A0limit =A0 =A0 =A0 =A0 =A0 limit_in_<unit_of_measurement>
> + =A0 =A0 =A0 threshold =A0 =A0 =A0 notify_threshold_in_<unit_of_measurem=
ent>
> =A0 =A0 =A0 =A0failcnt =A0 =A0 =A0 =A0 failcnt
> =A0 =A0 =A0 =A0lock =A0 =A0 =A0 =A0 =A0 =A0no file :)
>
> @@ -153,9 +167,12 @@ counter fields. They are recommended to adhere to th=
e following rules:
> =A0 =A0 =A0 =A0usage =A0 =A0 =A0 =A0 =A0 prohibited
> =A0 =A0 =A0 =A0max_usage =A0 =A0 =A0 reset to usage
> =A0 =A0 =A0 =A0limit =A0 =A0 =A0 =A0 =A0 set the limit
> + =A0 =A0 =A0 threshold =A0 =A0 =A0 set the threshold
> =A0 =A0 =A0 =A0failcnt =A0 =A0 =A0 =A0 reset to zero
>
> -
> + d. Notification is enabled by installing the threshold notifier callbac=
k. It
> + =A0 =A0is up to the resouce controller to communicate the notification =
to user
> + =A0 =A0space tasks.
>
> =A05. Usage example
>
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 511f42f..5ec98d7 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -9,6 +9,11 @@
> =A0*
> =A0* Author: Pavel Emelianov <xemul@openvz.org>
> =A0*
> + * Resouce usage threshold notification update
> + * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
> + * Author: Dan Malek <dan@embeddedalley.com>
> + * Author: Vladislav Buzov <vbuzov@embeddedalley.com>
> + *
> =A0* See Documentation/cgroups/resource_counter.txt for more
> =A0* info about what this counter is.
> =A0*/
> @@ -35,6 +40,19 @@ struct res_counter {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0unsigned long long limit;
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* the resource usage threshold to notify the resouce con=
troller. This
> + =A0 =A0 =A0 =A0* is the minimal difference between the resource limit a=
nd current
> + =A0 =A0 =A0 =A0* usage to fire a notification.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 unsigned long long threshold;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* the threshold notification callback installed by the r=
esource
> + =A0 =A0 =A0 =A0* controller. Called when the usage reaches or exceeds t=
he threshold.
> + =A0 =A0 =A0 =A0* Should be fast and not sleep because called when inter=
rupts are
> + =A0 =A0 =A0 =A0* disabled.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 void (*threshold_notifier)(struct res_counter *counter);
> + =A0 =A0 =A0 /*
> =A0 =A0 =A0 =A0 * the number of unsuccessful attempts to consume the reso=
urce
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0unsigned long long failcnt;
> @@ -87,6 +105,7 @@ enum {
> =A0 =A0 =A0 =A0RES_MAX_USAGE,
> =A0 =A0 =A0 =A0RES_LIMIT,
> =A0 =A0 =A0 =A0RES_FAILCNT,
> + =A0 =A0 =A0 RES_THRESHOLD,
> =A0};
>
> =A0/*
> @@ -132,6 +151,21 @@ static inline bool res_counter_limit_check_locked(st=
ruct res_counter *cnt)
> =A0 =A0 =A0 =A0return false;
> =A0}
>
> +static inline bool res_counter_threshold_check_locked(struct res_counter=
 *cnt)
> +{
> + =A0 =A0 =A0 if (cnt->usage + cnt->threshold < cnt->limit)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> +
> + =A0 =A0 =A0 return false;
> +}
> +
> +static inline void res_counter_threshold_notify_locked(struct res_counte=
r *cnt)
> +{
> + =A0 =A0 =A0 if (!res_counter_threshold_check_locked(cnt) &&
> + =A0 =A0 =A0 =A0 =A0 cnt->threshold_notifier)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cnt->threshold_notifier(cnt);
> +}
> +
> =A0/*
> =A0* Helper function to detect if the cgroup is within it's limit or
> =A0* not. It's currently called from cgroup_rss_prepare()
> @@ -147,6 +181,21 @@ static inline bool res_counter_check_under_limit(str=
uct res_counter *cnt)
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> +/*
> + * Helper function to detect if the cgroup usage is under it's threshold=
 or
> + * not.
> + */
> +static inline bool res_counter_check_under_threshold(struct res_counter =
*cnt)
> +{
> + =A0 =A0 =A0 bool ret;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&cnt->lock, flags);
> + =A0 =A0 =A0 ret =3D res_counter_threshold_check_locked(cnt);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&cnt->lock, flags);
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0static inline void res_counter_reset_max(struct res_counter *cnt)
> =A0{
> =A0 =A0 =A0 =A0unsigned long flags;
> @@ -174,6 +223,26 @@ static inline int res_counter_set_limit(struct res_c=
ounter *cnt,
> =A0 =A0 =A0 =A0spin_lock_irqsave(&cnt->lock, flags);
> =A0 =A0 =A0 =A0if (cnt->usage <=3D limit) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cnt->limit =3D limit;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (limit <=3D cnt->threshold)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cnt->threshold =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_threshold_notif=
y_locked(cnt);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_irqrestore(&cnt->lock, flags);
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static inline int res_counter_set_threshold(struct res_counter *cnt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long long threshold)
> +{
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 int ret =3D -EINVAL;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&cnt->lock, flags);
> + =A0 =A0 =A0 if (cnt->limit > threshold) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cnt->threshold =3D threshold;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_threshold_notify_locked(cnt);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D 0;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&cnt->lock, flags);
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index e1338f0..9b36748 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -5,6 +5,10 @@
> =A0*
> =A0* Author: Pavel Emelianov <xemul@openvz.org>
> =A0*
> + * Resouce usage threshold notification update
> + * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
> + * Author: Dan Malek <dan@embeddedalley.com>
> + * Author: Vladislav Buzov <vbuzov@embeddedalley.com>
> =A0*/
>
> =A0#include <linux/types.h>
> @@ -32,6 +36,7 @@ int res_counter_charge_locked(struct res_counter *count=
er, unsigned long val)
> =A0 =A0 =A0 =A0counter->usage +=3D val;
> =A0 =A0 =A0 =A0if (counter->usage > counter->max_usage)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0counter->max_usage =3D counter->usage;
> + =A0 =A0 =A0 res_counter_threshold_notify_locked(counter);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -101,6 +106,8 @@ res_counter_member(struct res_counter *counter, int m=
ember)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return &counter->limit;
> =A0 =A0 =A0 =A0case RES_FAILCNT:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return &counter->failcnt;
> + =A0 =A0 =A0 case RES_THRESHOLD:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &counter->threshold;
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0BUG();
> --
> 1.5.6.3
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
