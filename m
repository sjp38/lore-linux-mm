Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0FA886B0033
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 12:35:48 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y14so1230311pdi.30
        for <linux-mm@kvack.org>; Thu, 04 Jul 2013 09:35:48 -0700 (PDT)
Message-ID: <51D5A458.7000105@gmail.com>
Date: Fri, 05 Jul 2013 00:35:36 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: Honor min_free_kbytes set by user
References: <1372954036-16988-1-git-send-email-mhocko@suse.cz> <1372954239.1886.40.camel@joe-AO722> <20130704161641.GD7833@dhcp22.suse.cz> <20130704162005.GE7833@dhcp22.suse.cz>
In-Reply-To: <20130704162005.GE7833@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/05/2013 12:20 AM, Michal Hocko wrote:

[snip]

> ---
> From 5f089c0b2a57ff6c08710ac9698d65aede06079f Mon Sep 17 00:00:00 2001
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

Looks reasonable.

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

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


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
