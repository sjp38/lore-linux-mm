Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 423976B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 02:12:30 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so948187eek.7
        for <linux-mm@kvack.org>; Tue, 13 May 2014 23:12:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z48si827469eey.23.2014.05.13.23.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 23:12:28 -0700 (PDT)
Date: Wed, 14 May 2014 07:12:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/19] fs: buffer: Do not use unnecessary atomic
 operations when discarding buffers
Message-ID: <20140514061222.GW23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-18-git-send-email-mgorman@suse.de>
 <20140513152900.ea0a58cf4a650fb0b4110e3e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513152900.ea0a58cf4a650fb0b4110e3e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 03:29:00PM -0700, Andrew Morton wrote:
> On Tue, 13 May 2014 10:45:48 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Discarding buffers uses a bunch of atomic operations when discarding buffers
> > because ...... I can't think of a reason. Use a cmpxchg loop to clear all the
> > necessary flags. In most (all?) cases this will be a single atomic operations.
> > 
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -1485,14 +1485,18 @@ EXPORT_SYMBOL(set_bh_page);
> >   */
> >  static void discard_buffer(struct buffer_head * bh)
> >  {
> > +	unsigned long b_state, b_state_old;
> > +
> >  	lock_buffer(bh);
> >  	clear_buffer_dirty(bh);
> >  	bh->b_bdev = NULL;
> > -	clear_buffer_mapped(bh);
> > -	clear_buffer_req(bh);
> > -	clear_buffer_new(bh);
> > -	clear_buffer_delay(bh);
> > -	clear_buffer_unwritten(bh);
> > +	b_state = bh->b_state;
> > +	for (;;) {
> > +		b_state_old = cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAGS_DISCARD));
> > +		if (b_state_old == b_state)
> > +			break;
> > +		b_state = b_state_old;
> > +	}
> >  	unlock_buffer(bh);
> >  }
> >  
> > --- a/include/linux/buffer_head.h
> > +++ b/include/linux/buffer_head.h
> > @@ -77,6 +77,11 @@ struct buffer_head {
> >  	atomic_t b_count;		/* users using this buffer_head */
> >  };
> >  
> > +/* Bits that are cleared during an invalidate */
> > +#define BUFFER_FLAGS_DISCARD \
> > +	(1 << BH_Mapped | 1 << BH_New | 1 << BH_Req | \
> > +	 1 << BH_Delay | 1 << BH_Unwritten)
> > +
> 
> There isn't much point in having this in the header file is there?
> 

No, it's not necessary. I was just keeping it with the definition of the
flags. Your fix on top looks fine.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
