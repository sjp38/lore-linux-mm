Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id E025C6B0256
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 08:19:10 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so43823120wic.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 05:19:10 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id gj20si20824347wic.95.2015.09.07.05.19.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 05:19:09 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so82054541wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 05:19:09 -0700 (PDT)
Date: Mon, 7 Sep 2015 15:19:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 1/7] mm: drop page->slab_page
Message-ID: <20150907121907.GA5531@node.dhcp.inet.fi>
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441283758-92774-2-git-send-email-kirill.shutemov@linux.intel.com>
 <55ED1A09.3040409@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55ED1A09.3040409@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>

On Sun, Sep 06, 2015 at 10:00:57PM -0700, Alexander Duyck wrote:
> On 09/03/2015 05:35 AM, Kirill A. Shutemov wrote:
> >Since 8456a648cf44 ("slab: use struct page for slab management") nobody
> >uses slab_page field in struct page.
> >
> >Let's drop it.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Acked-by: Christoph Lameter <cl@linux.com>
> >Acked-by: David Rientjes <rientjes@google.com>
> >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >Cc: Andi Kleen <ak@linux.intel.com>
> >---
> >  include/linux/mm_types.h |  1 -
> >  mm/slab.c                | 17 +++--------------
> >  2 files changed, 3 insertions(+), 15 deletions(-)
> >
> >diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> >index 0038ac7466fd..58620ac7f15c 100644
> >--- a/include/linux/mm_types.h
> >+++ b/include/linux/mm_types.h
> >@@ -140,7 +140,6 @@ struct page {
> >  #endif
> >  		};
> >-		struct slab *slab_page; /* slab fields */
> >  		struct rcu_head rcu_head;	/* Used by SLAB
> >  						 * when destroying via RCU
> >  						 */
> >diff --git a/mm/slab.c b/mm/slab.c
> >index 200e22412a16..649044f26e5d 100644
> >--- a/mm/slab.c
> >+++ b/mm/slab.c
> >@@ -1888,21 +1888,10 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
> >  	freelist = page->freelist;
> >  	slab_destroy_debugcheck(cachep, page);
> >-	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
> >-		struct rcu_head *head;
> >-
> >-		/*
> >-		 * RCU free overloads the RCU head over the LRU.
> >-		 * slab_page has been overloeaded over the LRU,
> >-		 * however it is not used from now on so that
> >-		 * we can use it safely.
> >-		 */
> >-		head = (void *)&page->rcu_head;
> >-		call_rcu(head, kmem_rcu_free);
> >-
> >-	} else {
> >+	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
> >+		call_rcu(&page->rcu_head, kmem_rcu_free);
> >+	else
> >  		kmem_freepages(cachep, page);
> >-	}
> >  	/*
> >  	 * From now on, we don't use freelist
> 
> This second piece looks like it belongs in patch 2, not patch 1 based on the
> descriptions.

You're right.

Although I don't think I would re-spin the patchset just for this change.
If any other change would be required, I'll fix this too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
