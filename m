Date: Fri, 13 Sep 2002 14:41:27 +0200
From: Jan Hudec <bulb@ucw.cz>
Subject: Re: kiobuf interface / PG_locked flag
Message-ID: <20020913124127.GB23303@artax.karlin.mff.cuni.cz>
References: <3D8054D5.B385C83@scs.ch> <3D80B1C8.EE19E03D@earthlink.net> <20020912163308.I2273@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020912163308.I2273@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, Martin Maletinsky <maletinsky@scs.ch>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2002 at 04:33:08PM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Thu, Sep 12, 2002 at 09:24:56AM -0600, Joseph A. Knapka wrote:
> 
> > > I just read about the kiobuf interface in the Linux Device Driver book from Rubini/Corbet, and there is one point, which I don't understand:
> > > - map_user_kiobuf() forces the pages within a user space address range into physical memory, and increments their usage count, which subsequently prevents the pages from
> > > being swapped out.
> > 
> > While it's true that having a non-zero reference count will prevent
> > a page from being swapped out, such a page is still subject to
> > all normal VM operations. In particular, the VM might unmap
> > the page from your process, *decrement its reference count*, and
> > then swap it out.
> 
> No.  The VM may unmap the page, and it may allocate a swap entry for
> it, and it may decrement the reference count associated with any mmap
> of the page, but it will NOT decrement the refcount associated with
> the kiobuf itself, and will not evict the page from memory.
> 
> > > - lock_kiovec() sets the PG_locked flag for the pages in the kiobufs of a kiovec. The PG_locked flag prevents the pages from being swapped out, which is however already
> > > ensured by map_user_kiobuf().
> > 
> > I believe PG_locked will prevent the VM from unmapping the
> > page, which does, in fact, gaurantee that it won't be
> > swapped out.
> 
> The page will not be swapped out anyway.  You don't need to lock it to
> prevent that.  Locking may be useful if you want to serialise IO on a
> particular page, but if you don't need that, there's just no point in
> locking the pages.

Ref-counts protect from swapping out. But it's the PG_locked flag, that
protects from starting other IO. If you are writing, read must not
happen. If you are reading, nothing else at all must happen. So that's
the difference. map_use_kiobuf fault the pages in. lock_kiovec make
sure, that noone (else) is doing ANU IO on the pages.

--------------------------------------------------------------------------------
                  				- Jan Hudec `Bulb' <bulb@ucw.cz>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
