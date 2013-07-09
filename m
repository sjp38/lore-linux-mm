Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id DACCB6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 19:41:28 -0400 (EDT)
Date: Wed, 10 Jul 2013 01:40:06 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [RFC] mm: Honor min_free_kbytes set by user
In-Reply-To: <20130704162005.GE7833@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.00.1307100139220.4045@twin.jikos.cz>
References: <1372954036-16988-1-git-send-email-mhocko@suse.cz> <1372954239.1886.40.camel@joe-AO722> <20130704161641.GD7833@dhcp22.suse.cz> <20130704162005.GE7833@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 4 Jul 2013, Michal Hocko wrote:

> On Thu 04-07-13 18:16:41, Michal Hocko wrote:
> > On Thu 04-07-13 09:10:39, Joe Perches wrote:
> > > On Thu, 2013-07-04 at 18:07 +0200, Michal Hocko wrote:
> > > > A warning is printed when the new value is ignored.
> > > 
> > > []
> > > 
> > > > +		printk(KERN_WARNING "min_free_kbytes is not updated to %d"
> > > > +				"because user defined value %d is preferred\n",
> > > > +				new_min_free_kbytes, user_min_free_kbytes);
> > > 
> > > Please use pr_warn and coalesce the format.
> > 
> > Sure can do that. mm/page_alloc.c doesn't seem to be unified in that
> > regards (44 printks and only 4 pr_<foo>) so I used printk.
> > 
> > > You'd've noticed a missing space between %d and because.
> > 
> > True
> > 
> 
> Checkpatch fixes
> ---
> >From 5f089c0b2a57ff6c08710ac9698d65aede06079f Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 4 Jul 2013 17:15:54 +0200
> Subject: [PATCH] mm: Honor min_free_kbytes set by user
> 
> min_free_kbytes is updated during memory hotplug (by init_per_zone_wmark_min)
> currently which is right thing to do in most cases but this could be
> unexpected if admin increased the value to prevent from allocation
> failures and the new min_free_kbytes would be decreased as a result of
> memory hotadd.
> 
> This patch saves the user defined value and allows updating
> min_free_kbytes only if it is higher than the saved one.
> 
> A warning is printed when the new value is ignored.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/page_alloc.c | 24 +++++++++++++++++-------
>  1 file changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 22c528e..9c011fc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -204,6 +204,7 @@ static char * const zone_names[MAX_NR_ZONES] = {
>  };
>  
>  int min_free_kbytes = 1024;
> +int user_min_free_kbytes;

Minor nit: any reason this can't be static?

>  
>  static unsigned long __meminitdata nr_kernel_pages;
>  static unsigned long __meminitdata nr_all_pages;
> @@ -5592,14 +5593,21 @@ static void __meminit setup_per_zone_inactive_ratio(void)
>  int __meminit init_per_zone_wmark_min(void)
>  {
>  	unsigned long lowmem_kbytes;
> +	int new_min_free_kbytes;
>  
>  	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
> -
> -	min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
> -	if (min_free_kbytes < 128)
> -		min_free_kbytes = 128;
> -	if (min_free_kbytes > 65536)
> -		min_free_kbytes = 65536;
> +	new_min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
> +
> +	if (new_min_free_kbytes > user_min_free_kbytes) {
> +		min_free_kbytes = new_min_free_kbytes;
> +		if (min_free_kbytes < 128)
> +			min_free_kbytes = 128;
> +		if (min_free_kbytes > 65536)
> +			min_free_kbytes = 65536;
> +	} else {
> +		pr_warn("min_free_kbytes is not updated to %d because user defined value %d is preferred\n",
> +				new_min_free_kbytes, user_min_free_kbytes);
> +	}
>  	setup_per_zone_wmarks();
>  	refresh_zone_stat_thresholds();
>  	setup_per_zone_lowmem_reserve();
> @@ -5617,8 +5625,10 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
>  	void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	proc_dointvec(table, write, buffer, length, ppos);
> -	if (write)
> +	if (write) {
> +		user_min_free_kbytes = min_free_kbytes;
>  		setup_per_zone_wmarks();
> +	}
>  	return 0;
>  }
>  
> 

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
