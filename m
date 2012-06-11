Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B975F6B00F2
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:19:02 -0400 (EDT)
Date: Mon, 11 Jun 2012 11:19:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V8 14/16] hugetlb/cgroup: add charge/uncharge calls for
 HugeTLB alloc/free
Message-ID: <20120611091900.GH12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120609092301.GF1761@cmpxchg.org>
 <87pq98ljil.fsf@skywalker.in.ibm.com>
 <20120609143054.GH1761@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120609143054.GH1761@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat 09-06-12 16:30:54, Johannes Weiner wrote:
> On Sat, Jun 09, 2012 at 06:39:06PM +0530, Aneesh Kumar K.V wrote:
> > Johannes Weiner <hannes@cmpxchg.org> writes:
> > 
> > > On Sat, Jun 09, 2012 at 02:29:59PM +0530, Aneesh Kumar K.V wrote:
> > >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > >> 
> > >> This adds necessary charge/uncharge calls in the HugeTLB code.  We do
> > >> hugetlb cgroup charge in page alloc and uncharge in compound page destructor.
> > >> 
> > >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > >> ---
> > >>  mm/hugetlb.c        |   16 +++++++++++++++-
> > >>  mm/hugetlb_cgroup.c |    7 +------
> > >>  2 files changed, 16 insertions(+), 7 deletions(-)
> > >> 
> > >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > >> index bf79131..4ca92a9 100644
> > >> --- a/mm/hugetlb.c
> > >> +++ b/mm/hugetlb.c
> > >> @@ -628,6 +628,8 @@ static void free_huge_page(struct page *page)
> > >>  	BUG_ON(page_mapcount(page));
> > >>  
> > >>  	spin_lock(&hugetlb_lock);
> > >> +	hugetlb_cgroup_uncharge_page(hstate_index(h),
> > >> +				     pages_per_huge_page(h), page);
> > >
> > > hugetlb_cgroup_uncharge_page() takes the hugetlb_lock, no?
> > 
> > Yes, But this patch also modifies it to not take the lock, because we
> > hold spin_lock just below in the call site. I didn't want to drop the
> > lock and take it again.
> 
> Sorry, I missed that.
> 
> > > It's quite hard to review code that is split up like this.  Please
> > > always keep the introduction of new functions in the same patch that
> > > adds the callsite(s).
> > 
> > One of the reason I split the charge/uncharge routines and the callers
> > in separate patches is to make it easier for review. Irrespective of
> > the call site charge/uncharge routines should be correct with respect
> > to locking and other details. What I did in this patch is a small
> > optimization of avoiding dropping and taking the lock again. May be the
> > right approach would have been to name it __hugetlb_cgroup_uncharge_page
> > and make sure the hugetlb_cgroup_uncharge_page still takes spin_lock.
> > But then we don't have any callers for that.
> 
> I think this makes it needlessly complicated and there is no correct
> or incorrect locking in (initially) dead code :-)
> 
> The callsites are just a few lines.  It's harder to review if you
> introduce an API and then change it again mid-patchset.

Fully agreed.

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
