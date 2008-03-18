Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
	end_page_writeback()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <E1JbaTH-0005jN-4r@pomaz-ex.szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191945.122011759@szeredi.hu> <1205840031.8514.346.camel@twins>
	 <E1JbaTH-0005jN-4r@pomaz-ex.szeredi.hu>
Content-Type: text/plain
Date: Tue, 18 Mar 2008 13:29:35 +0100
Message-Id: <1205843375.8514.357.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-03-18 at 12:59 +0100, Miklos Szeredi wrote:
> > On Mon, 2008-03-17 at 20:19 +0100, Miklos Szeredi wrote:
> > > plain text document attachment (end_page_writeback_nobdi.patch)
> > > From: Miklos Szeredi <mszeredi@suse.cz>
> > > 
> > > Fuse's writepage will need to clear page writeback separately from
> > > updating the per BDI counters.
> > 
> > This is because of the juggling with temporary pages, right?
> > 
> > Would be nice to have some comments in the code explaining this.
> 
> Yup, well it will go through a bigger cleanup, as discussed with
> Andrew, if that's OK with you?

Well, I was pondering that - it hadn't made its way out to the other
side of my brain yet.. but I'll dump have I have:

Yes, it does two things, _however_ those two things are very much
related. Your use-case that breaks this relation is an execption - and I
haven't really grasped it yet..

I'm in general not too keen about you having to export the BDI
accounting stuff and using it explicitly like this, but I'm afraid I
don't see a way around it - the danger is that other filesystems will
get creative (hence the req for GPL - that excludes the most creative
ones).

Yes, it makes sense to delay the write completion accounting until its
actually completed.. but I would suggest all writeback accounting.

So the thing that's in your way is that removing a page from the radix
tree doesn't imply its done writing. So perhaps we should make that
distinction instead?

So instead of conditionally do part of the accounting, never do it and
require something like: page_writeback_complete() to be called after a
successfull test_clear_page_writeback().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
