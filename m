Date: Mon, 2 Jul 2001 19:39:50 +0100 (BST)
From: <markhe@veritas.com>
Subject: Can reverse VM locks?
Message-ID: <Pine.LNX.4.33.0107021917250.9756-100000@alloc.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

  I have been working with a quite old kernel tree, where
__find_page_nolock() was calling age_page_up() (which could have ended up
taking the "pagemap_lru_lock").
  Looking at recent kernels, I see that __find_page_nolock() is now simply
setting the PG_referenced bit.

  As far as I am aware, the old behaviour of __find_page_nolock() defined
the lock ordering between the "pagecache_lock" and "pagemap_lru_lock", and
other places had to follow this ordering.

  Now, isn't is possible to reverse this ordering?

  The reason for wanting to do so is scalability - the "pagecache_lock"
suffers from contention on high-way boxes.

  In functions, such as reclaim_page() and invalidate_inode_pages(), the
"pagecache_lock" is taken earlier than needed due to the lock ordering
with "page_lru_lock".  It should now be possible to delay taking this lock
until after the "page_lru_lock" and until some of the tests have been
preformed on the page (some of the tests would need to be redo after
taking the lock to avoid dangerious false negatives).

  Anyone know of any places where reversing the lock ordering would break?
  Unless anyone can think of any serious issues, I'll start coding this up
tomorrow (and find the issues for myself :)).

Thanks,
Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
