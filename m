Received: from traveler.cistron-office.nl ([62.216.29.67] helo=traveler)
	by smtp.cistron-office.nl with esmtp (Exim 3.35 #1 (Debian))
	id 1BXhbK-0004BE-00
	for <linux-mm@kvack.org>; Tue, 08 Jun 2004 16:29:18 +0200
Date: Tue, 8 Jun 2004 16:29:18 +0200
From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: Keeping mmap'ed files in core regression in 2.6.7-rc
Message-ID: <20040608142918.GA7311@traveler.cistron.net>
Reply-To: linux-mm@kvack.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm running a Usenet news server with a full feed. Software is
INN 2.4.1.

The list of all articles is called the "history database" and is
indexed by a history.hash and a history.index file, both sized
around 300-400 MB.

These hash and index files are mmap'ed by the main innd process.

A full usenet feed is 800-1000 GB/day, that's ~ 12MB / sec incoming
traffic going to the local spool disk. About the same amount of
traffic is sent out to peers.

With kernels 2.6.0 - 2.6.6, I did a "echo 15 > /proc/sys/vm/swappiness"
and the kernel did a pretty good job of keeping the mmap'ed files
mostly in core, which is needed for performance (100-200 database
queries/sec!).

This is the output with a 2.6.6 kernel:

# ps u -C innd
USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND
news       276 26.8 60.2 817228 624932 ?     D    01:57 232:55 /usr/local/news/b

Now I tried 2.6.7-rc2 and -rc3 (well rc2-bk-latest-before-rc3) and
with those kernels, performance goes to hell because no matter
how much I tune, the kernel will throw out the mmap'ed pages first.
RSS of the innd process hovers around 200-250 MB instead of 600.

Ideas ?

Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
