Received: from uow.edu.au (IDENT:akpm@[47.181.194.197])
          by pwold011.asiapac.nortel.com (8.9.3/8.9.3) with ESMTP id AAA23851
          for <linux-mm@kvack.org>; Sat, 8 Jul 2000 00:37:36 +1000
Message-ID: <3965EC8E.5950B758@uow.edu.au>
Date: Sat, 08 Jul 2000 00:43:26 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: sys_exit() and zap_page_range()
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

A couple of things...

First, let's concede that running mmap001 and mmap002 while you're
trying to achieve low scheduling latency is a dumb thing to do, but
let's explore it anyway.


On exit from mmap001, zap_page_range() is taking over 20 milliseconds on
a 500MHz processor.   Is there anything easy which can be done about
this?

No algorithmic optimisations leap out at me, so the options appear to
be:

(1) Live with it.

(2) Pass the mm over to the swapper task and let it quietly
    throw things away in the background.

(3) Put some conditional schedule calls in there.

I note that Ingo's low-latency patch does (3).  He's put `if
(current->need_resched) schedule();' in the loop in zap_pte_range().  In
2.4, it looks like this won't work because of the lock held on
mm->page_table_lock, and the lock held on mapping->i_shared_lock in
vmtruncate().

Can anyone suggest a simple, clean way of decreasing zap_page_range's
scheduling latency, in a way which you're prepared to support?



Secondly, and quite unrelatedly, mmap002: why does the machine spend 10
seconds pounding the disk during the exit() call?  The file has been
unlinked and all the memory is being freed up.  Apart from fiddling with
a bit of file metadata I don't see why any I/O needs to be performed at
this time.  What's it doing?

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
