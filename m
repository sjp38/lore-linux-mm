Message-ID: <3F44F572.3070903@movaris.com>
Date: Thu, 21 Aug 2003 09:38:10 -0700
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: Buddy algorithm questions
References: <3F428E4E.4050402@movaris.com>
In-Reply-To: <3F428E4E.4050402@movaris.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Manager List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all,

I am using Mel's excellent primer on the VM and the O'Reilly kernel 
book, but I'm unable (too daft?) to find answers to the following 
questions on buddy pairing:

1. Are "page_idx", "index", "buddy1", and "buddy2" always a multiple of
    2^order? I don't think index needs to be, but I believe it's
    absolutely critical that the others are. Is this correct?

2. Is the address of buddy2 always after the address of buddy1 or is the
    address of buddy2 always before the address of buddy1? My assumption
    is "no", because from __free_pages_ok:

        buddy1 = base + (page_idx ^ -mask);
        buddy2 = base + page_idx;

    (page_idx ^ -mask) flips the 2^order bit of page_idx. So there are
    two cases:

        1. If the 2^order bit *was* set, "page_idx ^ -mask" *clears* the
           bit with the result that the value is (page_idx - 2^order).
           Thus the address of buddy1 is less than the address of buddy2.
        2. If the 2^order bit was *not* set, "page_idx ^ -mask" *sets*
           the bit with the result that the value is (page_idx +
           2^order). Thus buddy1 > buddy2.

    Is this assessment correct?

3. Question 2 dealt with the *addresses* of buddy1 and buddy2. What
    about their respective *indexes* into the zone's mem_map array? That
    is, is the index of buddy2 always after the index of buddy1 or is the
    index of buddy2 always before the index of buddy1?

4. __free_pages_ok performs a bitwise exclusive OR to find the buddy.
    However, on the allocation side of things __alloc_pages, rmqueue, nor
    expand have any such bitwise operations. The code in expand makes it
    look as though buddy2's address is always buddy1's plus the
    order-sized page block. How is it then that sometimes buddy1's
    address is before buddy2's and sometimes it's after in
    __free_pages_ok as mentioned in question 2 above?

I look forward to your answers or pointers to answers ;)

Thanks,
Kirk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
