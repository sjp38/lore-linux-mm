Message-ID: <A33AEFDC2EC0D411851900D0B73EBEF766E1A7@NAPA>
From: Hua Ji <hji@netscreen.com>
Subject: PPC Page Table Bug or Patch
Date: Mon, 11 Jun 2001 21:18:45 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-embedded@lists.linuxppc.org, linux-mm@kvack.org, linuxppc-user@lists.linuxppc.org
Cc: Hua Ji <hji@netscreen.com>
List-ID: <linux-mm.kvack.org>

Folks,

I personally think,after some testing, there is a bug with current 2.4
linx-ppc hashed pag table part. Raise here for discussion and confirmation
in case I am wrong. 

In one word, the codes for page table hashing function won't support large
page table with size of 8M, 16M or 32M, even if you change the corresponding
Hash_base and Hash_bits value.

Please see below descriptions. Thanks for the patience.
----------------------------------------------------------------------------
--------------------------------------------

--------------------------------
Which files related to?
--------------------------------
File: ./kernel/hashtable.S 
Function: hash_page_patch_A in hash_page() for 32bit ppc cpu.

.globl	hash_page_patch_A
hash_page_patch_A:
lis	r4,Hash_base@h		/* base address of hash table */
rlwimi	r4,r5,32-1,26-Hash_bits,25	/* (VSID & hash_mask) << 6 */
rlwinm	r0,r3,32-6,26-Hash_bits,25	/* (PI & hash_mask) << 6 */
xor	r4,r4,r0		/* make primary hash */

------------------
When would happen?
------------------
The above codes won't work when Hash_bits increase to 17,18, or 19.
Testing done:	* Change Hash_base to a 32M aligned space
			* Change the Hash_bits to 19, which means all 19
bits hash value
			will take part in to compose the primary PTEG
address.
Testing Result:   The value with above codes give the wrong value, compared
to the manually calculated with
			the algorithm specified by the PowerPC spec.
------------------
Why happen?
------------------
The wrong/bug is from the :
rlwinm	r0,r3,32-6,26-Hash_bits,25	/* (PI & hash_mask) << 6 */
xor	r4,r4,r0		/* make primary hash */

Reason: When reach the above line, r3 contains the low word of the pte. For
example, 0xF0100000
When execute the aboe rlwinm, the following things happen
Bits: 0-----------------------------------------------------------31
r3: 	 1111  0000 0001 0000 0000 0000 0000 0000
				
r0:    0000 0011 1100 0000 0100 0000 0000 0000
		         ^-----|--API--|-----10 bits-----^
Bits:0-------------7----------------------------------25--------31
				     Total 19 bits   
As we can see, the first 3 bits(value of 111) of those 19 bits are not zero,
which is requried to be so (Refer to : Page 7-55, PowerPC TM Microprocessor 
Family: The Programming Environments for 32-Bit Microprocessors)
The reason why this happen is simple: The first 4 bits of the r3 register is
rotated to those position. In other words, the index of segment register
also take part in the hash. Hence, we say, when Hash_bits is upto 17, 18 or
19, the hash value will go wrong.

--------------------
Suggested fix
--------------------


We need make sure the first 3 bits of those 19 bits are zero out. The
suggested fix would be:

.globl	hash_page_patch_A
hash_page_patch_A:
lis	r4,Hash_base@h		/* base address of hash table */
rlwimi	r4,r5,32-1,26-Hash_bits,25	/* (VSID & hash_mask) << 6 */

/* Fix for large page table */

lis r7, 0x0FFF
ori r7,r7,0xFFFF  /* assume r7 is available for usage */
or r3, r3, r7  /* Or we can replace the above 3 lines with "rlwinm r3,
r3,0,4,31"?

/* Now do the primary hash, using 19 bits(000+API+10bits) from low word of
the PTE.
rlwinm	r0,r3,32-6,26-Hash_bits,25	/* (PI & hash_mask) << 6 */
xor	r4,r4,r0		/* make primary hash */

------------------
Testing done
-----------------

Tested with 32M page table size, it creates the correct hash value and
hardware can correctly address the primary PTE grouop. In other words,
750 cpu hardware creates the same hash value as the above did.

With the above fix, people, in order to support ANY size page table, only
need change the:
Hash_base
and
Hash_bits

----------------------------------------------------------------------------
----------------------------------------------------


Thanks,

Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
