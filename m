Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8816B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 09:47:17 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b15so1122459eek.26
        for <linux-mm@kvack.org>; Thu, 01 May 2014 06:47:16 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id n7si34206263eeu.169.2014.05.01.06.47.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 01 May 2014 06:47:16 -0700 (PDT)
Date: Thu, 1 May 2014 09:47:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 14/17] mm: Do not use atomic operations when releasing
 pages
Message-ID: <20140501134713.GF23420@cmpxchg.org>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-15-git-send-email-mgorman@suse.de>
 <20140501132922.GD23420@cmpxchg.org>
 <20140501133938.GK23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140501133938.GK23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 02:39:38PM +0100, Mel Gorman wrote:
> On Thu, May 01, 2014 at 09:29:22AM -0400, Johannes Weiner wrote:
> > On Thu, May 01, 2014 at 09:44:45AM +0100, Mel Gorman wrote:
> > > There should be no references to it any more and a parallel mark should
> > > not be reordered against us. Use non-locked varient to clear page active.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > ---
> > >  mm/swap.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/swap.c b/mm/swap.c
> > > index f2228b7..7a5bdd7 100644
> > > --- a/mm/swap.c
> > > +++ b/mm/swap.c
> > > @@ -854,7 +854,7 @@ void release_pages(struct page **pages, int nr, bool cold)
> > >  		}
> > >  
> > >  		/* Clear Active bit in case of parallel mark_page_accessed */
> > > -		ClearPageActive(page);
> > > +		__ClearPageActive(page);
> > 
> > Shouldn't this comment be removed also?
> 
> Why? We're still clearing the active bit.

Ah, I was just confused by the "parallel mark_page_accessed" part.  It
means parallel to release_pages(), but before the put_page_testzero(),
not parallel to the active bit clearing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
