Date: Sun, 15 Sep 2002 17:54:41 +0200
From: Jan Hudec <bulb@ucw.cz>
Subject: Re: kiobuf interface / PG_locked flag
Message-ID: <20020915155441.GA3636@vagabond>
References: <3D8054D5.B385C83@scs.ch> <3D80B1C8.EE19E03D@earthlink.net> <20020912163308.I2273@redhat.com> <20020913124127.GB23303@artax.karlin.mff.cuni.cz> <20020913154541.E17450@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020913154541.E17450@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, Martin Maletinsky <maletinsky@scs.ch>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2002 at 03:45:41PM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Fri, Sep 13, 2002 at 02:41:27PM +0200, Jan Hudec wrote:
> 
> > Ref-counts protect from swapping out. But it's the PG_locked flag, that
> > protects from starting other IO. If you are writing, read must not
> > happen. If you are reading, nothing else at all must happen. So that's
> > the difference. map_use_kiobuf fault the pages in. lock_kiovec make
> > sure, that noone (else) is doing ANU IO on the pages.
> 
> Depends on what semantics you want.  There's nothing to stop a kiobuf
> from being modified in flight.  All the app has to do is create a
> thread and modify the buffer from within that thread.

Well, if a multithread application writes to a buffer in one buffer
while doing IO in another, it's asking for trouble. But kernel must make
sure it does not start parallel IO on the same page, so the application
does not get garbage when it behaves correctly (btw, share read-write
mmap will probably get you in trouble anyway - or does kernel modify
PTEs on locking a page?).

-------------------------------------------------------------------------------
						 Jan 'Bulb' Hudec <bulb@ucw.cz>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
