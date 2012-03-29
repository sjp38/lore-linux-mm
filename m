Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 7D0C36B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 03:57:25 -0400 (EDT)
Date: Thu, 29 Mar 2012 09:57:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
Message-ID: <20120329075722.GB30465@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120328134020.GG20949@tiehlicka.suse.cz>
 <87y5qk1vat.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y5qk1vat.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 28-03-12 23:07:14, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Fri 16-03-12 23:09:24, Aneesh Kumar K.V wrote:
> > [...]
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 6728a7a..4b36c5e 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> > [...]
> >> @@ -4887,6 +5013,7 @@ err_cleanup:
> >>  static struct cgroup_subsys_state * __ref
> >>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >>  {
> >> +	int idx;
> >>  	struct mem_cgroup *memcg, *parent;
> >>  	long error = -ENOMEM;
> >>  	int node;
> >> @@ -4929,9 +5056,14 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >>  		 * mem_cgroup(see mem_cgroup_put).
> >>  		 */
> >>  		mem_cgroup_get(parent);
> >> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> >> +			res_counter_init(&memcg->hugepage[idx],
> >> +					 &parent->hugepage[idx]);
> >
> > Hmm, I do not think we want to make groups deeper in the hierarchy
> > unlimited as we cannot reclaim. Shouldn't we copy the limit from the parent?
> > Still not ideal but slightly more expected behavior IMO.
> 
> But we should be limiting the child group based on parent's limit only
> when hierarchy is set right ?

Yes. Everything else should be unlimited by default.

> 
> >
> > The hierarchy setups are still interesting and the limitations should be
> > described in the documentation...
> >
> 
> It should behave similar to memcg. ie, if hierarchy is set, then we limit
> using MIN(parent's limit, child's limit). May be I am missing some of
> the details of memcg use_hierarchy config. My goal was to keep it
> similar to memcg. Can you explain why do you think the patch would
> make it any different ?

Yes, the patch tries to be consistent with the memcg limits. That is OK
and I have no objections for that. It is just that consequences are
different. The hugetlb limit is really hard...

> 
> -aneesh
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

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
