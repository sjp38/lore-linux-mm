In-reply-to: <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
	(message from Linus Torvalds on Wed, 23 Jan 2008 11:35:21 -0800 (PST))
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in
 sys_msync()
References: <12010440803930-git-send-email-salikhmetov@gmail.com>  <1201044083504-git-send-email-salikhmetov@gmail.com>  <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org> <1201110066.6341.65.camel@lappy> <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
Message-Id: <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 23 Jan 2008 20:55:34 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> > 
> > It would need some addition piece to not call msync_interval() for
> > MS_SYNC, and remove the balance_dirty_pages_ratelimited_nr() stuff.
> > 
> > But yeah, this pte walker is much better. 
> 
> Actually, I think this patch is much better. 
> 
> Anyway, it's better because:
>  - it actually honors the range
>  - it uses the same code for MS_ASYNC and MS_SYNC
>  - it just avoids doing the "wait for" for MS_ASYNC.
> 
> However, it's totally untested, of course. What did you expect? Clean code 
> _and_ testing? 
> 
> [ Side note: it is quite possible that we should not do the 
>   SYNC_FILE_RANGE_WAIT_BEFORE on MS_ASYNC, and just skip over pages that 
>   are busily under writeback already.

MS_ASYNC is not supposed to wait, so SYNC_FILE_RANGE_WAIT_BEFORE
probably should not be used in that case.

What would be perfect, is if we had a sync mode, that on encountering
a page currently under writeback, would just do a page_mkclean() on
it, so we still receive a page fault next time one of the mappings is
dirtied, so the times can be updated.

Would there be any difficulties with that?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
