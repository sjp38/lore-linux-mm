Date: Mon, 4 Sep 2000 15:05:07 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: zero copy IO project
In-Reply-To: <Pine.LNX.4.21.0009041231430.8855-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009041432150.17443-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fabio Riccardi <fabio.riccardi@free.fr>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Sep 2000, Rik van Riel wrote:

> On Mon, 4 Sep 2000, Fabio Riccardi wrote:
...
> > Is anybody aready working on this? Does anybody have ideas about
> > it? Anybody interested in a discussion of pros and cons of such
> > an architectural change to Linux?
> 
> The project (and data structure used) is called KIOBUF.
> 
> IIRC Stephen Tweedie and Ben LaHaise are working on it
> and it will be a more generic zero-copy IO infrastructure
> than io-lite and others.
...

First off, the current discussion on linux-kernel seems to be hitting upon
a lot of the relevant points, at least related to the network stack.

In terms of actual ToDos at the moment, most of the work is in the design
of kiobuf based APIs.  The rw_kiovec operation in my async io patches is
along the lines of what we want to do, but I need to write up actual docs
describing how it should be used and what the ideas are behind it (along
with going back to Stephen and making sure it fits in with his
ideas ;-).  A number of infrastructure patches from Stephen need to be
merged (probably 2.5 stuff), and then some of the more interesting things
like the kick-ass pipe code can, too.

Hmmm, there is the fewer copy code for packet fragments (read: NFS) that
needs to be kiobufified.  And TUX's zero copy TX code should accept
kiobufs.  Stephen mentioned a kiovec container file that needs to be
written.  The block layer rototiling is being thought about by a number of
people (SGI's XFS has a number of good ideas for the filesystem space that
will be useful)...  And the list goes on...

What exactly do you wish to accomplish zero copy io for?  The kiovec
container is probably the most useful part of the plan for generic zero
copy io, since it allows you to have a handle for a buffer in kernel space
that does not have to cross over into user space, but that can have
relevant parts of data added to it.  Ie, a userspace web server could
write() the header for an HTTP request into the container, then make use
of sendfile operations to transmit it and then the data directly from the
file onto the wire.

This isn't making much of a scratch into the ideas floating around, but
given some feedback perhaps we can narrow things down to a more useful
scope. =)  Cheers,

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
