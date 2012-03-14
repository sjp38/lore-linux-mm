Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 219086B004D
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 06:42:44 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 10:35:46 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2EAaH7m3108982
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 21:36:17 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2EAg3k1018832
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 21:42:04 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 3/8] hugetlb: add charge/uncharge calls for HugeTLB alloc/free
In-Reply-To: <4F5F4C48.8050001@parallels.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F5F4C48.8050001@parallels.com>
Date: Wed, 14 Mar 2012 16:11:58 +0530
Message-ID: <87ty1r8nwp.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 17:31:52 +0400, Glauber Costa <glommer@parallels.com> wrote:
> On 03/13/2012 11:07 AM, Aneesh Kumar K.V wrote:
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 8cac77b..f4aa11c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2901,6 +2901,11 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >
> >   	if (PageSwapCache(page))
> >   		return NULL;
> > +	/*
> > +	 * HugeTLB page uncharge happen in the HugeTLB compound page destructor
> > +	 */
> > +	if (PageHuge(page))
> > +		return NULL;
> 
> Maybe it is better to call uncharge_common from the compound destructor,
> so we can have all the uncharge code in a single place.
> 

PageHuge is not represented by a page flags as SwapCache. Hence I was
not able to call uncharge_common from compound destructor. For
SwapCache, we clear the flag and call uncharge_common again. Also I will
have to update those functions to take the resource counter index as
argument so that we end up updated the right resource counter in the
counter array. That would result in more code changes and I was not sure
about that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
