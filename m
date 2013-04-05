Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id D8F726B0027
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 21:09:34 -0400 (EDT)
Received: by mail-ie0-f202.google.com with SMTP id qd14so795867ieb.5
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 18:09:34 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 03/28] dcache: convert dentry_stat.nr_unused to per-cpu counters
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-4-git-send-email-glommer@parallels.com>
Date: Thu, 04 Apr 2013 18:09:31 -0700
Message-ID: <xr93r4ipkcl0.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>

On Fri, Mar 29 2013, Glauber Costa wrote:

> From: Dave Chinner <dchinner@redhat.com>
>
> Before we split up the dcache_lru_lock, the unused dentry counter
> needs to be made independent of the global dcache_lru_lock. Convert
> it to per-cpu counters to do this.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/dcache.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index fbfae008..f1196f2 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -118,6 +118,7 @@ struct dentry_stat_t dentry_stat = {
>  };
>  
>  static DEFINE_PER_CPU(unsigned int, nr_dentry);
> +static DEFINE_PER_CPU(unsigned int, nr_dentry_unused);
>  
>  #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
>  static int get_nr_dentry(void)
> @@ -129,10 +130,20 @@ static int get_nr_dentry(void)
>  	return sum < 0 ? 0 : sum;
>  }
>  
> +static int get_nr_dentry_unused(void)
> +{
> +	int i;
> +	int sum = 0;
> +	for_each_possible_cpu(i)
> +		sum += per_cpu(nr_dentry_unused, i);
> +	return sum < 0 ? 0 : sum;
> +}

Just checking...  If cpu x is removed, then its per cpu nr_dentry_unused
count survives so we don't leak nr_dentry_unused.  Right?  I see code in
percpu_counter_sum_positive() to explicitly handle this case and I want
to make sure we don't need it here.

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
