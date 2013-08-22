Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 0B9026B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 03:24:44 -0400 (EDT)
Date: Thu, 22 Aug 2013 16:24:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 10/20] mm, hugetlb: remove resv_map_put()
Message-ID: <20130822072451.GF13415@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-11-git-send-email-iamjoonsoo.kim@lge.com>
 <8761uzgvyn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8761uzgvyn.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Wed, Aug 21, 2013 at 04:19:20PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > In following patch, I change vma_resv_map() to return resv_map
> > for all case. This patch prepares it by removing resv_map_put() which
> > doesn't works properly with following change, because it works only for
> > HPAGE_RESV_OWNER's resv_map, not for all resv_maps.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 73034dd..869c3e0 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2212,15 +2212,6 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
> >  		kref_get(&resv->refs);
> >  }
> >
> > -static void resv_map_put(struct vm_area_struct *vma)
> > -{
> > -	struct resv_map *resv = vma_resv_map(vma);
> > -
> > -	if (!resv)
> > -		return;
> > -	kref_put(&resv->refs, resv_map_release);
> > -}
> 
> Why not have seperate functions to return vma_resv_map for
> HPAGE_RESV_OWNER and one for put ? That way we could have something like
> 
> resv_map_hpage_resv_owner_get()
> resv_map_hpge_resv_put() 

Because there is no place to call this function more than once.
IMO, in this simple case, open code is better to understand and better to
reduce code size.

> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
