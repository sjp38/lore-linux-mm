Subject: Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt
 problem or FS buffer cache mgmt problem?
Message-ID: <OF07A85924.76A9D082-ON88256966.0008D359@LocalDomain>
From: "Ying Chen/Almaden/IBM" <ying@almaden.ibm.com>
Date: Mon, 25 Sep 2000 18:53:19 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi,

It does not seem to be the fragmentation problem. I did  bit more
investigation on it. It turns out when
__alloc_pages() was called, the zonelist passed in had only two zones (DMA
and LOWMEM/NORMAL). Both of these zones
have been exhaused. So, _alloc_pages() returns NULL. However, my HIGHMEM
zone still has 800 MB free, and the memory space is not
fragmented in anyway (it's got lots of 2MB buffers). I was wrong in my last
email in that I said the HIGHMEM had 2k buffers, it really should be 2048KB
buffers. Sorry about that.  I misread the console output. try_to_free_pages
() was not able to return anything useful for DMA and NORMAL
zones since all the memory used in the NORMAL and DMA zones was for inode
cache and directory cache. Unless GFP_IO is turned on, do_try_to_free_pages
will not be able to free any memory I think, despite almost 1GB memory left
in the HIGHMEM zone.

Why didn't the zonelist contain all three zones but only the first two? I'm
trying to find out the answer myself too from the source.....


Ying
---------------------- Forwarded by Ying Chen/Almaden/IBM on 09/25/2000
06:34 PM ---------------------------

Ying Chen
09/22/2000 04:59 PM

To:   Rik van Riel <riel@conectiva.com.br>
cc:   "Theodore Y. Ts'o" <tytso@mit.edu>
From: Ying Chen/Almaden/IBM@IBMUS
Subject:  Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem
      mgmt problem or FS buffer cache mgmt problem?  (Document link: Ying
      Chen)

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
