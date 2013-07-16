Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id ACB7C6B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 01:10:19 -0400 (EDT)
Date: Tue, 16 Jul 2013 14:10:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/9] mm, hugetlb: move up the code which check
 availability of free huge page
Message-ID: <20130716051020.GA30116@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-2-git-send-email-iamjoonsoo.kim@lge.com>
 <87a9lnkjlu.fsf@linux.vnet.ibm.com>
 <20130716011607.GD2430@lge.com>
 <87a9lni3bv.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a9lni3bv.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 16, 2013 at 09:06:04AM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > On Mon, Jul 15, 2013 at 07:31:33PM +0530, Aneesh Kumar K.V wrote:
> >> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> >> 
> >> > We don't need to proceede the processing if we don't have any usable
> >> > free huge page. So move this code up.
> >> 
> >> I guess you can also mention that since we are holding hugetlb_lock
> >> hstate values can't change.
> >
> > Okay. I will mention this for v2.
> >
> >> 
> >> 
> >> Also.
> >> 
> >> >
> >> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> >
> >> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >> > index e2bfbf7..d87f70b 100644
> >> > --- a/mm/hugetlb.c
> >> > +++ b/mm/hugetlb.c
> >> > @@ -539,10 +539,6 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
> >> >  	struct zoneref *z;
> >> >  	unsigned int cpuset_mems_cookie;
> >> >
> >> > -retry_cpuset:
> >> > -	cpuset_mems_cookie = get_mems_allowed();
> >> > -	zonelist = huge_zonelist(vma, address,
> >> > -					htlb_alloc_mask, &mpol, &nodemask);
> >> >  	/*
> >> >  	 * A child process with MAP_PRIVATE mappings created by their parent
> >> >  	 * have no page reserves. This check ensures that reservations are
> >> > @@ -550,11 +546,16 @@ retry_cpuset:
> >> >  	 */
> >> >  	if (!vma_has_reserves(vma) &&
> >> >  			h->free_huge_pages - h->resv_huge_pages == 0)
> >> > -		goto err;
> >> > +		return NULL;
> >> >
> >> 
> >> If you don't do the above change, the patch will be much simpler. 
> >
> > The patch will be, but output code will not.
> > With this change, we can remove one goto label('err:') and
> > this makes code more readable.
> >
> 
> If you feel stronly about the cleanup, you can do another path for the
> cleanups. Don't mix things in a single patch. That makes review difficult.

Okay! I will make an another patch for clean-up.

Thanks.

> 
> -aneesh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
