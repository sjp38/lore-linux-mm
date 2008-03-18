Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
	end_page_writeback()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <E1JbbHf-0005rm-R5@pomaz-ex.szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191945.122011759@szeredi.hu> <1205840031.8514.346.camel@twins>
	 <E1JbaTH-0005jN-4r@pomaz-ex.szeredi.hu> <1205843375.8514.357.camel@twins>
	 <E1JbbHf-0005rm-R5@pomaz-ex.szeredi.hu>
Content-Type: text/plain
Date: Tue, 18 Mar 2008 14:08:22 +0100
Message-Id: <1205845702.8514.365.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-03-18 at 13:51 +0100, Miklos Szeredi wrote:
> > Yes, it does two things, _however_ those two things are very much
> > related. Your use-case that breaks this relation is an execption - and I
> > haven't really grasped it yet..
> > 
> > I'm in general not too keen about you having to export the BDI
> > accounting stuff and using it explicitly like this, but I'm afraid I
> > don't see a way around it - the danger is that other filesystems will
> > get creative (hence the req for GPL - that excludes the most creative
> > ones).
> > 
> > Yes, it makes sense to delay the write completion accounting until its
> > actually completed.. but I would suggest all writeback accounting.
> 
> Doesn't work, as long as we have throttle_vm_writeout() waiting for
> NR_WRITEBACK to go below a threshold, delaying the NR_WRITEBACK
> accounting could lead to a deadlock.
> 
> So at least until that's resolved NR_WRITEBACK_TEMP needs to be
> separate from NR_WRITEBACK_TEMP.  And it makes sense possibly even
> after that, as they are fundamentally different things.  The first one
> is page cache pages being under writeout, the second is just kernel
> buffers (mostly) unrelated to the page cache.

Urgh, throttle_vm_writeout() again.. Agreed, that'll deadlock.

> > So the thing that's in your way is that removing a page from the radix
> > tree doesn't imply its done writing. So perhaps we should make that
> > distinction instead?
> > 
> > So instead of conditionally do part of the accounting, never do it and
> > require something like: page_writeback_complete() to be called after a
> > successfull test_clear_page_writeback().
> 
> Yes, that's a possibility, but then normal filesystems miss out on the
> small optimization provided by doing the BDI accounting functions
> inside the same IRQ disabled region as the radix tree operation.
> Would that have any significant performance impact?

Yeah, realized that. Don't know, would have to measure it somehow...
some archs are rather slow with disabling IRQs, but we're talking about
writeout which should be dominated by the IO times.

Its just that your proposal exposes too much guts, I'd like the
interface to be a little higher level.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
