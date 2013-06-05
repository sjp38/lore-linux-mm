Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 07E166B0036
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:07:33 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:07:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 03/35] dcache: convert dentry_stat.nr_unused to
 per-cpu counters
Message-Id: <20130605160731.91a5cd3ff700367f5e155d83@linux-foundation.org>
In-Reply-To: <1370287804-3481-4-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-4-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Mon,  3 Jun 2013 23:29:32 +0400 Glauber Costa <glommer@openvz.org> wrote:

> From: Dave Chinner <dchinner@redhat.com>
> 
> Before we split up the dcache_lru_lock, the unused dentry counter
> needs to be made independent of the global dcache_lru_lock. Convert
> it to per-cpu counters to do this.
> 
> ...
>
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -118,8 +118,10 @@ struct dentry_stat_t dentry_stat = {
>  };
>  
>  static DEFINE_PER_CPU(long, nr_dentry);
> +static DEFINE_PER_CPU(long, nr_dentry_unused);
>  
>  #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
> +/* scan possible cpus instead of online and avoid worrying about CPU hotplug. */

That's a poor comment.  It explains what the code does (which is dead
obvious) but fails to explain *why* the code does it.

> @@ -129,10 +131,20 @@ static long get_nr_dentry(void)
>  	return sum < 0 ? 0 : sum;
>  }
>  
> +static long get_nr_dentry_unused(void)
> +{
> +	int i;
> +	long sum = 0;
> +	for_each_possible_cpu(i)
> +		sum += per_cpu(nr_dentry_unused, i);
> +	return sum < 0 ? 0 : sum;
> +}

And I'm sure we've asked and answered ad nauseum why this code needed
to open-code the counters instead of using the provided library code,
yet the answer to that *still* isn't in the code comments or even in
the changelog.  It should be.


Given that the existing proc_nr_dentry() will suck mud rocks on
large-cpu-count machines (due to get_nr_dentry()), I guess we can
assume that nobody will be especially hurt by making proc_nr_dentry()
suck even harder...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
