From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14337.64909.191024.839302@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 16:09:01 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <38008F28.76CD7B4D@colorfullife.com>
References: <Pine.LNX.4.10.9910091758380.5808-100000@alpha.random>
	<38008F28.76CD7B4D@colorfullife.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Oct 1999 15:05:44 +0200, Manfred Spraul <manfreds@colorfullife.com> said:

> Andrea Arcangeli wrote:
>> Look the swapout path. Without the big kernel lock you'll free vmas under
>> swap_out().

> I checked to code in mm/*.c, and it seems that reading the vma-list is
> protected by either lock_kernel() [eg: swapper] or down(&mm->mmap_sem)
> [eg: do_mlock].

The swapper relies on it being protected by the big lock.  The mm
semaphore is required when you need additional protection: specifically,
if you need to sleep while manipulating the vma lists (eg. in page
faults). 

> But this means that both locks are required if you modify the vma list.
> Single reader, multiple writer synchronization. Unusual, but interesting
> :-)

Correct, but you only need the one lock --- the big lock --- to read the
vma list, which is what the swapper does.  The swapper only needs write
access to the page tables, not to the vma list.

> How should we fix it?

> a) the swapper calls down(&mm->mmap_sem), but I guess that would
> lock-up.

Massive deadlock, indeed.  We've looked at this but it is soooo painful.

> b) everyone who changes the vma list calls lock_kernel().

... or an equivalent lock.  The big lock itself isn't needed if we have
a per-mm spinlock, but we do need something lighter weight than the mmap
semaphore to let the swapper read-protect the vma lists.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
