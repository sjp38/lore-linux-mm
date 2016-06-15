Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9813E6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 22:32:46 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e5so23278107ith.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 19:32:46 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p131si4716214itc.25.2016.06.14.19.32.45
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 19:32:46 -0700 (PDT)
Date: Wed, 15 Jun 2016 11:32:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160615023249.GG17127@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox>
 <20160531000117.GB18314@bbox>
 <575E7F0B.8010201@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <575E7F0B.8010201@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

Hi,

On Mon, Jun 13, 2016 at 03:08:19PM +0530, Anshuman Khandual wrote:
> On 05/31/2016 05:31 AM, Minchan Kim wrote:
> > @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  	int rc = -EAGAIN;
> >  	int page_was_mapped = 0;
> >  	struct anon_vma *anon_vma = NULL;
> > +	bool is_lru = !__PageMovable(page);
> >  
> >  	if (!trylock_page(page)) {
> >  		if (!force || mode == MIGRATE_ASYNC)
> > @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  		goto out_unlock_both;
> >  	}
> >  
> > +	if (unlikely(!is_lru)) {
> > +		rc = move_to_new_page(newpage, page, mode);
> > +		goto out_unlock_both;
> > +	}
> > +
> 
> Hello Minchan,
> 
> I might be missing something here but does this implementation support the
> scenario where these non LRU pages owned by the driver mapped as PTE into
> process page table ? Because the "goto out_unlock_both" statement above
> skips all the PTE unmap, putting a migration PTE and removing the migration
> PTE steps.

You're right. Unfortunately, it doesn't support right now but surely,
it's my TODO after landing this work.

Could you share your usecase?

It would be helpful for merging when I wll send patchset.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
