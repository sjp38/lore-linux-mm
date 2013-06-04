Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 90B126B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 16:50:29 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r11so772896pdi.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 13:50:28 -0700 (PDT)
Date: Tue, 4 Jun 2013 13:50:25 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130604205025.GG14916@htj.dyndns.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604131843.GF31242@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello, Michal.

On Tue, Jun 04, 2013 at 03:18:43PM +0200, Michal Hocko wrote:
> > +	if (memcg)
> > +		css_get(&memcg->css);
> 
> This is all good and nice but it re-introduces the same problem which
> has been fixed by (5f578161: memcg: relax memcg iter caching). You are
> pinning memcg in memory for unbounded amount of time because css
> reference will not let object to leave and rest.

I don't get why that is a problem.  Can you please elaborate?  css's
now explicitly allow holding onto them.  We now have clear separation
of "destruction" and "release" and blkcg also depends on it.  If memcg
still doesn't distinguish the two properly, that's where the problem
should be fixed.

> I understand your frustration about the complexity of the current
> synchronization but we didn't come up with anything easier.
> Originally I though that your tree walk updates which allow dropping rcu
> would help here but then I realized that not really because the iterator
> (resp. pos) has to be a valid pointer and there is only one possibility
> to do that AFAICS here and that is css pinning. And is no-go.

I find the above really weird.  If css can't be pinned for position
caching, isn't it natural to ask why it can't be and then fix it?
Because that's what the whole refcnt thing is about and a usage which
cgroup explicitly allows (e.g. blkcg also does it).  Why do you go
from there to "this batshit crazy barrier dancing is the only
solution"?

Can you please explain why memcg css's can't be pinned?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
