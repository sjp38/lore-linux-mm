Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 901D66B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 07:40:02 -0400 (EDT)
Subject: Re: [RFC PATCH] mm: let the bdi_writeout fraction respond more
 quickly
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <1276714466.1745.625.camel@laptop>
References: <1276523894.1980.85.camel@castor.rsk>
	 <1276526681.1980.89.camel@castor.rsk>  <1276714466.1745.625.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Jun 2010 12:39:56 +0100
Message-ID: <1276774796.1978.11.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-06-16 at 20:54 +0200, Peter Zijlstra wrote:
> On Mon, 2010-06-14 at 15:44 +0100, Richard Kennedy wrote:
> > > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > > index 2fdda90..315dd04 100644
> > > --- a/mm/page-writeback.c
> > > +++ b/mm/page-writeback.c
> > > @@ -144,7 +144,7 @@ static int calc_period_shift(void)
> > >       else
> > >               dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> > >                               100;
> > > -     return 2 + ilog2(dirty_total - 1);
> > > +     return ilog2(dirty_total - 1) - 4;
> > >  } 
> 
> IIRC I suggested similar things in the past and all we needed to do was
> find people doing the measurements on different bits of hardware or so..
> 
> I don't have any problems with the approach, all we need to make sure is
> that we never return 0 or a negative number (possibly ensure a minimum
> positive shift value).

Yep that sounds reasonable. would minimum shift of 4 be ok ?

something like

	max ( (ilog2(dirty_total - 1)- 4) , 4);

Unfortunately volunteers don't seem to be leaping out of the woodwork,
maybe Andrew could be persuaded to try this in his tree for a while and
see if any one squeaks ?

regards
Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
