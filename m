Date: Fri, 26 May 2000 16:31:29 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526163129.B21662@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000526141526.E10082@redhat.com>; from sct@redhat.com on Fri, May 26, 2000 at 02:15:26PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > Agreed.  I looked at that code though and it seemed very... large.
> > I think COW address_space gets the same results with less code.  Fast, too.
> > I know what I've got to do to prove it :-)
> 
> How will it deal with fork() cases where the child starts mprotecting
> arbitrary regions, so that you have completely independent vmas all
> sharing the same private pages?

Each VMA points to an address_space, and each private address_space can
have a parent.  Pages that aren't hashed in a private address space are
found in the parent's address space.

When a VMA is cloned for fork(), they have the same address_space which
is now marked as requiring COW.  When you modify a page in either, a new
space is created which contains the modified pages and the appropriate
VMA refers to the new space.  Now if it was from a file there were page
modifications at all stages by everyone, you have a small tree of 4
address_spaces:

                      1 - underlying file
                      |
                      2 - privately modified pages from the file,
                     / \  shared by child & parent
                    /   \
pages only seen by 3     4 pages only seen by the child
the parent                          

The beauty here is that the sharing structure is quite explicit.

Note that stacked address_spaces are only created when they actually
contain pages, and page counters are used to collapse layers when
appropriate.

mprotect & partial munmap are fine.  What happens here is that the VMAs
created by those functions refer to the same address_space -- this time
without COW semantics.  For this, all VMAs sharing an address_space that
COW as a single unit are linked together.  A modification to any one
that COWs its address_space updates all its linked VMAs.

You didn't mention it, but that leaves mremap.  This is a fiddly one!
mremaps that simply expand or shrink a segment are fine by themselves.
mremaps that move a segment are fine by themselves.  But the combination
can cause page offset values to duplicate for different pages.

So mremap needs a fixup to create new address_spaces in certain unusual
cases and rehash pages when that happens.  I don't think those cases
occur in any usual use of mremap.

thanks,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
