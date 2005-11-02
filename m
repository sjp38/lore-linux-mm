Date: Wed, 2 Nov 2005 21:55:54 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: New bug in patch and existing Linux code - race with install_page()
 (was: Re: [PATCH] 2.6.14 patch for supporting madvise(MADV_REMOVE))
In-Reply-To: <1130967383.24503.112.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.61.0511022145450.18444@goblin.wat.veritas.com>
References: <1130366995.23729.38.camel@localhost.localdomain>
 <20051102014321.GG24051@opteron.random>  <1130947957.24503.70.camel@localhost.localdomain>
  <200511022054.15119.blaisorblade@yahoo.it> <1130967383.24503.112.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Blaisorblade <blaisorblade@yahoo.it>, Andrea Arcangeli <andrea@suse.de>, lkml <linux-kernel@vger.kernel.org>, akpm@osdl.org, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Nov 2005, Badari Pulavarty wrote:
> On Wed, 2005-11-02 at 20:54 +0100, Blaisorblade wrote:
> > > +       /* XXX - Do we need both i_sem and i_allocsem all the way ? */
> > > +       down(&inode->i_sem);
> > > +       down_write(&inode->i_alloc_sem);
> > > +       unmap_mapping_range(mapping, offset, (end - offset), 1);
> > In my opinion, as already said, unmap_mapping_range can be called without 
> > these two locks, as it operates only on mappings for the file.
> > 
> > However currently it's called with these locks held in vmtruncate, but I think 
> > the locks are held in that case only because we need to truncate the file, 
> > and are hold in excess also across this call.
> 
> I agree, I can push down the locking only for ->truncate_range - if
> no one has objections. (But again, it so special case - no one really
> cares about the performance of this interface ?).

I can't remember why i_alloc_sem got introduced, and don't have time to
work it out: something to do with direct I/O races, perhaps?  Someone
else must advise, perhaps you will be able to drop that one.

But I think you'd be very unwise to drop i_sem too.  i_mmap_lock gets
dropped whenever preemption demands here, i_sem is what's preventing
someone else coming along and doing a concurrent truncate or remove.
You don't want that.

Sorry, I've not yet had time to study your patch: I do intend to,
but cannot promise when.  I fear it won't be as easy as making
these occasional responses.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
