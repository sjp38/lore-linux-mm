Date: Fri, 3 Nov 2000 03:33:37 -0800
Message-Id: <200011031133.DAA10265@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200011031139.eA3BdMH19480@trampoline.thunk.org> (tytso@mit.edu)
Subject: Re: BUG FIX?: mm->rss is modified in some places without holding the  page_table_lock
References: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local> <200011031139.eA3BdMH19480@trampoline.thunk.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tytso@mit.edu
Cc: davej@suse.de, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   Given that we don't have a 64-bit atomic_t type, what do people
   think of Davej's patch?  (attached, below)

Broken, in 9 out of 10 places where he adds page_table_lock
acquisitions, this lock is already held --> instant deadlock.

This report is complicated by the fact that people were forgetting
that vmlist_*_{lock,unlock}(mm) was actually just spin_{lock,unlock}
on mm->page_table_lock.  I fixed that already by removing the dumb
vmlist locking macros which were causing all of this confusion.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
