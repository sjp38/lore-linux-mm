Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7BB2D6B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 06:50:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 10:41:50 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FAoZes59768888
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:50:35 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FAoYrh027534
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:50:35 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V9 14/15] hugetlb/cgroup: migrate hugetlb cgroup info from oldpage to new page during migration
In-Reply-To: <20120614100454.GL27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120614100454.GL27397@tiehlicka.suse.cz>
Date: Fri, 15 Jun 2012 16:20:31 +0530
Message-ID: <87haucn91k.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Wed 13-06-12 15:57:33, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> With HugeTLB pages, hugetlb cgroup is uncharged in compound page destructor.  Since
>> we are holding a hugepage reference, we can be sure that old page won't
>> get uncharged till the last put_page().
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
> One question below
> [...]
>> +void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
>> +{
>> +	struct hugetlb_cgroup *h_cg;
>> +
>> +	if (hugetlb_cgroup_disabled())
>> +		return;
>> +
>> +	VM_BUG_ON(!PageHuge(oldhpage));
>> +	spin_lock(&hugetlb_lock);
>> +	h_cg = hugetlb_cgroup_from_page(oldhpage);
>> +	set_hugetlb_cgroup(oldhpage, NULL);
>> +	cgroup_exclude_rmdir(&h_cg->css);
>> +
>> +	/* move the h_cg details to new cgroup */
>> +	set_hugetlb_cgroup(newhpage, h_cg);
>> +	spin_unlock(&hugetlb_lock);
>> +	cgroup_release_and_wakeup_rmdir(&h_cg->css);
>> +	return;
>> +}
>> +
>
> The changelog says that the old page won't get uncharged - which means
> that the the cgroup cannot go away (even if we raced with the move
> parent, hugetlb_lock makes sure we either see old or new cgroup) so why
> do we need to play with css ref. counting?

Ok hugetlb_lock should be sufficient here i guess. I will send a patch
on top to remove the exclude_rmdir and release_and_wakeup_rmdir 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
