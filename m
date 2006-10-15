Subject: Re: [patch 6/6] mm: fix pagecache write deadlocks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061015115656.GA25243@wotan.suse.de>
References: <20061013143516.15438.8802.sendpatchset@linux.site>
	 <20061013143616.15438.77140.sendpatchset@linux.site>
	 <1160912230.5230.23.camel@lappy>  <20061015115656.GA25243@wotan.suse.de>
Content-Type: text/plain
Date: Sun, 15 Oct 2006 15:51:09 +0200
Message-Id: <1160920269.5230.29.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> > > +		/*
> > > +		 * Must not enter the pagefault handler here, because we hold
> > > +		 * the page lock, so we might recursively deadlock on the same
> > > +		 * lock, or get an ABBA deadlock against a different lock, or
> > > +		 * against the mmap_sem (which nests outside the page lock).
> > > +		 * So increment preempt count, and use _atomic usercopies.
> > > +		 */
> > > +		inc_preempt_count();
> > >  		if (likely(nr_segs == 1))
> > > -			copied = filemap_copy_from_user(page, offset,
> > > +			copied = filemap_copy_from_user_atomic(page, offset,
> > >  							buf, bytes);
> > >  		else
> > > -			copied = filemap_copy_from_user_iovec(page, offset,
> > > -						cur_iov, iov_offset, bytes);
> > > +			copied = filemap_copy_from_user_iovec_atomic(page,
> > > +						offset, cur_iov, iov_offset,
> > > +						bytes);
> > > +		dec_preempt_count();
> > > +
> > 
> > Why use raw {inc,dec}_preempt_count() and not
> > preempt_{disable,enable}()? Is the compiler barrier not needed here? And
> > do we really want to avoid the preempt_check_resched()?
> 
> Counter to intuition, we actually don't mind being preempted here,
> but we do mind entering the (core) pagefault handler. Incrementing
> the preempt count causes the arch specific handler to bail out early
> before it takes any locks.
> 
> Clear as mud? Wrapping it in a better name might be an improvement?
> Or wrapping it into the copy*user_atomic functions themselves (which
> is AFAIK the only place we use it).

Right, but since you do inc the preempt_count you do disable preemption,
might as well check TIF_NEED_RESCHED when enabling preemption again.

Sticking it in the atomic copy functions does make sense to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
