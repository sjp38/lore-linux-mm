Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A22DA6B004F
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 15:45:39 -0500 (EST)
Message-ID: <4EF78B6A.8020904@parallels.com>
Date: Mon, 26 Dec 2011 00:45:30 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/3] Extend the mincore() report bits
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi.

We're currently working on the "Checkpoint-Restart in the Userspace" project. The
aim of the project is to dump a full (as full as possible) state of a running process
set (e.g. an application or a container) and recreate them at exactly the same state
later [1]

One of the parts of this state-dumping is dumping the memory of the processes. Since
apps usually mmap() more memory, than they actually use, dumping the whole mapping
contents is too expensive. To reduce this data we currently use the mincore() syscall
to check which pages are currently in memory and should be dumped, and which are not
and can be skipped. This simple trick reduces the dump size greatly, buy has three
problems.

1. File pages, that were not mapped by a task, but that were brought to page cache
   somehow (readahead or shared lib usage by other task) are reported as present and we 
   dump them, while we can skip them, since reading the page from file again at restore 
   time gives the correct page;
2. File pages, that are mapped by private mapping but that are not yet cow-ed are also
   reported as present, but we can skip them as well -- they can be re-read from disk;
2. Pages, that are swapped out are not reported by existing mincore(), and we skip them,
   and this is a bug :(

That said, I propose to add 2 more bits to the mincore per-page report to address these
problems. Plz, find details in the respective patches.

[1]
The project homepage is at http://criu.org
The project sources can be found here:
tools:  https://github.com/cyrillos/crtools
kernel: https://github.com/cyrillos/linux-2.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
