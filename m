Message-ID: <3B5BFB1F.F2967398@scs.ch>
Date: Mon, 23 Jul 2001 12:23:27 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Question concerning the buddy allocator
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: paul@scs.ch
List-ID: <linux-mm.kvack.org>

Hello,

I am interested, if physically contiguous memory allocated from the buddy allocator may be freed in a different way than it was allocated. I.e. if a memory blocks of size
(2^x)*PAGE_SIZE allocated by one call to the buddy allocator can be freed in fragments of (2^y)*PAGE_SIZE, with 2^(x-y) successive calls to the buddy allocator, where y < x
and the fragments start at an address which is a multiple of (2^y)*PAGE_SIZE.

I looked it up in the 2.2.x and 2.4.x code, and performed some experiments with the 2.4.x code, and I found that freeing the memory blocks in multiple fragments was
possible. However, in order to free the fragments, the count field in the descriptor of the first page in each fragment needs to be set to 1. (This is because
__free_pages() checks the count field of the first pages descriptor before calling __free_pages_ok(), if the count field is not zero, no further action is taken and the
__free_pages() returns, i.e. no pages are re-inserted into the buddy allocation system.).

Can anyone tell me:
- If the proceeding I described (i.e. setting the count field to 1) is a 'legal' way to free fragments, and if not if there is another 'legal' way to do so. May the
modification of the page descriptor's count field have any undesired side-effects?
- What is the reason behind the check of the count field of the first page's descriptor in __free_pages().

Thank's for your help
regards
Martin

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
