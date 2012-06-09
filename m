Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 5DC0E6B0062
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 09:09:36 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 13:06:29 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q59D9UDK52232194
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 23:09:30 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59D9Tik024235
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 23:09:30 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 14/16] hugetlb/cgroup: add charge/uncharge calls for HugeTLB alloc/free
In-Reply-To: <20120609092301.GF1761@cmpxchg.org>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120609092301.GF1761@cmpxchg.org>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Sat, 09 Jun 2012 18:39:06 +0530
Message-ID: <87pq98ljil.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Sat, Jun 09, 2012 at 02:29:59PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This adds necessary charge/uncharge calls in the HugeTLB code.  We do
>> hugetlb cgroup charge in page alloc and uncharge in compound page destructor.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  mm/hugetlb.c        |   16 +++++++++++++++-
>>  mm/hugetlb_cgroup.c |    7 +------
>>  2 files changed, 16 insertions(+), 7 deletions(-)
>> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index bf79131..4ca92a9 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -628,6 +628,8 @@ static void free_huge_page(struct page *page)
>>  	BUG_ON(page_mapcount(page));
>>  
>>  	spin_lock(&hugetlb_lock);
>> +	hugetlb_cgroup_uncharge_page(hstate_index(h),
>> +				     pages_per_huge_page(h), page);
>
> hugetlb_cgroup_uncharge_page() takes the hugetlb_lock, no?

Yes, But this patch also modifies it to not take the lock, because we
hold spin_lock just below in the call site. I didn't want to drop the
lock and take it again.

>
> It's quite hard to review code that is split up like this.  Please
> always keep the introduction of new functions in the same patch that
> adds the callsite(s).

One of the reason I split the charge/uncharge routines and the callers
in separate patches is to make it easier for review. Irrespective of
the call site charge/uncharge routines should be correct with respect
to locking and other details. What I did in this patch is a small
optimization of avoiding dropping and taking the lock again. May be the
right approach would have been to name it __hugetlb_cgroup_uncharge_page
and make sure the hugetlb_cgroup_uncharge_page still takes spin_lock.
But then we don't have any callers for that.

-aneesh



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
