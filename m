Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m5K5G9wQ013543
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 06:16:09 +0100
Received: from an-out-0708.google.com (ancc35.prod.google.com [10.100.29.35])
	by zps77.corp.google.com with ESMTP id m5K5G8G2030315
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 22:16:08 -0700
Received: by an-out-0708.google.com with SMTP id c35so227221anc.44
        for <linux-mm@kvack.org>; Thu, 19 Jun 2008 22:16:08 -0700 (PDT)
Message-ID: <6599ad830806192216m41027e09r7605b9f85c283ae8@mail.gmail.com>
Date: Thu, 19 Jun 2008 22:16:07 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 2/2] memcg: reduce usage at change limit
In-Reply-To: <20080617123604.c8cb1bd5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080617123144.ce5a74fa.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080617123604.c8cb1bd5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 16, 2008 at 8:36 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Reduce the usage of res_counter at the change of limit.
>
> Changelog v4 -> v5.
>  - moved "feedback" alogrithm from res_counter to memcg.

FWIW, I really thought it was much better having it in the generic res_counter.

Paul

>
> Background:
>  - Now, mem->usage is not reduced at limit change. So, the users will see
>   usage > limit case in memcg every time. This patch fixes it.
>
>  Before:
>  - no usage change at setting limit.
>  - setting limit always returns 0 even if usage can never be less than zero.
>   (This can happen when memory is locked or there is no swap.)
>  - This is BUG, I think.
>  After:
>  - usage will be less than new limit at limit change.
>  - set limit returns -EBUSY when the usage cannot be reduced.
>
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
>  Documentation/controllers/memory.txt |    3 -
>  mm/memcontrol.c                      |   68 ++++++++++++++++++++++++++++-------
>  2 files changed, 56 insertions(+), 15 deletions(-)
>
> Index: mm-2.6.26-rc5-mm3/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.26-rc5-mm3.orig/mm/memcontrol.c
> +++ mm-2.6.26-rc5-mm3/mm/memcontrol.c
> @@ -852,18 +852,30 @@ out:
>        css_put(&mem->css);
>        return ret;
>  }
> +/*
> + * try to set limit and reduce usage if necessary.
> + * returns 0 at success.
> + * returns -EBUSY if memory cannot be dropped.
> + */
>
> -static int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
> +static inline int mem_cgroup_resize_limit(struct cgroup *cont,
> +                                       unsigned long long val)
>  {
> -       *tmp = memparse(buf, &buf);
> -       if (*buf != '\0')
> -               return -EINVAL;
> +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +       int retry_count = 0;
> +       int progress;
>
> -       /*
> -        * Round up the value to the closest page size
> -        */
> -       *tmp = ((*tmp + PAGE_SIZE - 1) >> PAGE_SHIFT) << PAGE_SHIFT;
> -       return 0;
> +retry:
> +       if (!res_counter_set_limit(&memcg->res, val))
> +               return 0;
> +       if (retry_count == MEM_CGROUP_RECLAIM_RETRIES)
> +               return -EBUSY;
> +
> +       cond_resched();
> +       progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
> +       if (!progress)
> +               retry_count++;
> +       goto retry;
>  }
>
>  static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
> @@ -874,11 +886,41 @@ static u64 mem_cgroup_read(struct cgroup
>
>  static ssize_t mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>                                struct file *file, const char __user *userbuf,
> -                               size_t nbytes, loff_t *ppos)
> +                               size_t bbytes, loff_t *ppos)
>  {
> -       return res_counter_write(&mem_cgroup_from_cont(cont)->res,
> -                               cft->private, userbuf, nbytes, ppos,
> -                               mem_cgroup_write_strategy);
> +       char *buf, *end;
> +       unsigned long long val;
> +       int ret;
> +
> +       buf = kmalloc(bbytes + 1, GFP_KERNEL);
> +       if (!buf)
> +               return -ENOMEM;
> +       buf[bbytes] = '\0';
> +       ret = -EFAULT;
> +       if (copy_from_user(buf, userbuf, bbytes))
> +               goto out;
> +
> +       ret = -EINVAL;
> +       strstrip(buf);
> +       val = memparse(buf, &end);
> +       if (*end != '\0')
> +               goto out;
> +       /* Round to page size */
> +       val = ((val + PAGE_SIZE - 1) >> PAGE_SHIFT) << PAGE_SHIFT;
> +
> +       switch(cft->private) {
> +       case RES_LIMIT:
> +               ret = mem_cgroup_resize_limit(cont, val);
> +               break;
> +       default:
> +               ret = -EINVAL;
> +               goto out;
> +       }
> +       if (!ret)
> +               ret = bbytes;
> +out:
> +       kfree(buf);
> +       return ret;
>  }
>
>  static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
> Index: mm-2.6.26-rc5-mm3/Documentation/controllers/memory.txt
> ===================================================================
> --- mm-2.6.26-rc5-mm3.orig/Documentation/controllers/memory.txt
> +++ mm-2.6.26-rc5-mm3/Documentation/controllers/memory.txt
> @@ -242,8 +242,7 @@ rmdir() if there are no tasks.
>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
>  3. Teach controller to account for shared-pages
> -4. Start reclamation when the limit is lowered
> -5. Start reclamation in the background when the limit is
> +4. Start reclamation in the background when the limit is
>    not yet hit but the usage is getting closer
>
>  Summary
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
