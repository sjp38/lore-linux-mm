Message-ID: <009201bfb5e6$a33b9600$0a1e17ac@local>
From: "Manfred Spraul" <manfreds@colorfullife.com>
References: <Pine.LNX.4.21.0005041702560.2512-100000@alpha.random>
Subject: Re: classzone-VM + mapped pages out of lru_cache
Date: Thu, 4 May 2000 18:34:23 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Andrea Arcangeli" <andrea@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

>
> Because it's not necessary as far I can tell. Only one
> truncate_inode_pages() can run at once and none read or write can run
> under truncate_inode_pages(). This should be enforced by the VFS, and if
> that doesn't happen the truncate_inode_pages changes that gone into pre6
> (and following) hides the real bug.
>

truncate: VFS acquires inode->i_sem semaphore.[fs/open.c, do_truncate()]
write: VFS doesn't acquire the semaphore [new in 2.3], but f_op->write()
could acquire the semaphore.
e.g. generic_file_write() acquires the semaphore. [mm/filemap.c]
read: no locking. AFAICS read & truncate could run in parallel.

[I'm reading 2.3.99-pre6]
--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
