Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 63B616B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 15:39:29 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id n5OJef8S001808
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 12:40:41 -0700
Received: from qw-out-1920.google.com (qwk4.prod.google.com [10.241.195.132])
	by wpaz5.hot.corp.google.com with ESMTP id n5OJeW4i002249
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 12:40:38 -0700
Received: by qw-out-1920.google.com with SMTP id 4so203644qwk.30
        for <linux-mm@kvack.org>; Wed, 24 Jun 2009 12:40:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090624170516.GT8642@balbir.in.ibm.com>
References: <20090624170516.GT8642@balbir.in.ibm.com>
Date: Wed, 24 Jun 2009 12:40:38 -0700
Message-ID: <6599ad830906241240o26ab54ffj37a1685f7c7d9e05@mail.gmail.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Looks like a sensible change.

Paul

On Wed, Jun 24, 2009 at 10:05 AM, Balbir Singh<balbir@linux.vnet.ibm.com> wrote:
> Hi, All,
>
> I've been experimenting with reduction of resource counter locking
> overhead. My benchmarks show a marginal improvement, /proc/lock_stat
> however shows that the lock contention time and held time reduce
> by quite an amount after this patch.
>
> Before the patch, I see
>
> lock_stat version 0.3
> -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>                              class name    con-bounces    contentions
> waittime-min   waittime-max waittime-total    acq-bounces
> acquisitions   holdtime-min   holdtime-max holdtime-total
> -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>
>                          &counter->lock:       1534627        1575341
> 0.57          18.39      675713.23       43330446      138524248
> 0.43         148.13    54133607.05
>                          --------------
>                          &counter->lock         809559
> [<ffffffff810810c5>] res_counter_charge+0x3f/0xed
>                          &counter->lock         765782
> [<ffffffff81081045>] res_counter_uncharge+0x2c/0x6d
>                          --------------
>                          &counter->lock         653284
> [<ffffffff81081045>] res_counter_uncharge+0x2c/0x6d
>                          &counter->lock         922057
> [<ffffffff810810c5>] res_counter_charge+0x3f/0xed
>
>
> After the patch I see
>
> lock_stat version 0.3
> -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>                              class name    con-bounces    contentions
> waittime-min   waittime-max waittime-total    acq-bounces
> acquisitions   holdtime-min   holdtime-max holdtime-total
> -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>
>                 &(&counter->lock)->lock:        962193         976349
> 0.60          14.07      465926.04       21364165       66041988
> 0.45          88.31    25395513.12
>                 -----------------------
>                 &(&counter->lock)->lock         495468
> [<ffffffff8108106e>] res_counter_uncharge+0x2c/0x77
>                 &(&counter->lock)->lock         480881
> [<ffffffff810810f7>] res_counter_charge+0x3e/0xfb
>                 -----------------------
>                 &(&counter->lock)->lock         564419
> [<ffffffff810810f7>] res_counter_charge+0x3e/0xfb
>                 &(&counter->lock)->lock         411930
> [<ffffffff8108106e>] res_counter_uncharge+0x2c/0x77
>
> Please review, comment on the usefulness of this approach. I do have
> another approach in mind for reducing res_counter lock overhead, but
> this one seems the most straight forward
>
>
> Feature: Change locking of res_counter
>
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>
> Resource Counters today use spin_lock_irq* variants for locking.
> This patch converts the lock to a seqlock_t
> ---
>
>  include/linux/res_counter.h |   24 +++++++++++++-----------
>  kernel/res_counter.c        |   18 +++++++++---------
>  2 files changed, 22 insertions(+), 20 deletions(-)
>
>
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 511f42f..4c61757 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -14,6 +14,7 @@
>  */
>
>  #include <linux/cgroup.h>
> +#include <linux/seqlock.h>
>
>  /*
>  * The core object. the cgroup that wishes to account for some
> @@ -42,7 +43,7 @@ struct res_counter {
>         * the lock to protect all of the above.
>         * the routines below consider this to be IRQ-safe
>         */
> -       spinlock_t lock;
> +       seqlock_t lock;
>        /*
>         * Parent counter, used for hierarchial resource accounting
>         */
> @@ -139,11 +140,12 @@ static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
>  static inline bool res_counter_check_under_limit(struct res_counter *cnt)
>  {
>        bool ret;
> -       unsigned long flags;
> +       unsigned long flags, seq;
>
> -       spin_lock_irqsave(&cnt->lock, flags);
> -       ret = res_counter_limit_check_locked(cnt);
> -       spin_unlock_irqrestore(&cnt->lock, flags);
> +       do {
> +               seq = read_seqbegin_irqsave(&cnt->lock, flags);
> +               ret = res_counter_limit_check_locked(cnt);
> +       } while (read_seqretry_irqrestore(&cnt->lock, seq, flags));
>        return ret;
>  }
>
> @@ -151,18 +153,18 @@ static inline void res_counter_reset_max(struct res_counter *cnt)
>  {
>        unsigned long flags;
>
> -       spin_lock_irqsave(&cnt->lock, flags);
> +       write_seqlock_irqsave(&cnt->lock, flags);
>        cnt->max_usage = cnt->usage;
> -       spin_unlock_irqrestore(&cnt->lock, flags);
> +       write_sequnlock_irqrestore(&cnt->lock, flags);
>  }
>
>  static inline void res_counter_reset_failcnt(struct res_counter *cnt)
>  {
>        unsigned long flags;
>
> -       spin_lock_irqsave(&cnt->lock, flags);
> +       write_seqlock_irqsave(&cnt->lock, flags);
>        cnt->failcnt = 0;
> -       spin_unlock_irqrestore(&cnt->lock, flags);
> +       write_sequnlock_irqrestore(&cnt->lock, flags);
>  }
>
>  static inline int res_counter_set_limit(struct res_counter *cnt,
> @@ -171,12 +173,12 @@ static inline int res_counter_set_limit(struct res_counter *cnt,
>        unsigned long flags;
>        int ret = -EBUSY;
>
> -       spin_lock_irqsave(&cnt->lock, flags);
> +       write_seqlock_irqsave(&cnt->lock, flags);
>        if (cnt->usage <= limit) {
>                cnt->limit = limit;
>                ret = 0;
>        }
> -       spin_unlock_irqrestore(&cnt->lock, flags);
> +       write_sequnlock_irqrestore(&cnt->lock, flags);
>        return ret;
>  }
>
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index e1338f0..9830c00 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -17,7 +17,7 @@
>
>  void res_counter_init(struct res_counter *counter, struct res_counter *parent)
>  {
> -       spin_lock_init(&counter->lock);
> +       seqlock_init(&counter->lock);
>        counter->limit = RESOURCE_MAX;
>        counter->parent = parent;
>  }
> @@ -45,9 +45,9 @@ int res_counter_charge(struct res_counter *counter, unsigned long val,
>        *limit_fail_at = NULL;
>        local_irq_save(flags);
>        for (c = counter; c != NULL; c = c->parent) {
> -               spin_lock(&c->lock);
> +               write_seqlock(&c->lock);
>                ret = res_counter_charge_locked(c, val);
> -               spin_unlock(&c->lock);
> +               write_sequnlock(&c->lock);
>                if (ret < 0) {
>                        *limit_fail_at = c;
>                        goto undo;
> @@ -57,9 +57,9 @@ int res_counter_charge(struct res_counter *counter, unsigned long val,
>        goto done;
>  undo:
>        for (u = counter; u != c; u = u->parent) {
> -               spin_lock(&u->lock);
> +               write_seqlock(&u->lock);
>                res_counter_uncharge_locked(u, val);
> -               spin_unlock(&u->lock);
> +               write_sequnlock(&u->lock);
>        }
>  done:
>        local_irq_restore(flags);
> @@ -81,9 +81,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
>
>        local_irq_save(flags);
>        for (c = counter; c != NULL; c = c->parent) {
> -               spin_lock(&c->lock);
> +               write_seqlock(&c->lock);
>                res_counter_uncharge_locked(c, val);
> -               spin_unlock(&c->lock);
> +               write_sequnlock(&c->lock);
>        }
>        local_irq_restore(flags);
>  }
> @@ -167,9 +167,9 @@ int res_counter_write(struct res_counter *counter, int member,
>                if (*end != '\0')
>                        return -EINVAL;
>        }
> -       spin_lock_irqsave(&counter->lock, flags);
> +       write_seqlock_irqsave(&counter->lock, flags);
>        val = res_counter_member(counter, member);
>        *val = tmp;
> -       spin_unlock_irqrestore(&counter->lock, flags);
> +       write_sequnlock_irqrestore(&counter->lock, flags);
>        return 0;
>  }
>
> --
>        Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
