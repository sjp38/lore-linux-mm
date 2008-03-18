In-reply-to: <1205845702.8514.365.camel@twins> (message from Peter Zijlstra on
	Tue, 18 Mar 2008 14:08:22 +0100)
Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
	end_page_writeback()
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191945.122011759@szeredi.hu> <1205840031.8514.346.camel@twins>
	 <E1JbaTH-0005jN-4r@pomaz-ex.szeredi.hu> <1205843375.8514.357.camel@twins>
	 <E1JbbHf-0005rm-R5@pomaz-ex.szeredi.hu> <1205845702.8514.365.camel@twins>
Message-Id: <E1JbcKL-00060V-9N@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Mar 2008 14:58:05 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peterz@infradead.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > So the thing that's in your way is that removing a page from the radix
> > > tree doesn't imply its done writing. So perhaps we should make that
> > > distinction instead?
> > > 
> > > So instead of conditionally do part of the accounting, never do it and
> > > require something like: page_writeback_complete() to be called after a
> > > successfull test_clear_page_writeback().
> > 
> > Yes, that's a possibility, but then normal filesystems miss out on the
> > small optimization provided by doing the BDI accounting functions
> > inside the same IRQ disabled region as the radix tree operation.
> > Would that have any significant performance impact?
> 
> Yeah, realized that. Don't know, would have to measure it somehow...
> some archs are rather slow with disabling IRQs, but we're talking about
> writeout which should be dominated by the IO times.
> 
> Its just that your proposal exposes too much guts, I'd like the
> interface to be a little higher level.

Well, but this is the kernel, you can't really make foolproof
interfaces.  If we'll go with Andrew's suggestion, I'll add comments
warning users about not touching those flags unless they know what
they are doing, OK?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
