Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 9F5B36B0095
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 05:23:10 -0400 (EDT)
Date: Sat, 9 Jun 2012 11:23:01 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -V8 14/16] hugetlb/cgroup: add charge/uncharge calls for
 HugeTLB alloc/free
Message-ID: <20120609092301.GF1761@cmpxchg.org>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat, Jun 09, 2012 at 02:29:59PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This adds necessary charge/uncharge calls in the HugeTLB code.  We do
> hugetlb cgroup charge in page alloc and uncharge in compound page destructor.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c        |   16 +++++++++++++++-
>  mm/hugetlb_cgroup.c |    7 +------
>  2 files changed, 16 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bf79131..4ca92a9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -628,6 +628,8 @@ static void free_huge_page(struct page *page)
>  	BUG_ON(page_mapcount(page));
>  
>  	spin_lock(&hugetlb_lock);
> +	hugetlb_cgroup_uncharge_page(hstate_index(h),
> +				     pages_per_huge_page(h), page);

hugetlb_cgroup_uncharge_page() takes the hugetlb_lock, no?

It's quite hard to review code that is split up like this.  Please
always keep the introduction of new functions in the same patch that
adds the callsite(s).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
