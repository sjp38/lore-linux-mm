Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D82F06B00DF
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 09:37:20 -0400 (EDT)
Date: Tue, 30 Apr 2013 14:37:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 03/31] dcache: convert dentry_stat.nr_unused to
 per-cpu counters
Message-ID: <20130430133716.GC6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-4-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-4-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:18:59AM +0400, Glauber Costa wrote:
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
> index e689268..8df1cd9 100644
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
> +

I was going to raise questions on the use of for_each_possible_cpu() and
ask why it was not for_each_online_cpu() but I see now that it has been
discussed already -- it's to avoid lost counters from offlined CPUs
without having to cope with CPU hotplug just to keep a proc handler
happy.

A comment either here or in the changelog saying that
for_each_possible_cpu() is deliberate would not hurt in case someone
tries to "fix" this but it's no big deal so

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
