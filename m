Date: Thu, 14 Jan 1999 23:43:43 -0700 (MST)
From: Colin Plumb <colin@nyx.net>
Message-Id: <199901150643.XAA25203@nyx10.nyx.net>
Subject: Re: Why don't shared anonymous mappings work?
Sender: owner-linux-mm@kvack.org
To: blah@kvack.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Um, I think you fail to understand.  I was talking about a linked list
>> *without* allocating extra space.  The idea is that I don't know of a
>> processor that requires more than 2 bits (M68K) to mark a PTE as invalid;
>> the user gets the rest.  Currently the user bits in the invalid PTE
>> encodings point to swap pages.  You could steal one bit and point to
>> either a word in memory or a swap page.

> Ooops, brain fart (sometimes you read, but the meaning just isn't
> absorbed).  I think assuming that you can get 30 bits out of a pte on a 32
> bit platform to use as a pointer is pushing things, though (and you do
> need all the bits: mremap allows users to move shared pages to different
> offset within a page table).

Not quite.  You only need as many bits as are needed to address all of
physical memory minus the number of bits implied by PTE alignment.

So, for a 2 GB machine, you need 29 bits for a pointer to a 32-bit word.
Plus one for the type bit does equal 30, but many machines are smaller.

The bits available (looking at include/asm-*/pgtable.h) are:
alpha: 32 (plus more, I think - the code doesn't try too hard.)
arm/proc-armo: 31
arm/proc-armv: 30
i386: 30
m68k: 30 (old), 27 (new)
mips: 24
ppc: 31
sparc: 25
sparc64: 51

We seem to be doing okay, except for the MIPS and Sparc ports, and maybe
the code isn't as aggressive as it cound be there.

> Under the scheme I'm planning on
> implementing, this is a non issue: all pages are tied to an inode. 
> Alternatively, we could pull i_mmap & co out of struct inode and make a
> vmstore (or whatever) object as I believe Eric suggested. 

What's nice is the low over head of the current scheme; there's no space
allocated for bookkeeping except two bytes of swap map per swap page.

You need to maintain a more complex structure, I think.
-- 
	-Colin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
