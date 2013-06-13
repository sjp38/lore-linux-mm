Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5E0E190001B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 11:54:55 -0400 (EDT)
Date: Thu, 13 Jun 2013 17:54:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 5/9] memcg: use css_get/put when charging/uncharging
 kmem
Message-ID: <20130613155453.GK23070@dhcp22.suse.cz>
References: <51B98D17.2050902@huawei.com>
 <20130613155319.GJ23070@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130613155319.GJ23070@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>

[Fix Glauber's new address]

On Thu 13-06-13 17:53:19, Michal Hocko wrote:
> On Thu 13-06-13 17:12:55, Li Zefan wrote:
> > Sorry for updating the patchset so late.
> > 
> > I've made some changes for the memory barrier thing, and I agree with
> > Michal that there can be improvement but can be a separate patch.
> > 
> > If this version is ok for everyone, I'll send the whole patchset out
> > to Andrew.
> > 
> > =========================
> > 
> > Use css_get/put instead of mem_cgroup_get/put.
> > 
> > We can't do a simple replacement, because here mem_cgroup_put()
> > is called during mem_cgroup_css_free(), while mem_cgroup_css_free()
> > won't be called until css refcnt goes down to 0.
> > 
> > Instead we increment css refcnt in mem_cgroup_css_offline(), and
> > then check if there's still kmem charges. If not, css refcnt will
> > be decremented immediately, 
> 
> > otherwise the refcnt won't be decremented when kmem charges goes down
> > to 0.
> 
> This is a bit confusing. What about "otherwise the css refcount will be
> released after the last kmem allocation is uncharged."
> 
> > 
> > v3:
> > - changed wmb() to smp_smb(), and moved it to memcg_kmem_mark_dead(),
> >   and added comment.
> > 
> > v2:
> > - added wmb() in kmem_cgroup_css_offline(), pointed out by Michal
> > - revised comments as suggested by Michal
> > - fixed to check if kmem is activated in kmem_cgroup_css_offline()
> > 
> > Signed-off-by: Li Zefan <lizefan@huawei.com>
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c | 70 ++++++++++++++++++++++++++++++++++++---------------------
> >  1 file changed, 45 insertions(+), 25 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 466c595..76dcd0e 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -416,6 +416,11 @@ static void memcg_kmem_clear_activated(struct mem_cgroup *memcg)
> >  
> >  static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
> >  {
> > +	/*
> > +	 * We need to call css_get() first, because memcg_uncharge_kmem()
> > +	 * will call css_put() if it sees the memcg is dead.
> > +	 */
> > +	smb_wmb();
> >  	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
> >  		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_account_flags);
> 
> I do not feel strongly about that but maybe open coding this in
> mem_cgroup_css_offline would be even better. There is only single caller
> and there is smaller chance somebody will use the function incorrectly
> later on.
> 
> So I leave the decision on you because this doesn't matter much.
> 
> [...]
> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
