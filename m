Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0949F6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 19:09:08 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so20195486pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:09:07 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id os6si23964374pab.195.2015.07.24.16.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 16:09:07 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so20013425pdr.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:09:06 -0700 (PDT)
Date: Fri, 24 Jul 2015 16:09:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass
 __GFP_THISNODE
In-Reply-To: <55B2A596.1010101@suse.cz>
Message-ID: <alpine.DEB.2.10.1507241606270.12744@chino.kir.corp.google.com>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507241301400.5215@chino.kir.corp.google.com> <55B2A596.1010101@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 24 Jul 2015, Vlastimil Babka wrote:

> > I assume you looked at the collapse_huge_page() case and decided that it 
> > needs no modification since the gfp mask is used later for other calls?
> 
> Yeah. Not that the memcg charge parts would seem to care about __GFP_THISNODE,
> though.
> 

Hmm, not sure that memcg would ever care about __GFP_THISNODE.  I wonder 
if it make more sense to remove setting __GFP_THISNODE in 
collapse_huge_page()?  khugepaged_alloc_page() seems fine with the new 
alloc_pages_exact_node() semantics.

> >> diff --git a/mm/migrate.c b/mm/migrate.c
> >> index f53838f..d139222 100644
> >> --- a/mm/migrate.c
> >> +++ b/mm/migrate.c
> >> @@ -1554,10 +1554,8 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
> >>  	struct page *newpage;
> >>  
> >>  	newpage = alloc_pages_exact_node(nid,
> >> -					 (GFP_HIGHUSER_MOVABLE |
> >> -					  __GFP_THISNODE | __GFP_NOMEMALLOC |
> >> -					  __GFP_NORETRY | __GFP_NOWARN) &
> >> -					 ~GFP_IOFS, 0);
> >> +				(GFP_HIGHUSER_MOVABLE | __GFP_NOMEMALLOC |
> >> +				 __GFP_NORETRY | __GFP_NOWARN) & ~GFP_IOFS, 0);
> >>  
> >>  	return newpage;
> >>  }
> > [snip]
> > 
> > What about the alloc_pages_exact_node() in new_page_node()?
> 
> Oops, seems I missed that one. So the API seems ok otherwise?
> 

Yup!  And I believe that this patch doesn't cause any regression after the 
new_page_node() issue is fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
