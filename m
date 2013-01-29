Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 4F70A6B0082
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:26:32 -0500 (EST)
Date: Tue, 29 Jan 2013 15:26:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/6] memcg: introduce memsw_accounting_users
Message-ID: <20130129142630.GE29574@dhcp22.suse.cz>
References: <510658F0.9050802@oracle.com>
 <51079A79.9090802@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51079A79.9090802@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lord Glauber Costa of Sealand <glommer@parallels.com>
Cc: Jeff Liu <jeff.liu@oracle.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue 29-01-13 13:46:33, Glauber Costa wrote:
> Hi,
> 
> On 01/28/2013 02:54 PM, Jeff Liu wrote:
> > As we don't account the swap stat number for the root_mem_cgroup anymore,
> > here we can just return an invalid CSS ID if there is no non-root memcg
> > is alive.  Also, introduce memsw_accounting_users to track the number of
> > active non-root memcgs.
> > 
> > Signed-off-by: Jie Liu <jeff.liu@oracle.com>
> > CC: Glauber Costa <glommer@parallels.com>
> > CC: Michal Hocko <mhocko@suse.cz>
> > CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > CC: Johannes Weiner <hannes@cmpxchg.org>
> > CC: Mel Gorman <mgorman@suse.de>
> > CC: Andrew Morton <akpm@linux-foundation.org>
> > CC: Sha Zhengju <handai.szj@taobao.com>
> > 
> > ---
> >  mm/page_cgroup.c |   16 +++++++++++++++-
> >  1 file changed, 15 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> > index c945254..189fbf5 100644
> > --- a/mm/page_cgroup.c
> > +++ b/mm/page_cgroup.c
> > @@ -336,6 +336,8 @@ struct swap_cgroup {
> >  };
> >  #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
> >  
> > +static atomic_t memsw_accounting_users = ATOMIC_INIT(0);
> > +
> 
> I am not seeing this being incremented or decremented. I can only guess
> that it comes in later patches. However, they are clearly used as a
> global reference counter.
> 
> This is precisely one of the use cases static branches solve very
> neatly. Did you consider using them?
> 
> True, they will help a lot more when we are touching hot paths, and swap
> is hardly a hot path.
> 
> However, since one of the main complaints about memcg has been that we
> inflict "death by a thousand cuts", maybe it wouldn't hurt everything
> else being the same.
> 
> Michal and others, do you have any feelings here?
 
I would leave a static branch change to a separate patch. Make it work
first and only then care about how it looks.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
