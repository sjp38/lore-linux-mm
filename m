Subject: Re: [patch] implement smarter atime updates support
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070805210446.57aa66f6@the-village.bc.nu>
References: <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	 <20070804163733.GA31001@elte.hu>
	 <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	 <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net>
	 <46B5A996.5060006@garzik.org> <20070805105850.GC4246@unthought.net>
	 <20070805124648.GA21173@elte.hu>
	 <alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org>
	 <20070805190928.GA17433@elte.hu> <20070805192226.GA20234@elte.hu>
	 <1186343582.25667.3.camel@laptopd505.fenrus.org>
	 <20070805210446.57aa66f6@the-village.bc.nu>
Content-Type: text/plain
Date: Sun, 05 Aug 2007 13:22:36 -0700
Message-Id: <1186345356.25667.7.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Jakob Oestergaard <jakob@unthought.net>, Jeff Garzik <jeff@garzik.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, 2007-08-05 at 21:04 +0100, Alan Cox wrote:
> O> you might want to add
> > 
> > 	/* 
> > 	 * if the inode is dirty already, do the atime update since
> > 	 * we'll be doing the disk IO anyway to clean the inode.
> > 	 */
> > 	if (inode->i_state & I_DIRTY)
> > 		return 1;
> 
> This makes the actual result somewhat less predictable. Is that wise ?
> Right now its clear what happens based on what user sequence of events
> and that this is easily repeatable.

I can see the repeatability argument; on the flipside, having a system
of "opportunistic atime", eg as good as you can go cheaply, but with
minimum guarantees has some attraction as well. For example one could
imagine a system where the inode gets it's atime updated anyway, just
not flagged for writing back to disk. If it later undergoes some event
that would cause it to go to disk, it gets preserved...

otoh that's even more unpredictable since VM pressure could drop this
update early.

For the dirty case, such drawbacks don't exist; it's just one more step
of "when we can cheaply".

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
