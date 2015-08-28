Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 06B6C6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:56:08 -0400 (EDT)
Received: by ykek5 with SMTP id k5so7523980yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 09:56:07 -0700 (PDT)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id q63si4411348ywc.180.2015.08.28.09.56.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 09:56:07 -0700 (PDT)
Received: by ykek5 with SMTP id k5so7523567yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 09:56:06 -0700 (PDT)
Date: Fri, 28 Aug 2015 12:56:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150828165604.GM26785@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828164918.GJ9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello,

On Fri, Aug 28, 2015 at 07:49:18PM +0300, Vladimir Davydov wrote:
> On Fri, Aug 28, 2015 at 11:25:30AM -0400, Tejun Heo wrote:
> > On the default hierarchy, all memory consumption will be accounted
> > together and controlled by the same set of limits.  Always enable
> > kmemcg on the default hierarchy.
> 
> IMO we should introduce a boot time knob for disabling it, because kmem
> accounting is still not perfect, besides some users might prefer to go
> w/o it for performance reasons.

Yeah, fair enough.

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c94b686..8a5dd01 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4362,6 +4362,13 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
> >  	if (ret)
> >  		return ret;
> >  
> > +	/* kmem is always accounted together on the default hierarchy */
> > +	if (cgroup_on_dfl(css->cgroup)) {
> > +		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
> > +		if (ret)
> > +			return ret;
> > +	}
> > +
> 
> This is a wrong place for this. The kernel will panic on an attempt to
> create a sub memcg, because memcg_init_kmem already enables kmem
> accounting in this case. I guess we should add this hunk to
> memcg_propagate_kmem instead.

Yeap, bypassing "parent is active" test in memcg_propagate_kmem()
seems like the right thing to do.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
