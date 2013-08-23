Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 5FDE76B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 02:16:43 -0400 (EDT)
Date: Fri, 23 Aug 2013 15:16:53 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 12/20] mm, hugetlb: remove vma_has_reserves()
Message-ID: <20130823061653.GC22605@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-13-git-send-email-iamjoonsoo.kim@lge.com>
 <87siy215e1.fsf@linux.vnet.ibm.com>
 <20130822091747.GA22605@lge.com>
 <87mwoa0yx5.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mwoa0yx5.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Thu, Aug 22, 2013 at 04:34:22PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > On Thu, Aug 22, 2013 at 02:14:38PM +0530, Aneesh Kumar K.V wrote:
> >> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> >> 
> >> > vma_has_reserves() can be substituted by using return value of
> >> > vma_needs_reservation(). If chg returned by vma_needs_reservation()
> >> > is 0, it means that vma has reserves. Otherwise, it means that vma don't
> >> > have reserves and need a hugepage outside of reserve pool. This definition
> >> > is perfectly same as vma_has_reserves(), so remove vma_has_reserves().
> >> >
> >> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> 
> >> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >
> > Thanks.
> >
> >> > @@ -580,8 +547,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
> >> >  	 * have no page reserves. This check ensures that reservations are
> >> >  	 * not "stolen". The child may still get SIGKILLed
> >> >  	 */
> >> > -	if (!vma_has_reserves(vma, chg) &&
> >> > -			h->free_huge_pages - h->resv_huge_pages == 0)
> >> > +	if (chg && h->free_huge_pages - h->resv_huge_pages == 0)
> >> >  		return NULL;
> >> >
> >> >  	/* If reserves cannot be used, ensure enough pages are in the pool */
> >> > @@ -600,7 +566,7 @@ retry_cpuset:
> >> >  			if (page) {
> >> >  				if (avoid_reserve)
> >> >  					break;
> >> > -				if (!vma_has_reserves(vma, chg))
> >> > +				if (chg)
> >> >  					break;
> >> >
> >> >  				SetPagePrivate(page);
> >> 
> >> Can you add a comment above both the place to explain why checking chg
> >> is good enough ?
> >
> > Yes, I can. But it will be changed to use_reserve in patch 13 and it
> > represent it's meaning perfectly. So commeting may be useless.
> 
> That should be ok, because having a comment in this patch helps in
> understanding the patch better, even though you are removing that
> later. 

Okay. I will add it in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
