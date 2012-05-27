Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D44E16B0082
	for <linux-mm@kvack.org>; Sun, 27 May 2012 16:14:05 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 27 May 2012 20:03:51 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4RK6lAZ1311192
	for <linux-mm@kvack.org>; Mon, 28 May 2012 06:06:47 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4RKDsx8016226
	for <linux-mm@kvack.org>; Mon, 28 May 2012 06:13:55 +1000
Date: Mon, 28 May 2012 01:43:41 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V6 06/14] hugetlb: Simplify migrate_huge_page
Message-ID: <20120527201341.GB7631@skywalker.linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1334573091-18602-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1205241432290.24113@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205241432290.24113@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu, May 24, 2012 at 02:35:05PM -0700, David Rientjes wrote:
> On Mon, 16 Apr 2012, Aneesh Kumar K.V wrote:
> 
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index 97cc273..1f092db 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -1414,7 +1414,6 @@ static int soft_offline_huge_page(struct page *page, int flags)
> >  	int ret;
> >  	unsigned long pfn = page_to_pfn(page);
> >  	struct page *hpage = compound_head(page);
> > -	LIST_HEAD(pagelist);
> >  
> >  	ret = get_any_page(page, pfn, flags);
> >  	if (ret < 0)
> > @@ -1429,19 +1428,11 @@ static int soft_offline_huge_page(struct page *page, int flags)
> >  	}
> >  
> >  	/* Keep page count to indicate a given hugepage is isolated. */
> > -
> > -	list_add(&hpage->lru, &pagelist);
> > -	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0,
> > -				true);
> > +	ret = migrate_huge_page(page, new_page, MPOL_MF_MOVE_ALL, 0, true);
> 
> Was this tested?  Shouldn't this be migrate_huge_page(compound_head(page), 
> ...)?
> 

I tested this using madvise, but by not using tail pages. How about the below diff ?

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 4a45098..53a1495 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1428,8 +1428,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	}
 
 	/* Keep page count to indicate a given hugepage is isolated. */
-	ret = migrate_huge_page(page, new_page, MPOL_MF_MOVE_ALL, 0, true);
-	put_page(page);
+	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, 0, true);
+	put_page(hpage);
 	if (ret) {
 		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 			pfn, ret, page->flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
