From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16783.59834.7179.464876@thebsh.namesys.com>
Date: Tue, 9 Nov 2004 00:48:42 +0300
Subject: Re: [PATCH] ignore referenced pages on reclaim when OOM 
In-Reply-To: <20041108181821.GA3236@logos.cnet>
References: <20041108181821.GA3236@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: akpm@osdl.org, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti writes:
 > Andrew,
 > 
 > Can you please apply Rik's patch? 
 > 
 > Ignore referenced bit when priority reaches 0. Get out of such
 > OOM situation as fast as possible, instead of running around 
 > trying to find elegible pages for reclaim. 
 > 
 > Speeds up extreme load performance on Rik's tests.

I recently tested quite similar thing, the only dfference being that in
my case references bit started being ignored when scanning priority
reached 2 rather than 0.

I found that it _degrades_ performance in the loads when there is a lot
of file system write-back going from tail of the inactive list (like
dirtying huge file through mmap in a loop).

Nikita.

 > 
 > ----- Forwarded message from Rik van Riel <riel@redhat.com> -----
 > 
 > From: Rik van Riel <riel@redhat.com>
 > Date: Fri, 5 Nov 2004 16:56:17 -0500 (EST)
 > To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
 > Subject: [PATCH] fix OOM problem
 > X-X-Sender: riel@chimarrao.boston.redhat.com
 > X-MIMETrack: Itemize by SMTP Server on USMail/Cyclades(Release 6.5.1|January 21, 2004) at
 >  11/05/2004 13:58:40
 > 
 > 
 > 
 > ===== mm/vmscan.c 1.231 vs edited =====
 > --- 1.231/mm/vmscan.c	Sun Oct 17 01:07:24 2004
 > +++ edited/mm/vmscan.c	Mon Oct 25 17:38:56 2004
 > @@ -379,7 +379,7 @@
 >  
 >  		referenced = page_referenced(page, 1);
 >  		/* In active use or really unfreeable?  Activate it. */
 > -		if (referenced && page_mapping_inuse(page))
 > +		if (referenced && sc->priority && page_mapping_inuse(page))
 >  			goto activate_locked;
 >  
 >  #ifdef CONFIG_SWAP
 > @@ -715,7 +715,7 @@
 >  		if (page_mapped(page)) {
 >  			if (!reclaim_mapped ||
 >  			    (total_swap_pages == 0 && PageAnon(page)) ||
 > -			    page_referenced(page, 0)) {
 > +			    (page_referenced(page, 0) && sc->priority)) {
 >  				list_add(&page->lru, &l_active);
 >  				continue;
 >  			}
 > 
 > 
 > 
 > --
 > To unsubscribe, send a message with 'unsubscribe linux-mm' in
 > the body to majordomo@kvack.org.  For more info on Linux MM,
 > see: http://www.linux-mm.org/ .
 > Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
