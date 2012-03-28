Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D0BA16B0115
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 13:37:38 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 28 Mar 2012 17:28:56 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2SHVIgZ3375176
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 04:31:18 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2SHbOe3028785
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 04:37:24 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
In-Reply-To: <20120328134020.GG20949@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120328134020.GG20949@tiehlicka.suse.cz>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Wed, 28 Mar 2012 23:07:14 +0530
Message-ID: <87y5qk1vat.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Fri 16-03-12 23:09:24, Aneesh Kumar K.V wrote:
> [...]
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 6728a7a..4b36c5e 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
> [...]
>> @@ -4887,6 +5013,7 @@ err_cleanup:
>>  static struct cgroup_subsys_state * __ref
>>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>>  {
>> +	int idx;
>>  	struct mem_cgroup *memcg, *parent;
>>  	long error = -ENOMEM;
>>  	int node;
>> @@ -4929,9 +5056,14 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>>  		 * mem_cgroup(see mem_cgroup_put).
>>  		 */
>>  		mem_cgroup_get(parent);
>> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
>> +			res_counter_init(&memcg->hugepage[idx],
>> +					 &parent->hugepage[idx]);
>
> Hmm, I do not think we want to make groups deeper in the hierarchy
> unlimited as we cannot reclaim. Shouldn't we copy the limit from the parent?
> Still not ideal but slightly more expected behavior IMO.

But we should be limiting the child group based on parent's limit only
when hierarchy is set right ?

>
> The hierarchy setups are still interesting and the limitations should be
> described in the documentation...
>

It should behave similar to memcg. ie, if hierarchy is set, then we limit
using MIN(parent's limit, child's limit). May be I am missing some of
the details of memcg use_hierarchy config. My goal was to keep it
similar to memcg. Can you explain why do you think the patch would
make it any different ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
