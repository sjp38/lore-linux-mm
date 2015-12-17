Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id EEBC96B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 19:44:24 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l126so61905168wml.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 16:44:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y127si15578036wmy.71.2015.12.16.16.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 16:44:23 -0800 (PST)
Date: Wed, 16 Dec 2015 19:44:14 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] mm: memcontrol: clean up alloc, online, offline,
 free functions
Message-ID: <20151217004414.GA27651@cmpxchg.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
 <1449863653-6546-4-git-send-email-hannes@cmpxchg.org>
 <20151214171455.GF28521@esperanza>
 <20151215193858.GA15265@cmpxchg.org>
 <20151216121727.GL28521@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151216121727.GL28521@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Dec 16, 2015 at 03:17:27PM +0300, Vladimir Davydov wrote:
> On Tue, Dec 15, 2015 at 02:38:58PM -0500, Johannes Weiner wrote:
> > On Mon, Dec 14, 2015 at 08:14:55PM +0300, Vladimir Davydov wrote:
> > > On Fri, Dec 11, 2015 at 02:54:13PM -0500, Johannes Weiner wrote:
> > > ...
> > > > -static int
> > > > -mem_cgroup_css_online(struct cgroup_subsys_state *css)
> > > > +static struct cgroup_subsys_state * __ref
> > > > +mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
> > > >  {
> > > > -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> > > > -	struct mem_cgroup *parent = mem_cgroup_from_css(css->parent);
> > > > -	int ret;
> > > > -
> > > > -	if (css->id > MEM_CGROUP_ID_MAX)
> > > > -		return -ENOSPC;
> > > > +	struct mem_cgroup *parent = mem_cgroup_from_css(parent_css);
> > > > +	struct mem_cgroup *memcg;
> > > > +	long error = -ENOMEM;
> > > >  
> > > > -	if (!parent)
> > > > -		return 0;
> > > > +	memcg = mem_cgroup_alloc();
> > > > +	if (!memcg)
> > > > +		return ERR_PTR(error);
> > > >  
> > > >  	mutex_lock(&memcg_create_mutex);
> > > 
> > > It is pointless to take memcg_create_mutex in ->css_alloc. It won't
> > > prevent setting use_hierarchy for parent after a new child was
> > > allocated, but before it was added to the list of children (see
> > > create_css()). Taking the mutex in ->css_online renders this race
> > > impossible. That is, your cleanup breaks use_hierarchy consistency
> > > check.
> > > 
> > > Can we drop this use_hierarchy consistency check at all and allow
> > > children of a cgroup with use_hierarchy=1 have use_hierarchy=0? Yeah,
> > > that might result in some strangeness if cgroups are created in parallel
> > > with use_hierarchy flipped, but is it a valid use case? I surmise, one
> > > just sets use_hierarchy for a cgroup once and for good before starting
> > > to create sub-cgroups.
> > 
> > I don't think we have to support airtight exclusion between somebody
> > changing the parent attribute and creating new children that inherit
> > these attributes. Everything will still work if this race happens.
> > 
> > Does that mean we have to remove the restriction altogether? I'm not
> > convinced. We can just keep it for historical purposes so that we do
> > not *encourage* this weird setting.
> 
> Well, legacy hierarchy is scheduled to die, so it's too late to
> encourage or discourage any setting regarding it.

That's the main reason I don't want to blatantly change the interface
at this point :)

> Besides, hierarchy mode must be enabled for 99% setups, because this is
> what systemd does at startup. So I don't think we would hurt anybody by
> dropping this check altogether - IMO it'd be fairer than having a check
> that might sometimes fail.

Yeah, I don't actually think anybody will run into this in practice,
but also want to keep changes to the legacy interface, user-visible or
not, at a minimum: fixing bugs and refactoring code for v2, basically.

> It's not something I really care about though, so I don't insist.

Thanks! I left it for now just to be safe.

> > @@ -2929,6 +2909,10 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
> >  
> >  static void memcg_free_kmem(struct mem_cgroup *memcg)
> >  {
> > +	/* css_alloc() failed, offlining didn't happen */
> > +	if (unlikely(memcg->kmem_state == KMEM_ONLINE))
> 
> It's not a hot-path, so there's no need in using 'unlikely' here apart
> from improving readability, but the comment should be enough.

Yeah it was entirely done for readability to reinforce that we
(almost) never expect this to happen. The comment elaborates and
explains it a bit, but the unlikely() carries the main signal.

> > +		memcg_offline_kmem(memcg);
> > +
> 
> Calling 'offline' from css_free looks a little bit awkward, but let it
> be.
> 
> Anyway, it's a really nice cleanup, thanks!
> 
> Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
