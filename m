Date: Fri, 26 May 2000 08:45:45 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005261545.IAA89913@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

:Stephen C. Tweedie wrote:
:> > Agreed.  I looked at that code though and it seemed very... large.
:> > I think COW address_space gets the same results with less code.  Fast, too.
:> > I know what I've got to do to prove it :-)
:> 
:> How will it deal with fork() cases where the child starts mprotecting
:> arbitrary regions, so that you have completely independent vmas all
:> sharing the same private pages?
:
:Each VMA points to an address_space, and each private address_space can
:have a parent.  Pages that aren't hashed in a private address space are
:found in the parent's address space.
:
:When a VMA is cloned for fork(), they have the same address_space which
:is now marked as requiring COW.  When you modify a page in either, a new
:space is created which contains the modified pages and the appropriate
:VMA refers to the new space.  Now if it was from a file there were page
:modifications at all stages by everyone, you have a small tree of 4
:address_spaces:
:
:                      1 - underlying file
:                      |
:                      2 - privately modified pages from the file,
:                     / \  shared by child & parent
:                    /   \
:pages only seen by 3     4 pages only seen by the child
:the parent                          
:
:The beauty here is that the sharing structure is quite explicit.
:
:Note that stacked address_spaces are only created when they actually
:contain pages, and page counters are used to collapse layers when
:appropriate.
:...

    This appears to be very close to what FreeBSD does with its vm_map_entry
    and vm_object structures.  If you haven't read my article on how VM 
    objects work in FreeBSD, you really should, because you are going to hit
    exactly the same problems.  Ignore the linux jabs in the article :-)
    and skip to the 'VM objects' section.

	http://www.daemonnews.org/200001/freebsd_vm.html

    The article describes VM objects, which represent logical entities such
    as files or anonymous memory areas.   VM objects can be stacked to
    implement private adderss spaces (MAP_PRIVATE mappings).

    However, in FreeBSD a VM object represents a complete logical entity
    (such as a file), *NOT* a memory mapping.  There is a separate structure
    called a vm_map_entry which is responsible for mapping portions of a
    process's adderss space to portions of a VM object.   Things like COW
    flags and madvise() flags are stored in the vm_map_entry, not the 
    vm_object.  The actual function of doing a copy-on-write involves 
    stacking a new anonymous-memory (swap-backed) VM object in front of the
    one that took the COW hit, based on the COW flag in the vm_map_entry.
    Once the vm_map_entry is repointed to the new 'top layer' for that
    process, the COW flag can be cleared.  Write faults always occur in
    the top layer, so if you attempt to write to a page in a MAP_PRIVATE
    mapped file and that page cannot be found in the top level VM object
    (swap-backed anonymous memory object), it will be copied up from the
    lower level VM object (the one representing the actual file).

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
