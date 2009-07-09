Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DAE426B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 18:15:51 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <7cb22078-f200-45e3-a265-10cce2ae8224@default>
Date: Thu, 9 Jul 2009 15:34:39 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
In-Reply-To: <4A566414.7060805@codemonkey.ws>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > If it guesses wrong and overcommits too aggressively,
> > the hypervisor must swap some memory to a "hypervisor
> > swap disk" (which btw has some policy challenges).
> > IMHO this is more of a "mainframe" model.
>=20
> No, not at all.  A guest marks a page as being "volatile",=20
> which tells=20
> the hypervisor it never needs to swap that page.  It can discard it=20
> whenever it likes.
>=20
> If the guest later tries to access that page, it will get a special=20
> "discard fault".  For a lot of types of memory, the discard fault=20
> handler can then restore that page transparently to the code that=20
> generated the discard fault.

But this means that either the content of that page must have been
preserved somewhere or the discard fault handler has sufficient
information to go back and get the content from the source (e.g.
the filesystem).  Or am I misunderstanding?

With tmem, the equivalent of the "failure to access a discarded page"
is inline and synchronous, so if the tmem access "fails", the
normal code immediately executes.

> AFAICT, ephemeral tmem has the exact same characteristics as volatile=20
> CMM2 pages.  The difference is that tmem introduces an API to=20
> explicitly=20
> manage this memory behind a copy interface whereas CMM2 uses=20
> hinting and=20
> a special fault handler to allow any piece of memory to be marked in=20
> this way.
> :
> I don't really agree with your analysis of CMM2.  We can map CMM2=20
> operations directly to ephemeral tmem interfaces so tmem is a=20
> subset of CMM2, no?

Not really.  I suppose one *could* use tmem that way, immediately
writing every page read from disk into tmem, though that would
probably cause some real coherency challenges.  But the patch as
proposed only puts ready-to-be-replaced pages (as determined by
Linux's PFRA) into ephemeral tmem.

The two services provided to Linux (in the proposed patch) by
tmem are:

1) "I have a page of memory that I'm about to throw away because
    I'm not sure I need it any more and I have a better use for
    that pageframe right now.  Mr Tmem might you have someplace
    you can squirrel it away for me in case I need it again?
    Oh, and by the way, if you can't or you lose it, no big deal
    as I can go get it from disk if I need to."
2) "I'm out of memory and have to put this page somewhere.  Mr
    Tmem, can you take it?  But if you do take it, you have to
    promise to give it back when I ask for it!  If you can't
    promise, never mind, I'll find something else to do with it."

> > In other words, CMM2, despite its name, is more of a
> > "subservient" memory management system (Linux is
> > subservient to the hypervisor) and tmem is more
> > collaborative (Linux and the hypervisor share the
> > responsibilities and the benefits/costs).
>=20
> What's appealing to me about CMM2 is that it doesn't change the guest=20
> semantically but rather just gives the VMM more information about how=20
> the VMM is using it's memory.  This suggests that it allows greater=20
> flexibility in the long term to the VMM and more importantly,=20
> provides an easier implementation across a wide range of guests.

I suppose changing Linux to utilize the two tmem services
as described above is a semantic change.  But to me it
seems no more of a semantic change than requiring a new
special page fault handler because a page of memory might
disappear behind the OS's back.

But IMHO this is a corollary of the fundamental difference.  CMM2's
is more the "VMware" approach which is that OS's should never have
to be modified to run in a virtual environment.  (Oh, but maybe
modified just slightly to make the hypervisor a little less
clueless about the OS's resource utilization.)  Tmem asks: If an
OS is going to often run in a virtualized environment, what
can be done to share the responsibility for resource management
so that the OS does what it can with the knowledge that it has
and the hypervisor can most flexibly manage resources across
all the guests?  I do agree that adding an additional API
binds the user and provider of the API less flexibly then without
the API, but as long as the API is optional (as it is for both
tmem and CMM2), I don't see why CMM2 provides more flexibility.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
