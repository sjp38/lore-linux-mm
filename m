Date: Mon, 11 Oct 1999 19:01:12 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <14338.25394.766252.528741@dukat.scot.redhat.com>
Message-ID: <Pine.GSO.4.10.9910111850370.18777-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 11 Oct 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Mon, 11 Oct 1999 20:02:40 +0200, Manfred Spraul
> <manfreds@colorfullife.com> said:
> 
> > What about something like a rw-semaphore which protects the vma list:
> > vma-list modifiers [ie merge_segments(), insert_vm_struct() and
> > do_munmap()] grab it exclusive, swapper grabs it "shared, starve
> > exclusive".
> 
> Deadlock.  Process A tries to do an mmap on mm A, gets the exclusive
> lock, tries to swap out from process B, and grabs mm B's shared lock.
> Process B in the mean time is doing the same thing and has an exclusive
> lock on mm B, and is trying to share-lock A.  Whoops.

<looking at the places in question>
insert_vm_struct doesn't allocate anything.
Ditto for merge_segments
In do_munmap() the area that should be protected (ripping the vmas from
the list) doesn't allocate anything too.
In the swapper we are protected from recursion, aren't we?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
