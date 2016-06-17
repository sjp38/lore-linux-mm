Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB0D16B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 12:25:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so1795358lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:25:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p4si534679wjz.184.2016.06.17.09.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 09:25:43 -0700 (PDT)
Date: Fri, 17 Jun 2016 12:23:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: fix cgroup creation failure after many
 small jobs
Message-ID: <20160617162310.GA19084@cmpxchg.org>
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616200617.GD3262@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jun 16, 2016 at 04:06:17PM -0400, Tejun Heo wrote:
> On Wed, Jun 15, 2016 at 11:42:44PM -0400, Johannes Weiner wrote:
> > @@ -6205,6 +6205,24 @@ struct cgroup *cgroup_get_from_path(const char *path)
> >  }
> >  EXPORT_SYMBOL_GPL(cgroup_get_from_path);
> >  
> > +/**
> > + * css_id_free - relinquish an existing CSS's ID
> > + * @css: the CSS
> > + *
> > + * This releases the @css's ID and allows it to be recycled while the
> > + * CSS continues to exist. This is useful for controllers with state
> > + * that extends past a cgroup's lifetime but doesn't need precious ID
> > + * address space.
> > + *
> > + * This invalidates @css->id, and css_from_id() might return NULL or a
> > + * new css if the ID has been recycled in the meantime.
> > + */
> > +void css_id_free(struct cgroup_subsys_state *css)
> > +{
> > +	cgroup_idr_remove(&css->ss->css_idr, css->id);
> > +	css->id = 0;
> > +}
> 
> I don't quite get why we're trying to free css->id earlier when memcg
> is gonna be using its private id anyway.  From cgroup core side, the
> id space isn't restricted.

For some reason I was thinking of CSS ID being restricted as well, but
of course the only restriction is what's enforced in memcg onlining. I
deleted it.

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 75e74408cc8f..1d8a6dffdc25 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> ...
> > +static void mem_cgroup_id_put(struct mem_cgroup *memcg)
> > +{
> > +	if (atomic_dec_and_test(&memcg->id.ref)) {
> > +		idr_remove(&mem_cgroup_idr, memcg->id.id);
> 
> Maybe this should do "memcg->id.id = 0"?

Added.

> > +		css_id_free(&memcg->css);
> > +		css_put(&memcg->css);
> > +	}
> > +}
> > +
> > +/**
> > + * mem_cgroup_from_id - look up a memcg from a memcg id
> > + * @id: the memcg id to look up
> > + *
> > + * Caller must hold rcu_read_lock().
> > + */
> > +struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
> > +{
> > +	WARN_ON_ONCE(!rcu_read_lock_held());
> > +	return id > 0 ? idr_find(&mem_cgroup_idr, id) : NULL;
> > +}
> 
> css_from_id() has it too but I don't think id > 0 test is necessary.
> We prolly should take it out of css_from_id() too.

Yeah, idr_find() just returns NULL for index 0 - no warning. I removed
it from my patch and added a patch to remove it in css_from_id().

> It might be useful to add comment explaining why memcg needs private
> ids.

Good point. I put an intro comment above the mem_cgroup_idr definition
that explains why we need a private space.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
