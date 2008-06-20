Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id m5K59L1Y000352
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 06:09:21 +0100
Received: from an-out-0708.google.com (andd40.prod.google.com [10.100.30.40])
	by spaceape14.eur.corp.google.com with ESMTP id m5K59KqO026719
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 06:09:20 +0100
Received: by an-out-0708.google.com with SMTP id d40so325704and.126
        for <linux-mm@kvack.org>; Thu, 19 Jun 2008 22:09:20 -0700 (PDT)
Message-ID: <6599ad830806192209j2a3909faob223b72de3d28b81@mail.gmail.com>
Date: Thu, 19 Jun 2008 22:09:20 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 1/6] res_counter: handle limit change
In-Reply-To: <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 13, 2008 at 2:29 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Add a support to shrink_usage_at_limit_change feature to res_counter.
> memcg will use this to drop pages.

Sorry for the delay in looking at this.

I think the basic idea is great.

>
> Change log: xxx -> v4 (new file.)
>  - cut out the limit-change part from hierarchy patch set.
>  - add "retry_count" arguments to shrink_usage(). This allows that we don't
>   have to set the default retry loop count.
>  - res_counter_check_under_val() is added to support subsystem.
>  - res_counter_init() is res_counter_init_ops(cnt, NULL)
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
>  Documentation/controllers/resource_counter.txt |   19 +++++-
>  include/linux/res_counter.h                    |   33 ++++++++++-
>  kernel/res_counter.c                           |   74 ++++++++++++++++++++++++-
>  3 files changed, 121 insertions(+), 5 deletions(-)
>
> Index: linux-2.6.26-rc5-mm3/include/linux/res_counter.h
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/include/linux/res_counter.h
> +++ linux-2.6.26-rc5-mm3/include/linux/res_counter.h
> @@ -21,6 +21,13 @@
>  * the helpers described beyond
>  */
>
> +struct res_counter;
> +struct res_counter_ops {
> +       /* called when the subsystem has to reduce the usage. */
> +       int (*shrink_usage)(struct res_counter *cnt, unsigned long long val,
> +                           int retry_count);
> +};

We should also add the limit/usage write strategy function in here too.


> +
>  struct res_counter {
>        /*
>         * the current resource consumption level
> @@ -39,6 +46,10 @@ struct res_counter {
>         */
>        unsigned long long failcnt;
>        /*
> +        * registered callbacks etc...for res_counter.
> +        */
> +       struct res_counter_ops ops;
> +       /*

As Pavel mentioned, a pointer would be better here.
> -void res_counter_init(struct res_counter *counter);
> +void res_counter_init_ops(struct res_counter *counter,
> +                               struct res_counter_ops *ops);
> +
> +static inline void res_counter_init(struct res_counter *counter)
> +{
> +       res_counter_init_ops(counter, NULL);
> +}

I would rather just see res_counter_init() take an ops parameter, and
update the (few) users of res_counter.


> +static int res_counter_resize_limit(struct res_counter *cnt,
> +                       unsigned long long val)
> +{
> +       int retry_count = 0;
> +       int ret = -EBUSY;
> +       unsigned long flags;
> +
> +       BUG_ON(!cnt->ops.shrink_usage);

As others have pointed out, there are some subsystems where usage
can't be shrunk. Maybe provide a "res_counter_unshrinkable()" function
that always returns -EBUSY and can be used by subsystems that can't
handle shrinking?

> @@ -133,11 +185,29 @@ ssize_t res_counter_write(struct res_cou
>                if (*end != '\0')
>                        goto out_free;
>        }
> +       switch (member) {
> +       case RES_LIMIT:
> +               if (counter->ops.shrink_usage) {
> +                       ret = res_counter_resize_limit(counter, tmp);
> +                       goto done;
> +               }
> +               break;
> +       default:
> +               /*
> +                * Considering future implementation, we'll have to handle
> +                * other members and "fallback" will not work well. So, we
> +                * avoid to make use of "default" here.
> +                */
> +               break;
> +       }

Would this be simpler as just

if (member == RES_LIMIT && counter->ops.shrink_usage) {
  ret = res_counter_resize_limit(counter, tmp);
} else {
  ...
}

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
