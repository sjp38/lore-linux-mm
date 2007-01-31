Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l0VDxDQk096076
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:59:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VDxDTk1663016
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 14:59:13 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VDxDh0027818
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 14:59:13 +0100
Message-ID: <45C0A0B0.4030100@de.ibm.com>
Date: Wed, 31 Jan 2007 14:59:12 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] mm: mremap correct rmap accounting
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com> <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com> <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com> <45BF68A4.5070002@de.ibm.com> <Pine.LNX.4.64.0701302157250.22828@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0701302157250.22828@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Carsten Otte <carsteno@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> But there is a change which I now think you do need to make,
> for 2.6.21 - let it not distract attention from the pagecount
> correctness issue we've been discussing so far.  Something I
> should have noticed when I first looked at your clever use of
> the ZERO_PAGE, but have only noticed now.  Doesn't it clash
> with the clever use of the ZERO_PAGE when reading /dev/zero
> (see read_zero_pagealigned in drivers/char/mem.c)?
> 
> Consider two PROT_READ|PROT_WRITE,MAP_PRIVATE mappings of a
> four-page hole in a XIP file.  One of them just readfaults the
> four pages in (and is given ZERO_PAGE for each), the other has
> four pages read from /dev/zero into it (which also maps the
> ZERO_PAGE into its four ptes).
> 
> Then imagine that non-zero data is written to the first page of
> that hole, by a write syscall, or through a PROT_WRITE,MAP_SHARED
> mapping.  __xip_unmap will replace the first ZERO_PAGE in each of
> the MAP_PRIVATE mappings by the new non-zero data page.  Which is
> correct for the first mapping which just did readfaults, but wrong
> for the second mapping which has overwritten by reading /dev/zero
> - those pages ought to remain zeroed, never seeing the later data.
Nasty. I got your point now, but as far as I can see we're still in-spec:

MAP_PRIVATE
Create a private copy-on-write mapping.  Stores to the region do not
affect the original file.  It is unspecified whether changes made to
the file after the mmap call are visible in the mapped region.

A fix could be to use my own empty page instead of the ZERO_PAGE for 
xip. At least we have different behavior with/without xip here, 
therefore I agree that this requires fixing.

Carsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
