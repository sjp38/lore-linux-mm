Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id F03E06B005A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 03:57:27 -0400 (EDT)
Date: Tue, 27 Aug 2013 16:57:53 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 13/20] mm, hugetlb: mm, hugetlb: unify chg and
 avoid_reserve to use_reserve
Message-ID: <20130827075753.GB6795@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-14-git-send-email-iamjoonsoo.kim@lge.com>
 <87y57od2eo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y57od2eo.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Aug 26, 2013 at 06:39:35PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > Currently, we have two variable to represent whether we can use reserved
> > page or not, chg and avoid_reserve, respectively. With aggregating these,
> > we can have more clean code. This makes no functinoal difference.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 22ceb04..8dff972 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -531,8 +531,7 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
> >
> >  static struct page *dequeue_huge_page_vma(struct hstate *h,
> >  				struct vm_area_struct *vma,
> > -				unsigned long address, int avoid_reserve,
> > -				long chg)
> > +				unsigned long address, bool use_reserve)
> >  {
> >  	struct page *page = NULL;
> >  	struct mempolicy *mpol;
> > @@ -546,12 +545,10 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
> >  	 * A child process with MAP_PRIVATE mappings created by their parent
> >  	 * have no page reserves. This check ensures that reservations are
> >  	 * not "stolen". The child may still get SIGKILLed
> > +	 * Or, when parent process do COW, we cannot use reserved page.
> > +	 * In this case, ensure enough pages are in the pool.
> >  	 */
> > -	if (chg && h->free_huge_pages - h->resv_huge_pages == 0)
> > -		return NULL;
> 
> This hunk would be much easier if you were changing. 
> 
> 	if (!vma_has_reserves(vma) &&
> 			h->free_huge_pages - h->resv_huge_pages == 0)
> 		goto err;
> 
> ie, !vma_has_reserves(vma) == !use_reserve.
> 
> So may be a patch rearragment would help ?. But neverthless. 

I think that current form is better since use_reserve is not same as
vma_has_reserves(). I changed the call site of vma_has_reserves() to chg in
previous patch. In this patch, use_reserve in alloc_huge_page is made
by chg and avoid_reserve and is passed to dequeue_huge_page_vma(). So changing
in dequeue_huge_page_vma() is trivial.

> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
