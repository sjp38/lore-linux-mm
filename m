Date: Mon, 19 Mar 2001 18:46:17 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <Pine.LNX.4.33.0103192254130.1320-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0103191839510.1003-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>, MOLNAR Ingo <mingo@chiara.elte.hu>
List-ID: <linux-mm.kvack.org>

There is a 2.4.3-pre5 in the test-directory on ftp.kernel.org.

The complete changelog is appended, but the biggest recent change is the
mmap_sem change, which I updated with new locking rules for pte/pmd_alloc
to avoid the race on the actual page table build.

This has only been tested on i386 without PAE, and is known to break other
architectures. Ingo, mind checking what PAE needs? Generally, the changes
are simple, and really only implies changing the pte/pmd allocation
functions to _only_ allocate (ie removing the stuff that actually modifies
the page tables, as that is now handled by generic code), and to make sure
that the "pgd/pmd_populate()" functions do the right thing.

I have also removed the xxx_kernel() functions - for architectures that
need them, I suspect that the right approach is to just make the
"populate" funtions notice when "mm" is "init_mm", the kernel context.
That removed a lot of duplicate code that had little good reason.

This pre-release is meant mainly as a synchronization point for mm
developers, not for generic use.

	Thanks,

		Linus


-----
-pre5:
  - Rik van Riel and others: mm rw-semaphore (ps/top ok when swapping)
  - IDE: 256 sectors at a time is legal, but apparently confuses some
    drives. Max out at 255 sectors instead.
  - Petko Manolov: USB pegasus driver update
  - make the boottime memory map printout at least almost readable.
  - USB driver updates
  - pte_alloc()/pmd_alloc() need page_table_lock.

-pre4:
  - Petr Vandrovec, Al Viro: dentry revalidation fixes
  - Stephen Tweedie / Manfred Spraul: kswapd and ptrace race
  - Neil Brown: nfsd/rpc/raid cleanups and fixes

-pre3:
  - Alan Cox: continued merging
  - Urban Widmark: smbfs fix (d_add on already hashed dentry - no-no).
  - Andrew Morton: 3c59x update
  - Jeff Garzik: network driver cleanups and fixes
  - Gerard Roudier: sym-ncr drivers update
  - Jens Axboe: more loop cleanups and fixes
  - David Miller: sparc update, some networking fixes

-pre2:
  - Jens Axboe: fix loop device deadlocks
  - Greg KH: USB updates
  - Alan Cox: continued merging
  - Tim Waugh: parport and documentation updates
  - Cort Dougan: PowerPC merge
  - Jeff Garzik: network driver updates
  - Justin Gibbs: new and much improved aic7xxx driver 6.1.5

-pre1:
  - Chris Mason: reiserfs, another null bytes bug
  - Andrea Arkangeli: make SMP Athlon build
  - Alexander Zarochentcev: reiserfs directory fsync SMP locking fix
  - Jeff Garzik: PCI network driver updates
  - Alan Cox: continue merging
  - Ingo Molnar: fix RAID AUTORUN ioctl, scheduling improvements

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
