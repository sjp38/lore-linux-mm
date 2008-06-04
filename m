Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id m548xaHk009003
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 09:59:36 +0100
Received: from an-out-0708.google.com (anac8.prod.google.com [10.100.54.8])
	by spaceape8.eur.corp.google.com with ESMTP id m548xZUX027330
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 09:59:35 +0100
Received: by an-out-0708.google.com with SMTP id c8so649428ana.106
        for <linux-mm@kvack.org>; Wed, 04 Jun 2008 01:59:34 -0700 (PDT)
Message-ID: <6599ad830806040159w1026003fhe3212beac895927a@mail.gmail.com>
Date: Wed, 4 Jun 2008 01:59:12 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 2/2] memcg: hardwall hierarhcy for memcg
In-Reply-To: <20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 3, 2008 at 10:03 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> @@ -792,6 +798,89 @@ int mem_cgroup_shrink_usage(struct mm_st
>  }
>
>  /*
> + * Memory Controller hierarchy support.
> + */
> +
> +/*
> + * shrink usage to be res->usage + val < res->limit.
> + */
> +
> +int memcg_shrink_val(struct res_counter *cnt, unsigned long long val)
> +{
> +       struct mem_cgroup *memcg = container_of(cnt, struct mem_cgroup, res);
> +       unsigned long flags;
> +       int ret = 1;
> +       int progress = 1;
> +
> +retry:
> +       spin_lock_irqsave(&cnt->lock, flags);
> +       /* Need to shrink ? */
> +       if (cnt->usage + val <= cnt->limit)
> +               ret = 0;
> +       spin_unlock_irqrestore(&cnt->lock, flags);

Can't this logic be in res_counter itself? I.e. the callback can
assume that some shrinking needs to be done, and should just do it and
return. The res_counter can handle retrying if necessary.

> +/*
> + * For Hard Wall Hierarchy.
> + */
> +
> +int mem_cgroup_resize_callback(struct res_counter *cnt,
> +                       unsigned long long val, int what)
> +{
> +       unsigned long flags, borrow;
> +       unsigned long long diffs;
> +       int ret = 0;
> +
> +       BUG_ON(what != RES_LIMIT);
> +
> +       /* Is this under hierarchy ? */
> +       if (!cnt->parent) {
> +               spin_lock_irqsave(&cnt->lock, flags);
> +               cnt->limit = val;
> +               spin_unlock_irqrestore(&cnt->lock, flags);
> +               return 0;
> +       }
> +
> +       spin_lock_irqsave(&cnt->lock, flags);
> +       if (val > cnt->limit) {
> +               diffs = val - cnt->limit;
> +               borrow = 1;
> +       } else {
> +               diffs = cnt->limit - val;
> +               borrow = 0;
> +       }
> +       spin_unlock_irqrestore(&cnt->lock, flags);
> +
> +       if (borrow)
> +               ret = res_counter_move_resource(cnt,diffs,
> +                                       memcg_shrink_val,
> +                                       MEM_CGROUP_RECLAIM_RETRIES);
> +       else
> +               ret = res_counter_return_resource(cnt, diffs,
> +                                       memcg_shrink_val,
> +                                       MEM_CGROUP_RECLAIM_RETRIES);
> +       return ret;
> +}

Again, a lot of this function seems like generic logic that should be
in res_counter. The only bit that's memory specific is the
memcg_shrink_val, and maybe that could just be passed when creating
the res_counter. Perhaps we should have a res_counter_ops structure
with operations like "parse" for parsing strings into numbers
(currently called "write_strategy") and "reclaim" for trying to shrink
the usage.

> @@ -896,11 +987,44 @@ static ssize_t mem_cgroup_write(struct c
>                                struct file *file, const char __user *userbuf,
>                                size_t nbytes, loff_t *ppos)
>  {
> -       return res_counter_write(&mem_cgroup_from_cont(cont)->res,
> +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +
> +       if (cft->private != RES_LIMIT
> +               || !cont->parent
> +               || memcg->hierarchy_model == MEMCG_NO_HIERARCHY)

The res_counter already knows whether it has a parent, so these checks
shouldn't be necessary.

> @@ -1096,6 +1238,12 @@ static void mem_cgroup_destroy(struct cg
>        int node;
>        struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
>
> +       if (cont->parent &&
> +           mem->hierarchy_model == MEMCG_HARDWALL_HIERARCHY) {
> +               /* we did what we can...just returns what we borrow */
> +               res_counter_return_resource(&mem->res, -1, NULL, 0);
> +       }
> +

Should we also re-account any remaining child usage to the parent?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
