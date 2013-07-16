Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 6F4496B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 21:55:59 -0400 (EDT)
Date: Tue, 16 Jul 2013 10:56:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 6/9] mm, hugetlb: do not use a page in page cache for cow
 optimization
Message-ID: <20130716015600.GH2430@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-7-git-send-email-iamjoonsoo.kim@lge.com>
 <87d2qkj5b7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d2qkj5b7.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 15, 2013 at 07:25:40PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > Currently, we use a page with mapped count 1 in page cache for cow
> > optimization. If we find this condition, we don't allocate a new
> > page and copy contents. Instead, we map this page directly.
> > This may introduce a problem that writting to private mapping overwrite
> > hugetlb file directly. You can find this situation with following code.
> >
> >         size = 20 * MB;
> >         flag = MAP_SHARED;
> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
> >         if (p == MAP_FAILED) {
> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
> >                 return -1;
> >         }
> >         p[0] = 's';
> >         fprintf(stdout, "BEFORE STEAL PRIVATE WRITE: %c\n", p[0]);
> >         munmap(p, size);
> >
> >         flag = MAP_PRIVATE;
> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
> >         if (p == MAP_FAILED) {
> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
> >         }
> >         p[0] = 'c';
> >         munmap(p, size);
> >
> >         flag = MAP_SHARED;
> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
> >         if (p == MAP_FAILED) {
> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
> >                 return -1;
> >         }
> >         fprintf(stdout, "AFTER STEAL PRIVATE WRITE: %c\n", p[0]);
> >         munmap(p, size);
> >
> > We can see that "AFTER STEAL PRIVATE WRITE: c", not "AFTER STEAL
> > PRIVATE WRITE: s". If we turn off this optimization to a page
> > in page cache, the problem is disappeared.
> 
> Do we need to trun of the optimization for page cache completely ?
> Can't we check for MAP_PRIVATE case ?

IMO, we need to turn off the optimization for page cache completely.
This optimization works just for MAP_PRIVATE case.
If we map with MAP_SHARED, we map a page from page cache directly,
so we don't need this cow optimization.

> 
> Also, we may want to add the above test into libhugetlbfs 

I will submit the above test into libhugetlbfs.

Thanks.

> 
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index d4a1695..6c1eb9b 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2512,7 +2512,6 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >  {
> >  	struct hstate *h = hstate_vma(vma);
> >  	struct page *old_page, *new_page;
> > -	int avoidcopy;
> >  	int outside_reserve = 0;
> >  	unsigned long mmun_start;	/* For mmu_notifiers */
> >  	unsigned long mmun_end;		/* For mmu_notifiers */
> > @@ -2522,10 +2521,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >  retry_avoidcopy:
> >  	/* If no-one else is actually using this page, avoid the copy
> >  	 * and just make the page writable */
> > -	avoidcopy = (page_mapcount(old_page) == 1);
> > -	if (avoidcopy) {
> > -		if (PageAnon(old_page))
> > -			page_move_anon_rmap(old_page, vma, address);
> > +	if (page_mapcount(old_page) == 1 && PageAnon(old_page)) {
> > +		page_move_anon_rmap(old_page, vma, address);
> >  		set_huge_ptep_writable(vma, address, ptep);
> >  		return 0;
> >  	}
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
