Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2E9626B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 14:33:13 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr13so1265880pbb.34
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:33:12 -0700 (PDT)
Date: Thu, 27 Jun 2013 11:33:09 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Message-ID: <20130627183309.GB2276@teo>
References: <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <20130626073557.GD29127@bbox>
 <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Michal Hocko' <mhocko@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Minchan Kim' <minchan@kernel.org>

On Thu, Jun 27, 2013 at 03:12:10PM +0900, Hyunhee Kim wrote:
> In vmpressure, the pressure level is calculated based on the ratio
> of how many pages were scanned vs. reclaimed in a given time window.
> However, there is a possibility that "scanned < reclaimed" in such a
> case, when reclaiming ends by fatal signal in shrink_inactive_list.
> So, with this patch, we just return "low" level when "scanned < reclaimed"
> happens not to have userland miss reclaim activity.
> 
> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/vmpressure.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..8c60cad 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -119,6 +119,14 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  	unsigned long pressure;
>  
>  	/*
> +	 * This could happen, in such a case, when reclaiming ends by fatal
> +	 * signal in shrink_inactive_list(). In this case, return
> +	 * VMPRESSURE_LOW not to have userland miss reclaim activity.
> +	 */

Personally, I like to see this condition as a generic case: reclaimed >
scanned condition can't tell anything about the pressure itself, so the
best we can do is just report that there is some reclaiming happening
(i.e. signal _LOW level). It might be the fatal signal case, or THP, and I
so far don't see we we have to differentiate why exactly this condition
happened, at least from the vmpressure point of view...

It might be that in some cases we should not call vmpressure() callback
(i.e. when there is a fatal signals or something like that), but it is a
different matter.

There is another way to view the vmpressure subsystem. vmpressure() is
kind of a differential flow meter, which accounts the
reclaiming/allocation flow change. Ideally it should not matter why
exactly the reclaimed > scanned happened (unless we bogusly call
vmpressure() callback, in which case we should stop doing that).

So, I would add the comment about the generic case and why it makes sense
to return _LOW here, but other than that the patch looks good at least to
me.

Acked-by: Anton Vorontsov <anton@enomsg.org>

> +	if (reclaimed > scanned)
> +		return VMPRESSURE_LOW;
> +
> +	/*
>  	 * We calculate the ratio (in percents) of how many pages were
>  	 * scanned vs. reclaimed in a given time frame (window). Note that
>  	 * time is in VM reclaimer's "ticks", i.e. number of pages
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
