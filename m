Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id ECF9C6B0062
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 11:55:48 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 21:25:45 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q59FtgB511141564
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 21:25:43 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59LOw6Q029756
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 07:24:58 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 14/16] hugetlb/cgroup: add charge/uncharge calls for HugeTLB alloc/free
In-Reply-To: <20120609143054.GH1761@cmpxchg.org>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120609092301.GF1761@cmpxchg.org> <87pq98ljil.fsf@skywalker.in.ibm.com> <20120609143054.GH1761@cmpxchg.org>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Sat, 09 Jun 2012 21:25:37 +0530
Message-ID: <87wr3gfpja.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Sat, Jun 09, 2012 at 06:39:06PM +0530, Aneesh Kumar K.V wrote:
>> Johannes Weiner <hannes@cmpxchg.org> writes:
>> 
>> > On Sat, Jun 09, 2012 at 02:29:59PM +0530, Aneesh Kumar K.V wrote:
>> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> >> 
>> >> This adds necessary charge/uncharge calls in the HugeTLB code.  We do
>> >> hugetlb cgroup charge in page alloc and uncharge in compound page destructor.
>> >> 
>> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> >> ---
>> >>  mm/hugetlb.c        |   16 +++++++++++++++-
>> >>  mm/hugetlb_cgroup.c |    7 +------
>> >>  2 files changed, 16 insertions(+), 7 deletions(-)
>> >> 
>> >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> >> index bf79131..4ca92a9 100644
>> >> --- a/mm/hugetlb.c
>> >> +++ b/mm/hugetlb.c
>> >> @@ -628,6 +628,8 @@ static void free_huge_page(struct page *page)
>> >>  	BUG_ON(page_mapcount(page));
>> >>  
>> >>  	spin_lock(&hugetlb_lock);
>> >> +	hugetlb_cgroup_uncharge_page(hstate_index(h),
>> >> +				     pages_per_huge_page(h), page);
>> >
>> > hugetlb_cgroup_uncharge_page() takes the hugetlb_lock, no?
>> 
>> Yes, But this patch also modifies it to not take the lock, because we
>> hold spin_lock just below in the call site. I didn't want to drop the
>> lock and take it again.
>
> Sorry, I missed that.
>
>> > It's quite hard to review code that is split up like this.  Please
>> > always keep the introduction of new functions in the same patch that
>> > adds the callsite(s).
>> 
>> One of the reason I split the charge/uncharge routines and the callers
>> in separate patches is to make it easier for review. Irrespective of
>> the call site charge/uncharge routines should be correct with respect
>> to locking and other details. What I did in this patch is a small
>> optimization of avoiding dropping and taking the lock again. May be the
>> right approach would have been to name it __hugetlb_cgroup_uncharge_page
>> and make sure the hugetlb_cgroup_uncharge_page still takes spin_lock.
>> But then we don't have any callers for that.
>
> I think this makes it needlessly complicated and there is no correct
> or incorrect locking in (initially) dead code :-)
>
> The callsites are just a few lines.  It's harder to review if you
> introduce an API and then change it again mid-patchset.
>

I will fold the patches.

> If there are no callers for a function that grabs the lock itself,
> don't add it.  Just add a note to the kerneldoc that explains the
> requirement or put VM_BUG_ON(!spin_is_locked(&hugetlb_lock)); in
> there or so.

That is excellent. I will add kerneldoc and VM_BUG_ON. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
