Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id DE18A6B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 04:40:38 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so680925eak.2
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 01:40:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si3308979eem.132.2014.01.08.01.40.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 01:40:37 -0800 (PST)
Date: Wed, 8 Jan 2014 10:40:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: prevent set a value less than 0 to min_free_kbytes
Message-ID: <20140108094036.GA27937@dhcp22.suse.cz>
References: <20140108084242.GA10485@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140108084242.GA10485@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

On Wed 08-01-14 16:42:42, Han Pingtian wrote:
> If echo -1 > /proc/vm/sys/min_free_kbytes, the system will hang.
> Changing proc_dointvec() to proc_dointvec_minmax() in the
> min_free_kbytes_sysctl_handler() can prevent this to happen.

You can still do echo $BIG_VALUE > /proc/vm/sys/min_free_kbytes and make
your machine unusable but I agree that proc_dointvec_minmax is more
suitable here as we already have:
		.proc_handler   = min_free_kbytes_sysctl_handler,
		.extra1         = &zero,

It used to work properly but then 6fce56ec91b5 (sysctl: Remove
references to ctl_name and strategy from the generic sysctl table) has
removed sysctl_intvec strategy and so extra1 is ignored.

> Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>

That being said I do not think this will fix any real world problem but
just for sake of correctness

After changelog is updated feel free to add my
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_alloc.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 77937e0..a9dcfd8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5692,7 +5692,12 @@ module_init(init_per_zone_wmark_min)
>  int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
>  	void __user *buffer, size_t *length, loff_t *ppos)
>  {
> -	proc_dointvec(table, write, buffer, length, ppos);
> +	int rc;
> +
> +	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
> +	if (rc)
> +		return rc;
> +
>  	if (write) {
>  		user_min_free_kbytes = min_free_kbytes;
>  		setup_per_zone_wmarks();
> -- 
> 1.7.7.6
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
