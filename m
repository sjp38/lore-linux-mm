Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 09FE36B0036
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 03:35:52 -0400 (EDT)
Date: Wed, 26 Jun 2013 16:35:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] memcg: consider "scanned < reclaimed" case when
 calculating
Message-ID: <20130626073557.GD29127@bbox>
References: <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Sat, Jun 22, 2013 at 02:50:06PM +0900, Hyunhee Kim wrote:
> In vmpressure, the pressure level is calculated based on the ratio
> of how many pages were scanned vs. reclaimed in a given time window.
> However, there is a possibility that "scanned < reclaimed" in such
> a case, THP page is reclaimed or reclaiming is abandoned by fatal
> signal in shrink_inactive_list, etc. So, with this patch, we just
> return "low" level when "scanned < reclaimed" by assuming that
> there are enough reclaimed pages.

I agree send lowevent in this case but you should write down why
lowevent send is better than ignoring in description. 

> 
> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/vmpressure.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..c6560f3 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -118,6 +118,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  	unsigned long scale = scanned + reclaimed;
>  	unsigned long pressure;
>  

Please write when we encounter this case.

> +	if (reclaimed > scanned)
> +		return VMPRESSURE_LOW;
> +
>  	/*
>  	 * We calculate the ratio (in percents) of how many pages were
>  	 * scanned vs. reclaimed in a given time frame (window). Note that
> -- 
> 1.7.9.5
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
