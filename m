Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 753266B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 05:03:20 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id x48so2416149wes.17
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 02:03:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd10si10491092wjc.14.2014.07.24.02.03.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 02:03:10 -0700 (PDT)
Date: Thu, 24 Jul 2014 11:02:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140724090257.GB14578@dhcp22.suse.cz>
References: <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
 <20140719173911.GA1725@cmpxchg.org>
 <20140722150825.GA4517@dhcp22.suse.cz>
 <CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
 <20140723143847.GB16721@dhcp22.suse.cz>
 <20140723150608.GF1725@cmpxchg.org>
 <CAJfpegs-k5QC+42SzLKUSaHrdPxWBaT_dF+SOPqoDvg8h5p_Tw@mail.gmail.com>
 <20140723210241.GH1725@cmpxchg.org>
 <20140724084644.GA14578@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140724084644.GA14578@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu 24-07-14 10:46:44, Michal Hocko wrote:
> On Wed 23-07-14 17:02:41, Johannes Weiner wrote:
[...]
> We can reduce the lookup only to lruvec==true case, no?

Dohh
s@can@should@

newpage shouldn't charged in all other cases and it would be bug.
Or am I missing something?

> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> > ---
> >  mm/memcontrol.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index b7c9a202dee9..3eaa6e83c168 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -6660,6 +6660,12 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> >  	if (mem_cgroup_disabled())
> >  		return;
> >  
> > +	/* Page cache replacement: new page already charged? */
> > +	pc = lookup_page_cgroup(newpage);
> > +	if (PageCgroupUsed(pc))
> > +		return;
> > +
> > +	/* Re-entrant migration: old page already uncharged? */
> >  	pc = lookup_page_cgroup(oldpage);
> >  	if (!PageCgroupUsed(pc))
> >  		return;
> > -- 
> > 2.0.0
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
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
