Received: from weyl.math.psu.edu (weyl.math.psu.edu [146.186.130.226])
	by math.psu.edu (8.9.3/8.9.3) with ESMTP id XAA25131
	for <linux-mm@kvack.org>; Wed, 7 Jun 2000 23:45:58 -0400 (EDT)
Received: from localhost (viro@localhost)
	by weyl.math.psu.edu (8.9.3/8.9.3) with ESMTP id XAA13863
	for <linux-mm@kvack.org>; Wed, 7 Jun 2000 23:45:58 -0400 (EDT)
Date: Wed, 7 Jun 2000 23:45:58 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Contention on ->i_shared_lock in dup_mmap()
Message-ID: <Pine.GSO.4.10.10006072235360.10800-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

tests with -ac10 + dcache-ac10-MM1 and results are interesting: most of
contention comes from the dup_mmap().
109 dup_mmap:->i_shared_lock
48 do_syslog(case 5):console_lock
25 d_lookup:dcache_lock
21 enable_irq:desc->lock
20 bdget:bdev_lock
13 bdput:bdev_lock
9 __set_personality:->exit_sem
8 get_empty_filp:files_lock
7 insert_into_queues:hash_table_lock
...

OK, do_syslog() is just plain silly - it's resetting the buffer and code
in question looks so:
                spin_lock_irq(&console_lock);
                logged_chars = 0;
                spin_unlock_irq(&console_lock);
... which is for all purposes equivalent to
		if (logged_chars) {
			...
		}
so this one is easy (looks like a klogd silliness).

dcache_lock may need splitting. Or maybe not - I want to see more testing
results before going there.

bdget() and bdput() are my fault (bad hash-function and too small hash
table). Fixable.

__set_personality() one is actually a bug (it shouldn't be called at all
in the tests I've run) and that's also on todo list.

However, all that stuff pales compared to dup_mmap() one. What happens
there is that we copy all VMAs and insert them into ->i_shared lists of
their inodes. Which requires ->i_shared_lock and that amounts to visible
contention. Notice that most of the calls are followed by exec() and thus
by exit_mmap(), which merrily removes all these VMAs from their lists and
frees them.

Proposal: let's take the head of ->mmap out of the mm_struct, add
reference counter and allow the thing to be shared between different
mm_struct. Rules:
	a) whenever we take ->mmap_sem, take a semaphore on that new
structure (in principle that may make some uses of ->mmap_sem unneeded,
but that's another story).
	b) if we are going to modify the ->mmap (which requires ->mmap_sem
taken) && ->mmap is shared - create a private copy and use it (decrement
the counter on old one, indeed).
	c) fork() should just share the ->mmap with parent.
	d) exec() should drop the reference to ->mmap, killing it if we
were the sole owners.

	In effect it's COW for ->mmap. Comments?

PS: yes, the big lock was _way_ down the list - nowhere near the top ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
