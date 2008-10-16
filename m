Date: Thu, 16 Oct 2008 23:38:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: no way to swapoff a deleted swap file?
In-Reply-To: <1224145684.28131.25.camel@twins>
Message-ID: <Pine.LNX.4.64.0810162313570.26758@blonde.site>
References: <20081015202141.GX26067@cordes.ca> <1224145684.28131.25.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Peter Cordes <peter@cordes.ca>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Oct 2008, Peter Zijlstra wrote:
> On Wed, 2008-10-15 at 17:21 -0300, Peter Cordes wrote:
> > I unlinked a swapfile without realizing I was still swapping on it.
> > Now my /proc/swaps looks like this:
> > Filename                                Type            Size    Used	Priority
> > /var/tmp/EXP/cache/swap/1\040(deleted)  file            1288644 1448	-1
> > /var/tmp/EXP/cache/swap/2\040(deleted)  file            1433368 0	-2
> > 
> >  AFAICT, there's nothing I can pass to swapoff(2) that will make the
> > kernel let go of them.  If that's the case, please consider this a
> > feature request for a way to do this.  Now I'm going to have to reboot
> > before I can mkfs that partition.
> > 
> >  If kswapd0 had a fd open on the swap files, swapoff /proc/$PID/fd/3
> > could possibly work.  But it looks like the files are open but with no
> > user-space accessable file descriptors to them.  Which makes sense,
> > except for this case.
> 
> Right, except that kswapd is per node, so we'd either have to add it to
> all kswapd instances or a random one. Also, kthreads don't seem to have
> a files table afaict.
> 
> But yes, I see your problem and it makes sense to look for a nice
> solution.

No immediate answer springs to my mind.

It's not something I'd want to add a new system call for.
I guess we could put a magic file for each swap area
somewhere down in /sys, and allow swapoff to act upon that.

If there were other good reasons to add such files, that
could make sense.  But although I'll willingly admit it's a
lacuna, I don't think it's one worth bloating the kernel for.

(I would suggest that Peter keep a second link to his swapfiles
somewhere safer; but that's then open to the converse complaint,
that when he unlinks intentionally but forgets the safe link,
the disk space remains mysteriously in use.)

Sorry for being unhelpful!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
