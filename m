Message-ID: <39B3FD1D.EB33427D@free.fr>
Date: Mon, 04 Sep 2000 21:50:53 +0200
From: Fabio Riccardi <fabio.riccardi@free.fr>
MIME-Version: 1.0
Subject: Re: zero copy IO project
References: <Pine.LNX.4.21.0009041432150.17443-100000@devserv.devel.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, thanks for the pointers & explainations!

What I want is a server capable of handling high bandwidth communication and
the kiobuf mechanisms seem to be able to do the right thing, provided that
one rewrites the user applications accordingly...

If I understand correctly the kiobuf interface allows a user process to map a
piece of kernel memory in its own addressing space to use as an IO buffer.
What I originally had in mind was more something like netbsd's
UVM: _transparent_ zero-copy IO.

With the UVM  user applications just invokes the plain old fwrite (buff,
...) and the system grabs the buffer from the user space into kernel space
without the application noticing it (the original buffer becomes TCOW in the
application space).

Measurements (Brustoloni-Genie) show that explicit interfaces don't offer
significative performance advantages wrt emulated copy, while the latter
allows to run legacy (apache...) software without modification. Moreover it
keeps the number of OS interfaces to a bareable minimum.

I understand that a UVM like thing would imply major changes in the
VM architecture, since a page loanout mechanism has to be added to allow user
applications to export pieces of their addressing space to the kernel or to
some other user app.

Thoughts?

 - Fabio

Ben LaHaise wrote:

> On Mon, 4 Sep 2000, Rik van Riel wrote:
>
> > On Mon, 4 Sep 2000, Fabio Riccardi wrote:
> ...
> > > Is anybody aready working on this? Does anybody have ideas about
> > > it? Anybody interested in a discussion of pros and cons of such
> > > an architectural change to Linux?
> >
> > The project (and data structure used) is called KIOBUF.
> >
> > IIRC Stephen Tweedie and Ben LaHaise are working on it
> > and it will be a more generic zero-copy IO infrastructure
> > than io-lite and others.
> ...
>
> First off, the current discussion on linux-kernel seems to be hitting upon
> a lot of the relevant points, at least related to the network stack.
>
> In terms of actual ToDos at the moment, most of the work is in the design
> of kiobuf based APIs.  The rw_kiovec operation in my async io patches is
> along the lines of what we want to do, but I need to write up actual docs
> describing how it should be used and what the ideas are behind it (along
> with going back to Stephen and making sure it fits in with his
> ideas ;-).  A number of infrastructure patches from Stephen need to be
> merged (probably 2.5 stuff), and then some of the more interesting things
> like the kick-ass pipe code can, too.
>
> Hmmm, there is the fewer copy code for packet fragments (read: NFS) that
> needs to be kiobufified.  And TUX's zero copy TX code should accept
> kiobufs.  Stephen mentioned a kiovec container file that needs to be
> written.  The block layer rototiling is being thought about by a number of
> people (SGI's XFS has a number of good ideas for the filesystem space that
> will be useful)...  And the list goes on...
>
> What exactly do you wish to accomplish zero copy io for?  The kiovec
> container is probably the most useful part of the plan for generic zero
> copy io, since it allows you to have a handle for a buffer in kernel space
> that does not have to cross over into user space, but that can have
> relevant parts of data added to it.  Ie, a userspace web server could
> write() the header for an HTTP request into the container, then make use
> of sendfile operations to transmit it and then the data directly from the
> file onto the wire.
>
> This isn't making much of a scratch into the ideas floating around, but
> given some feedback perhaps we can narrow things down to a more useful
> scope. =)  Cheers,
>
>                 -ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
