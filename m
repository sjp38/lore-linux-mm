Date: Thu, 28 Sep 2000 17:13:59 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000928165427.K17518@athlon.random>
Message-ID: <Pine.LNX.4.21.0009281704430.9445-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Andrea Arcangeli wrote:

> The DBMS uses shared SCSI disks across multiple hosts on the same SCSI
> bus and synchronize the distributed cache via TCP. Tell me how to do
> that with the OS cache and mmap.

this could be supported by:

1) mlock()-ing the whole mapping.

2) introducing sys_flush(), which flushes pages from the pagecache.

3) doing sys_msync() after dirtying a range and before sending a TCP
   event.

Whenever the DB-cache-flush-event comes over TCP, it calls sys_flush() for
that given virtual address range or file address space range. Sys_flush
flushes the page from the pagecache and unmaps the address. Whenever it's
needed again by the application it will be faulted in and read from disk.

Can anyone see any problems with the concept of this approach? This can be
used for a page-granularity distributed IO cache.

(there are some smaller problems with this approach, like mlock() on a big
range can only be done by priviledged users, but thats not an issue IMO.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
