From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906231812.LAA02787@google.engr.sgi.com>
Subject: mmap/MAP_SHARED and mandatory flock
Date: Wed, 23 Jun 1999 11:12:30 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

It seems to me that the mmap/MAP_SHARED locks_verify_locked() check
and fcntl_setlk() have no synchronization. For example, a process
invoking fcntl_setlk on a IS_MANDLOCK inode can check that it has
no i_mmap vma list, then go on and sleep later before queueing a
file_lock on the inode i_flock. Subsequently, an mmaper can come
in, invoke locks_verify_locked(), see no file_lock on the inode
i_flock, and succeed. The file locker can then wake up and also
return success.

Am I missing some synchronization lock/algorithm?

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
