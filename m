Date: Thu, 12 Sep 2002 16:33:08 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kiobuf interface / PG_locked flag
Message-ID: <20020912163308.I2273@redhat.com>
References: <3D8054D5.B385C83@scs.ch> <3D80B1C8.EE19E03D@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D80B1C8.EE19E03D@earthlink.net>; from jknapka@earthlink.net on Thu, Sep 12, 2002 at 09:24:56AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Joseph A. Knapka" <jknapka@earthlink.net>
Cc: Martin Maletinsky <maletinsky@scs.ch>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Sep 12, 2002 at 09:24:56AM -0600, Joseph A. Knapka wrote:

> > I just read about the kiobuf interface in the Linux Device Driver book from Rubini/Corbet, and there is one point, which I don't understand:
> > - map_user_kiobuf() forces the pages within a user space address range into physical memory, and increments their usage count, which subsequently prevents the pages from
> > being swapped out.
> 
> While it's true that having a non-zero reference count will prevent
> a page from being swapped out, such a page is still subject to
> all normal VM operations. In particular, the VM might unmap
> the page from your process, *decrement its reference count*, and
> then swap it out.

No.  The VM may unmap the page, and it may allocate a swap entry for
it, and it may decrement the reference count associated with any mmap
of the page, but it will NOT decrement the refcount associated with
the kiobuf itself, and will not evict the page from memory.

> > - lock_kiovec() sets the PG_locked flag for the pages in the kiobufs of a kiovec. The PG_locked flag prevents the pages from being swapped out, which is however already
> > ensured by map_user_kiobuf().
> 
> I believe PG_locked will prevent the VM from unmapping the
> page, which does, in fact, gaurantee that it won't be
> swapped out.

The page will not be swapped out anyway.  You don't need to lock it to
prevent that.  Locking may be useful if you want to serialise IO on a
particular page, but if you don't need that, there's just no point in
locking the pages.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
