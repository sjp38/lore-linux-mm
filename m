From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200005251520.QAA02278@raistlin.arm.linux.org.uk>
Subject: Re: shm_alloc and friends
Date: Thu, 25 May 2000 16:20:10 +0100 (BST)
In-Reply-To: <E12uz6w-0007xj-00@the-village.bc.nu> from "Alan Cox" at May 25, 2000 03:59:44 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: riel@nl.linux.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox writes:
> Use pte_clear. That is the only valid way to do it. Im not sure I follow why
> you cant use pte_clear in this case

pte_clear has other side effects on ARM, since we don't have enough bits in the
page tables to store all the bits that Linux needs.  In fact, there are NO bits
in the page table entries which are not CPU defined.

Therefore, we have to store the CPU's version of the page pointers at ptep[0]
through to ptep[1023], and the kernel's version with all the associated flags
in ptep[-1024] through to ptep[-1].

pte_alloc and friends are aware of this because they are allocating page tables,
and pte_clear is supposed to be used on page tables.

SHM uses it on *pages* allocated from __get_free_page() and kmalloc, which are
not page tables.

Therefore, really SHM's use of pte_clear is a hack in the extreme, breaking the
architecture independence of the page table macros.
   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | |   http://www.arm.linux.org.uk/~rmk/aboutme.html    /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
