Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8F7F56B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 18:19:36 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so8627464pbc.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 15:19:35 -0700 (PDT)
Date: Mon, 16 Apr 2012 15:19:24 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/7] res_counter: add a function
 res_counter_move_parent().
Message-ID: <20120416221924.GB12421@google.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
 <4F86BA66.2010503@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F86BA66.2010503@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Apr 12, 2012 at 08:20:06PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> This function is used for moving accounting information to its
> parent in the hierarchy of res_counter.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/res_counter.h |    3 +++
>  kernel/res_counter.c        |   13 +++++++++++++
>  2 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index da81af0..8919d3c 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -135,6 +135,9 @@ int __must_check res_counter_charge_nofail(struct res_counter *counter,
>  void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
>  void res_counter_uncharge(struct res_counter *counter, unsigned long val);
>  
> +/* move resource to parent counter...i.e. just forget accounting in a child */

Can we drop this comment and

> +void res_counter_move_parent(struct res_counter *counter, unsigned long val);
>  
> +/*
> + * In hierarchical accounting, child's usage is accounted into ancestors.
> + * To move local usage to its parent, just forget current level usage.
> + */

make this one proper docbook function comment?

> +void res_counter_move_parent(struct res_counter *counter, unsigned long val)
> +{
> +	unsigned long flags;
> +
> +	BUG_ON(!counter->parent);

And let's please do "if (WARN_ON(!counter->parent)) return;" instead.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
