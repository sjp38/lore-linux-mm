Date: Wed, 23 Jan 2008 13:00:57 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in
 sys_msync()
In-Reply-To: <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.00.0801231248060.2803@woody.linux-foundation.org>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>  <1201044083504-git-send-email-salikhmetov@gmail.com>  <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org> <1201110066.6341.65.camel@lappy> <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
 <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>


On Wed, 23 Jan 2008, Miklos Szeredi wrote:
>
> > [ Side note: it is quite possible that we should not do the 
> >   SYNC_FILE_RANGE_WAIT_BEFORE on MS_ASYNC, and just skip over pages that 
> >   are busily under writeback already.
> 
> MS_ASYNC is not supposed to wait, so SYNC_FILE_RANGE_WAIT_BEFORE
> probably should not be used in that case.

Well, that would leave the page dirty (including in the page tables) if it 
was under page writeback when the MS_ASYNC happened.

So I agree, we shouldn't necessarily wait, but if we want the page tables 
to be cleaned, right now we need to.

> What would be perfect, is if we had a sync mode, that on encountering
> a page currently under writeback, would just do a page_mkclean() on
> it, so we still receive a page fault next time one of the mappings is
> dirtied, so the times can be updated.
> 
> Would there be any difficulties with that?

It would require fairly invasive changes. Right now the actual page 
writeback does effectively:

			...
                        if (wbc->sync_mode != WB_SYNC_NONE)
                                wait_on_page_writeback(page);

                        if (PageWriteback(page) ||
                            !clear_page_dirty_for_io(page)) {
                                unlock_page(page);
                                continue;
                        }

                        ret = (*writepage)(page, wbc, data);
			...

and that "clear_page_dirty_for_io()" really does clear *all* the dirty 
bits, so we absolutely must start writepage() when we have done that. And 
that, in turn, requires that we're not already under writeback.

Is it possible to fix? Sure. We'd have to split up 
clear_page_dirty_for_io() to do it, and do the

	if (mapping && mapping_cap_account_dirty(mapping))
			..

part first (before the PageWriteback() tests), and then doing the

	if (TestClearPageDirty(page))
			...

parts later (after checking that that we're not under page-writeback).

So it's not horribly hard, but it's kind of a separate issue right now. 
And while the *generic* page-writeback is easy enough to fix, I worry 
about low-level filesystems that have their own "writepages()" 
implementation. They could easily get that wrong.

So right now it seems that waiting for writeback to finish is the right 
and safe thing to do (and even so, I'm not actually willing to commit my 
suggested patch in 2.6.24, I think this needs more thinking about)

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
