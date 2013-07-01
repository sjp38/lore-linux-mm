Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 6DFE36B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 04:51:06 -0400 (EDT)
Date: Mon, 1 Jul 2013 10:51:03 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] vmpressure: implement strict mode
Message-ID: <20130701085103.GA19798@amd.pavel.ucw.cz>
References: <20130625175129.7c0d79e1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130625175129.7c0d79e1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, minchan@kernel.org, anton@enomsg.org, akpm@linux-foundation.org

Hi!

> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index ddf4f93..3c589cf 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -807,12 +807,14 @@ register a notification, an application must:
>  
>  - create an eventfd using eventfd(2);
>  - open memory.pressure_level;
> -- write string like "<event_fd> <fd of memory.pressure_level> <level>"
> +- write string like "<event_fd> <fd of memory.pressure_level> <level> [strict]"
>    to cgroup.event_control.
>  

This is.. pretty strange interface. Would it be cleaner to do ioctl()?
New syscall?

> @@ -303,22 +307,33 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>  {
>  	struct vmpressure *vmpr = cg_to_vmpressure(cg);
>  	struct vmpressure_event *ev;
> +	bool smode = false;
> +	const char *p;
>  	int level;
>  
>  	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
> -		if (!strcmp(vmpressure_str_levels[level], args))
> +		p = vmpressure_str_levels[level];
> +		if (!strncmp(p, args, strlen(p)))
>  			break;
>  	}
>  
>  	if (level >= VMPRESSURE_NUM_LEVELS)
>  		return -EINVAL;
>  
> +	p = strchr(args, ' ');
> +	if (p) {
> +		if (strncmp(++p, "strict", 6))
> +			return -EINVAL;
> +		smode = true;
> +	}
> +

This looks like something for bash, not for kernel :-(.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
