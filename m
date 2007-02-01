Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l11GLhIK033246
	for <linux-mm@kvack.org>; Thu, 1 Feb 2007 16:21:43 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11GLhGB1790122
	for <linux-mm@kvack.org>; Thu, 1 Feb 2007 17:21:43 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11GLhFU022218
	for <linux-mm@kvack.org>; Thu, 1 Feb 2007 17:21:43 +0100
Message-ID: <45C21397.6070809@de.ibm.com>
Date: Thu, 01 Feb 2007 17:21:43 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] mm: mremap correct rmap accounting
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com> <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com> <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com> <45BF68A4.5070002@de.ibm.com> <Pine.LNX.4.64.0701302157250.22828@blonde.wat.veritas.com> <45C0A0B0.4030100@de.ibm.com> <Pine.LNX.4.64.0701311600300.28314@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0701311600300.28314@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Carsten Otte <carsteno@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
 > I agree that last sentence _appears_ to give you a let out.  I
 > believe its intention is to address the case where one page has been
 > faulted in and written to by the app, the next page is unfaulted
 > then modified by some other means and then faulted into the app for
 > the first time:
 > that page will contain the mods made to the underlying object, even
 > though they were made after the private copy of the previous page
 > was taken (which copy should never show later mods to the underlying
 > object).
 > Whereas if the mapping were mmap'ed with MAP_LOCKED (or mlocked),
 > all pages would be faulted in immediately, and subsequent mods to
 > the underlying object never seen at all.
I see. Makes sense to interpret the spec that way.

 > Whatever the wording, I don't know of any application which is happy
 > for the modifications it makes to a MAP_PRIVATE mapping to disappear
 > without warning - except when it actually asks for that behaviour by
 > calling madvise(start, len, MADV_DONTNEED).
I am not happy with any visibility of xip to userland via filesystem 
syscalls. It is supposed to be transparent for userspace.

 > Yes, if your testing shows that it really does behave as I suspect.
It does indeed. My little test program shows it:
- ext2 in regular operation:
current state: read-faulted sparse mappings
content of area1:
content of area2:
current state: read zero into area1
content of area1:
content of area2:
current state: write data via sys_write
content of area1:
content of area2: this change was written using sys_write

- ext with xip:
current state: read-faulted sparse mappings
content of area1:
content of area2:
current state: read zero into area1
content of area1:
content of area2:
current state: write data via sys_write
content of area1: this change was written using sys_write
content of area2: this change was written using sys_write

That proves your suspicion. I will submit a fix. Thank you for 
pointing me at it.

Carsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
