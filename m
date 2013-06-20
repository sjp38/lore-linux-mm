Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 4B0E66B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 08:16:54 -0400 (EDT)
Date: Thu, 20 Jun 2013 14:16:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] memcg: event control at vmpressure.
Message-ID: <20130620121649.GB27196@dhcp22.suse.cz>
References: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
 <20130617131551.GA5018@dhcp22.suse.cz>
 <CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Thu 20-06-13 11:17:39, Hyunhee Kim wrote:
[...]
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..3c37b12 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
[...]
> @@ -303,10 +310,19 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>  {
>  	struct vmpressure *vmpr = cg_to_vmpressure(cg);
>  	struct vmpressure_event *ev;
> +	char *strlevel = NULL, *strtrigger = NULL;

No need for initialization to NULL when both would be initialized below.

>  	int level;
>  
> +	strlevel = args;
> +	strtrigger = strchr(args, ' ');
> +
> +	if (strtrigger) {
> +		*strtrigger = '\0';
> +		strtrigger++;
> +	}
> +
>  	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
> -		if (!strcmp(vmpressure_str_levels[level], args))
> +		if (!strcmp(vmpressure_str_levels[level], strlevel))
>  			break;
>  	}
>  
> @@ -319,6 +335,16 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>  
>  	ev->efd = eventfd;
>  	ev->level = level;
> +	ev->last_level = -1;
> +
> +	if (strtrigger == NULL)
> +		ev->edge_trigger = false;
> +	else if (!strcmp(strtrigger, "always"))
> +		ev->edge_trigger = false;
> +	else if (!strcmp(strtrigger, "edge"))
> +		ev->edge_trigger = true;
> +	else
> +		return -EINVAL;

I have missed this before but this will cause a memory leak and worse it
is user controlled mem leak. Move this up after the level check.

>  	mutex_lock(&vmpr->events_lock);
>  	list_add(&ev->node, &vmpr->events);
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
