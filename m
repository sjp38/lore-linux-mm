Received: from localhost (riel@localhost)
	by brutus.conectiva.com.br (8.10.2/8.10.2) with ESMTP id e8PDs3l19113
	for <linux-mm@kvack.org>; Mon, 25 Sep 2000 10:54:03 -0300
Subject: Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt
 problem or FS buffer cache mgmt problem?
Message-ID: <OF0B0FB751.51865A31-ON88256962.00809BFB@LocalDomain>
From: "Ying Chen/Almaden/IBM" <ying@almaden.ibm.com>
Date: Fri, 22 Sep 2000 16:59:42 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.21.0009251053580.14614@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Hi, Rik,

I think I may have found out the problem with the memory problem that I
mentioned to you a while back. Correct me if I'm wrong.

The problem seems to be that when I ran SPEC SFS with large IOPS tests, it
created millions of files and directories. Linux uses a huge amount of
memory for inode and dcache (close to 1.5 GB). The rest of the memory (I
had 2 GB in total) is used for write/read buffer caches and some
kernel NFSD thread code  pages, etc. When the memory is exhausted, the
kswapd would kick in to free up the memory pages. However, in some cases,
when do_try_to_free_pages is called, it is called from an non-IO'able
environment. I think the calles were made from __alloc_pages() from the
network modules.  Since there is not much memory used for buffer cache and
mmaps, when try_to_free_pages() is called, shrink_mmap would not return
anything useful. Yet because GFP_IO is not turned on, there is no way to
free up memory used for inode and dcache. So, the memory allocation for the
NIC driver will fail. I got "IP: queue_glue: no memory available" kinda of
stuff from the console.

I printed out some messages from the vm module. I can see that when the
system ran into an infinite loop of some sort, which I don't quite
understand yet.  I'd think that I'd get a system crash at some point, since
no memory only fails operations. But I have not traced down while it went
into infinite loop. Sysrq-m tells me that I have run out of all the DMA,
NORMAL memory buffers. For HIGHMEM, I still have 800 MB available, but most
of it is from 2K pool. A few pages from other pools. I can't quite explain
this either. It seems that I should have run out of HIGHMEM also....

Any ideas?

BTW, the tests were run against test6.

Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
