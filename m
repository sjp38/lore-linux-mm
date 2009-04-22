Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD846B007E
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 20:41:25 -0400 (EDT)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id n3M0fxnV009146
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 01:41:59 +0100
Received: from rv-out-0506.google.com (rvbg37.prod.google.com [10.140.83.37])
	by spaceape7.eur.corp.google.com with ESMTP id n3M0fuTZ003774
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 17:41:57 -0700
Received: by rv-out-0506.google.com with SMTP id g37so1167912rvb.35
        for <linux-mm@kvack.org>; Tue, 21 Apr 2009 17:41:56 -0700 (PDT)
Date: Tue, 21 Apr 2009 17:41:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 21/25] Use allocation flags as an index to the zone
 watermark
In-Reply-To: <20090422092429.6271.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0904211739520.31232@chino.kir.corp.google.com>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-22-git-send-email-mel@csn.ul.ie> <20090422092429.6271.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009, KOSAKI Motohiro wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 376d848..e61867e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1157,10 +1157,13 @@ failed:
> >  	return NULL;
> >  }
> >  
> > -#define ALLOC_NO_WATERMARKS	0x01 /* don't check watermarks at all */
> > -#define ALLOC_WMARK_MIN		0x02 /* use pages_min watermark */
> > -#define ALLOC_WMARK_LOW		0x04 /* use pages_low watermark */
> > -#define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
> > +/* The WMARK bits are used as an index zone->pages_mark */
> > +#define ALLOC_WMARK_MIN		0x00 /* use pages_min watermark */
> > +#define ALLOC_WMARK_LOW		0x01 /* use pages_low watermark */
> > +#define ALLOC_WMARK_HIGH	0x02 /* use pages_high watermark */
> > +#define ALLOC_NO_WATERMARKS	0x08 /* don't check watermarks at all */
> > +#define ALLOC_WMARK_MASK	0x07 /* Mask to get the watermark bits */
> 
> the mask only use two bit. but mask definition is three bit (0x07), why?
> 

I think it would probably be better to simply use

	#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS - 1)

here and define ALLOC_NO_WATERMARKS to be 0x04.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
