Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id KAA09565
	for <linux-mm@kvack.org>; Sun, 23 May 1999 10:31:25 -0400
Received: from [134.96.127.199] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id va381389 for <linux-mm@kvack.org>; Sun, 23 May 1999 07:32:20 -0700
Message-ID: <3748111C.3F040C1F@colorfullife.com>
Date: Sun, 23 May 1999 16:30:52 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: kernel_lock() profiling results
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've written a small patch that measures the duration how long the
kernel-lock is owned.
The main results:
- compiling:
* nearly 60% of all callers release the lock after less than 1024 CPU
cycles.
* a few callers own the lock very long, e.g. sys_bdflush for more than
10 milliseconds (>0.01 seconds).
- serving web pages with apache:
* only 17% need less than 1024 CPU cycles
* 55% need less than 2048 CPU cycles.

The patch and a list of all functions which owned the lock for more then
1.5 milliseconds is at
http://www.colorfullife.com/manfreds/kernel_lock/


OTHO, 2048 cpu cycles is about as long as __cpu_user() needs for 700
bytes if source,dest are currently not in the cache (I've tested it
with a 16 MB move from user mode). The memmove will be even
slower with faster CPU's (i.e. with a higher cpu clock/bus clock
multiplier)

My question:
Shouldn't we change file_read_actor() [mm/filemap.c, the function which
copies data from the page cache to user mode]:
we could release the kernel lock if we copy more than 1024 bytes.
(we currently do that only if the user mode memory is not paged in.)

Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
