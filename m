Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DDAA86B00C2
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 03:03:48 -0500 (EST)
Date: Mon, 5 Jan 2009 09:02:43 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH, RFC] Use WRITE_SYNC in __block_write_full_page() if WBC_SYNC_ALL
Message-ID: <20090105080241.GX32491@kernel.dk>
References: <E1LJatq-00061O-0e@closure.thunk.org> <20090104142303.98762f81.akpm@linux-foundation.org> <20090104224351.GF22958@mit.edu> <20090104151927.1f1603c6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090104151927.1f1603c6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Tso <tytso@mit.edu>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 04 2009, Andrew Morton wrote:
> On Sun, 4 Jan 2009 17:43:51 -0500 Theodore Tso <tytso@mit.edu> wrote:
> 
> > On Sun, Jan 04, 2009 at 02:23:03PM -0800, Andrew Morton wrote:
> > > > Following up with an e-mail thread started by Arjan two months ago,
> > > > (subject: [PATCH] Give kjournald a IOPRIO_CLASS_RT io priority), I have
> > > > a patch, just sent to linux-ext4@vger.kernel.org, which fixes the jbd2
> > > > layer to submit journal writes via submit_bh() with WRITE_SYNC.
> > > > Hopefully this might be enough of a priority boost so we don't have to
> > > > force a higher I/O priority level via a buffer_head flag.  However,
> > > > while looking through the code paths, in ordered data mode, we end up
> > > > flushing data pages via the page writeback paths on a per-inode basis,
> > > > and I noticed that even though we are passing in
> > > > wbc.sync_mode=WBC_SYNC_ALL, __block_write_full_page() is using
> > > > submit_bh(WRITE, bh) instead of submit_bh(WRITE_SYNC).
> > > 
> > > But this is all the wrong way to fix the problem, isn't it?
> > > 
> > > The problem is that at one particular point, the current transaction
> > > blocks callers behind the committing transaction's IO completion.
> > > 
> > > Did anyone look at fixing that?  ISTR concluding that a data copy and
> > > shadow-bh arrangement might be needed.
> > 
> > I haven't had time to really drill down into the jbd code yet, and
> > yes, eventually we probably want to do this.
> 
> We do.
> 
> >  Still, if we are
> > submitting I/O which we are going to end up waiting on, we really
> > should submit it with WRITE_SYNC, and this patch should optimize
> > writes in other situations; for example, if we fsync() a file, we will
> > also end up calling block_write_full_page(), and so supplying the
> > WRITE_SYNC hint to the block layer would be a Good Thing.
> 
> Is it?  WRITE_SYNC means "unplug the queue after this bh/BIO".  By setting
> it against every bh, don't we risk the generation of more BIOs and
> the loss of merging opportunities?

But it also implies that the io scheduler will treat the IO as sync even
if it is a write, which seems to be the very effect that Ted is looking
for as well.

Perhaps we should seperate it into two behavioural flags instead and
make the unplugging explicit.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
