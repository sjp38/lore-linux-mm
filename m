Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 302246B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 08:53:35 -0400 (EDT)
Date: Wed, 19 Jun 2013 14:53:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4] memcg: event control at vmpressure.
Message-ID: <20130619125329.GB16457@dhcp22.suse.cz>
References: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
 <20130617131551.GA5018@dhcp22.suse.cz>
 <CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

OK, this looks much better. Few nitpicks bellow.

On Wed 19-06-13 20:31:16, Hyunhee Kim wrote:
> In the original vmpressure, events are triggered whenever there is a reclaim
> activity. This becomes overheads to user space module and also increases
> power consumption if there is somebody to listen to it. This patch provides
> options to trigger events only when the pressure level changes.
> This trigger option can be set when registering each event by writing
> a trigger option, "edge" or "always", next to the string of levels.
> "edge" means that the event is triggered only when the pressure level is changed.
> "always" means that events are triggered whenever there is a reclaim process.
> To keep backward compatibility, "always" is set by default if nothing is input
> as an option. Each event can have different option. For example,
> "low" level uses "always" trigger option to see reclaim activity at user space
> while "medium"/"critical" uses "edge" to do an important job
> like killing tasks only once.
> 
> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  Documentation/cgroups/memory.txt |   12 ++++++++++--
>  mm/vmpressure.c                  |   32 ++++++++++++++++++++++++++++----
>  2 files changed, 38 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index ddf4f93..181a11f 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -791,6 +791,13 @@ way to trigger. Applications should do whatever they can to help the
>  system. It might be too late to consult with vmstat or any other
>  statistics, so it's advisable to take an immediate action.
>  
> +Events can be triggered whenever there is a reclaim activity or
> +only when the pressure level changes. Trigger option is decided
> +by writing it next to level. The event whose trigger option is "always"
> +is triggered whenever there is a reclaim process. If "edge" is set,
> +the event is triggered only when the level is changed.
> +If the trigger option is not set, "always" is set by default.
> +

I would move this information bellow where the usage is described.

>  The events are propagated upward until the event is handled, i.e. the
>  events are not pass-through. Here is what this means: for example you have
>  three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
[...]
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..4f676b8 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
[...]
> @@ -303,10 +310,21 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>  {
>  	struct vmpressure *vmpr = cg_to_vmpressure(cg);
>  	struct vmpressure_event *ev;
> +	char *strlevel = NULL, *strtrigger = NULL, *p = NULL;
>  	int level;
>  
> +	p = strchr(args, ' ');
> +
> +	if (p) {
> +		strtrigger = p + 1;
> +		*p = '\0';
> +		strlevel = (char *)args;
> +	} else {
> +		strlevel = (char *)args;
> +	}
> +

This is a total nit but this can be further simplified.
	strlevel = args;
	strtrigger = strchr(args, ' ');
	if (strtrigger) {
		*strtrigger = '\0';
		strtrigger++;
	}
I would still rather see using sscanf but that is just a matter of taste
I guess.

>  	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
> -		if (!strcmp(vmpressure_str_levels[level], args))
> +		if (!strcmp(vmpressure_str_levels[level], strlevel))
>  			break;
>  	}
>  
> @@ -319,6 +337,12 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>  
>  	ev->efd = eventfd;
>  	ev->level = level;
> +	ev->last_level = -1;
> +
> +	if (strtrigger && !strcmp(strtrigger, "edge"))
> +		ev->edge_trigger = true;
> +	else
> +		ev->edge_trigger = false;

I guess it would be more appropriate to return EINVAL if the trigger is
neither always nor edge because we might end up with abuses where
somebody start relying on "foo" implying "always".

The history tells that user interface should be really careful about not
allowing "undocumented but happen to work" behavior.

>  	mutex_lock(&vmpr->events_lock);
>  	list_add(&ev->node, &vmpr->events);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
