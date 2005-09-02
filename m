Message-ID: <4317F071.1070403@yahoo.com.au>
Date: Fri, 02 Sep 2005 16:25:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: New lockless pagecache
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

There were a number of problems with the old lockless pagecache:

- page_count of free pages was unstable, which meant an extra atomic
   operation when allocating a new page (had to use get_page instead
   of set_page_count).

- This meant a new page flag PG_free had to be introduced.

- Also needed a spin loop and memory barriers added to the page
   allocator to prevent a free page with a speculative reference on
   it from being allocated.

- This introduced the requirement that interrupts be disabled in
   page_cache_get_speculative to prevent deadlock, which was very
   disheartening.

- Too complex.

- To cap it off, there was an "unsolvable" race whereby a second
   page_cache_get_speculative would not be able to detect it had
   picked up a free page, and try to free it again.

The elegant solution was right under my nose the whole time.
I introduced an atomic_cmpxchg and use that to ensure we don't
touch ->_count of a free page. This solves all the above problems.

I think this is getting pretty stable. No guarantees of course,
but it would be great if anyone gave it a test.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
