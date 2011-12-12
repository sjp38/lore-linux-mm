Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9E3706B0187
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:54:20 -0500 (EST)
Date: Mon, 12 Dec 2011 15:54:13 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH v2] page_cgroup: add helper function to get swap_cgroup
Message-ID: <20111212145413.GC18789@redhat.com>
References: <1322822427-7691-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1322822427-7691-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, bsingharora@gmail.com

On Fri, Dec 02, 2011 at 06:40:27PM +0800, Bob Liu wrote:
> There are multi places need to get swap_cgroup, so add a helper
> function:
> static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent,
>                                 struct swap_cgroup_ctrl **ctrl);
> to simple the code.
> 
> v1 -> v2:
>  - add parameter struct swap_cgroup_ctrl **ctrl suggested by Michal
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/page_cgroup.c |   57 ++++++++++++++++++++++-------------------------------
>  1 files changed, 24 insertions(+), 33 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index f0559e0..1970e8a 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -362,6 +362,27 @@ not_enough_page:
>  	return -ENOMEM;
>  }

I realize that you mostly moved what was already there, but there are
a couple more things to clean up.  Would you like to send a patch for
them as well?

> +static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent,
> +					struct swap_cgroup_ctrl **ctrl)

__lookup_swap_cgroup()?  Or even more matching names would be to have
that public interface called lookup_swap_cgroup_id() and let this one
be lookup_swap_cgroup().

> +{
> +	int type = swp_type(ent);

swp_type() returns unsigned int

> +	unsigned long offset = swp_offset(ent);

swp_offset() returns pgoff_t

> +	unsigned long idx = offset / SC_PER_PAGE;
> +	unsigned long pos = offset & SC_POS_MASK;

This is actually quite crappy, the definition looks like this:

#define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
#define SC_POS_MASK	(SC_PER_PAGE - 1)

which relies on the fact that the division named SC_PER_PAGE yields a
power of two, which only is true by accident.

Better would be to delete SC_POS_MASK and use offset % SC_PER_PAGE
instead.

> +	struct swap_cgroup_ctrl *temp_ctrl;
> +	struct page *mappage;
> +	struct swap_cgroup *sc;
> +
> +	temp_ctrl = &swap_cgroup_ctrl[type];
> +	if (ctrl)
> +		*ctrl = temp_ctrl;

Name the output parameter ctrlp instead?  Then you can call the local
one ctrl.

Also, type is only used once, better to just inline it:

	&swap_cgroup_ctrl[swp_type(ent)]

> +	mappage = temp_ctrl->map[idx];

Same for idx, just use ctrl->map[offset / SC_PER_PAGE] directly.

> +	sc = page_address(mappage);
> +	sc += pos;
> +	return sc;
> +}

That seems elaborate.

	return page_address(mappage) + offset % SC_PER_PAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
