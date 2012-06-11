Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 2503B6B00FF
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:40:30 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jun 2012 15:10:26 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5B9eOBw52494486
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 15:10:24 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5BFB0Z3025168
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 01:11:01 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 12/16] hugetlb/cgroup: Add support for cgroup removal
In-Reply-To: <20120611085258.GD12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120611085258.GD12402@tiehlicka.suse.cz>
Date: Mon, 11 Jun 2012 15:10:20 +0530
Message-ID: <87fwa25gqj.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Sat 09-06-12 14:29:57, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This patch add support for cgroup removal. If we don't have parent
>> cgroup, the charges are moved to root cgroup.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  mm/hugetlb_cgroup.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++++--
>>  1 file changed, 79 insertions(+), 2 deletions(-)
>> 
>> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
>> index 48efd5a..9458fe3 100644
>> --- a/mm/hugetlb_cgroup.c
>> +++ b/mm/hugetlb_cgroup.c
>> @@ -99,10 +99,87 @@ static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
>>  	kfree(h_cgroup);
>>  }
>>  
>> +
>> +static int hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
>> +				      struct page *page)
>
> deserves a comment about the locking (needs to be called with
> hugetlb_lock).

will do

>
>> +{
>> +	int csize;
>> +	struct res_counter *counter;
>> +	struct res_counter *fail_res;
>> +	struct hugetlb_cgroup *page_hcg;
>> +	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
>> +	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
>> +
>> +	if (!get_page_unless_zero(page))
>> +		goto out;
>> +
>> +	page_hcg = hugetlb_cgroup_from_page(page);
>> +	/*
>> +	 * We can have pages in active list without any cgroup
>> +	 * ie, hugepage with less than 3 pages. We can safely
>> +	 * ignore those pages.
>> +	 */
>> +	if (!page_hcg || page_hcg != h_cg)
>> +		goto err_out;
>
> How can we have page_hcg != NULL && page_hcg != h_cg?

pages belonging to other cgroup ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
