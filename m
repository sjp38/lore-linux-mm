Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 11E486B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 19:43:07 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id h32-v6so1855848pld.15
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 16:43:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w1si1839955pgq.76.2018.04.18.16.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 16:43:05 -0700 (PDT)
Date: Wed, 18 Apr 2018 16:43:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 12/14] mm: Improve struct page documentation
Message-ID: <20180418234304.GA16782@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-13-willy@infradead.org>
 <f8606c8e-8fa6-da3d-676e-8ae36bae1ce7@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8606c8e-8fa6-da3d-676e-8ae36bae1ce7@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 18, 2018 at 04:32:27PM -0700, Randy Dunlap wrote:
> > + * If you allocate the page using alloc_pages(), you can use some of the
> > + * space in struct page for your own purposes.  The five words in the first
> 
> Using "first union" here...
> 
> > + * If your page will not be mapped to userspace, you can also use the 4
> > + * bytes in the second union, but you must call page_mapcount_reset()
> 
> and "second union" here bother me, but it looks like they are anonymous.
> 
> I'm concerned about someone other than you modifying struct page at some
> later time.  If these unions were named (and you could use that name here
> instead of "first" or "second"), then there would be less chance for that
> next person to miss modifying that comment or it just becoming stale.

Yeah, it bothers me too.  I was first bothered by this when writing the
patch descriptions for the earlier patches in the series "Combine first
three unions in struct page" and "Combine first two unions in struct
page" really suck as patch descriptions.  But I couldn't come up with
anything better, so here we are ...

If we name the union, then either we have to put in some grotty macros
or change every instance of page->mapping to page->u1.mapping (repeat
ad nauseam).  I mean, I'd rather leave the unions anonymous and name
the structs (but again, I don't want to rename every user).

We can put a comment on the union and name them that way, but I
don't even know what to call them.  "main union" "auxiliary union".
"secondary union".  I don't know.

> Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.  I also did some kernel-doc'ifying of some other comments earlier
in the series.  I'm sure they could be improved.  And there's a whole
bunch of comments which aren't in kernel-doc format and might or might
not want to be.

(eg: do we want to comment _refcount?  Other than to tell people to not
use it?)
