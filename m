Date: Wed, 20 Sep 2000 12:20:07 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how to translate virtual memory addresss into physical address ?
Message-ID: <20000920122007.M4608@redhat.com>
References: <39C86AF6.1040200@SANgate.com> <20000920105308.K4608@redhat.com> <39C890BC.7070308@SANgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39C890BC.7070308@SANgate.com>; from gabriel@SANgate.com on Wed, Sep 20, 2000 at 01:26:04PM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BenHanokh Gabriel <gabriel@SANgate.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux-MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Sep 20, 2000 at 01:26:04PM +0300, BenHanokh Gabriel wrote:

> my module will have to deal with user space virtual addresses which are mapped 
> either to the computer "main-memory" or to a pci-device memory.

User space virtual addresses aren't necessarily mapped anywhere.  They
can be swapped out, or for mmap they might not yet be faulted in at
all.  You have to deal with all the complications of faulting the page
and pinning it in memory if you want to deal with user virtual
addresses.  I'd definitely use map_user_kiobuf for this, but that
cannot yet deal with pci device memory.

> >  You can do the translation backwards, but only by walking
> > page tables.
> how do i do this ? i tought that pci-memory is not pageable

It's not pageable, but the virtual-to-physical address translation
still uses page tables.  "Non-pageable" just means that the page table
entries cannot get paged out, not that they don't exist.

> will the map_user_kiobuf handle pci-device memory correctly (AFAIK locking pci 
> memory is meaningless and that its memory is not split into pages ) ?

Not yet, no.  It can (and does) on the 2.2 version, but 2.4 encodes
the kiobuf pages as "struct page *" pointers and we need to teach it
how to generate such structs for dynamically-allocated memory regions
such as PCI.


Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
