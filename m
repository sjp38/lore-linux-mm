Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 945CC6B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 04:56:55 -0500 (EST)
Date: Fri, 2 Dec 2011 10:56:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] page_cgroup: add helper function to get swap_cgroup
Message-ID: <20111202095646.GA21070@tiehlicka.suse.cz>
References: <1322818931-2674-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1322818931-2674-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, jweiner@redhat.com, bsingharora@gmail.com

On Fri 02-12-11 17:42:11, Bob Liu wrote:
> There are multi places need to get swap_cgroup, so add a helper
> function:
> static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent);
> to simple the code.

I like the cleanup but I guess we can do a little bit better ;)

[...]
> +static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent)

Add struct swap_cgroup_ctrl ** ctrl parameter

> +{
> +	int type = swp_type(ent);
> +	unsigned long offset = swp_offset(ent);
> +	unsigned long idx = offset / SC_PER_PAGE;
> +	unsigned long pos = offset & SC_POS_MASK;
> +	struct swap_cgroup_ctrl *ctrl;
> +	struct page *mappage;
> +	struct swap_cgroup *sc;
> +
> +	ctrl = &swap_cgroup_ctrl[type];

	if (ctrl)
		*ctrl = &swap_cgroup_ctrl[type]

[...]
> @@ -375,20 +393,14 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>  					unsigned short old, unsigned short new)
>  {
>  	int type = swp_type(ent);
> -	unsigned long offset = swp_offset(ent);
> -	unsigned long idx = offset / SC_PER_PAGE;
> -	unsigned long pos = offset & SC_POS_MASK;
>  	struct swap_cgroup_ctrl *ctrl;
> -	struct page *mappage;
>  	struct swap_cgroup *sc;
>  	unsigned long flags;
>  	unsigned short retval;
>  
>  	ctrl = &swap_cgroup_ctrl[type];
> +	sc = swap_cgroup_getsc(ent);

	sc = swap_cgroup_getsc(ent, &ctrl);
[...]
> @@ -410,20 +422,14 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>  unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>  {
>  	int type = swp_type(ent);
> -	unsigned long offset = swp_offset(ent);
> -	unsigned long idx = offset / SC_PER_PAGE;
> -	unsigned long pos = offset & SC_POS_MASK;
>  	struct swap_cgroup_ctrl *ctrl;
> -	struct page *mappage;
>  	struct swap_cgroup *sc;
>  	unsigned short old;
>  	unsigned long flags;
>  
>  	ctrl = &swap_cgroup_ctrl[type];
> +	sc = swap_cgroup_getsc(ent);

Same here

[...]
> @@ -440,21 +446,10 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>   */
>  unsigned short lookup_swap_cgroup(swp_entry_t ent)
>  {
> -	int type = swp_type(ent);
> -	unsigned long offset = swp_offset(ent);
> -	unsigned long idx = offset / SC_PER_PAGE;
> -	unsigned long pos = offset & SC_POS_MASK;
> -	struct swap_cgroup_ctrl *ctrl;
> -	struct page *mappage;
>  	struct swap_cgroup *sc;
> -	unsigned short ret;
>  
> -	ctrl = &swap_cgroup_ctrl[type];
> -	mappage = ctrl->map[idx];
> -	sc = page_address(mappage);
> -	sc += pos;
> -	ret = sc->id;
> -	return ret;
> +	sc = swap_cgroup_getsc(ent);
> +	return sc->id;

	return swap_cgroup_getsc(ent, NULL)->id;

What do you think?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
