Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1EE6B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:55:06 -0500 (EST)
In-reply-to: <20101215052450.GQ5638@random.random> (message from Andrea
	Arcangeli on Wed, 15 Dec 2010 06:24:50 +0100)
Subject: Re: Deadlocks with transparent huge pages and userspace fs daemons
References: <1288817005.4235.11393.camel@nimitz>
 <20101214174626.GN5638@random.random>
 <E1PSc21-0004ob-M6@pomaz-ex.szeredi.hu> <20101215052450.GQ5638@random.random>
Message-Id: <E1PSskf-00066t-US@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 15 Dec 2010 15:54:45 +0100
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: miklos@szeredi.hu, dave@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shenlinf@cn.ibm.com, volobuev@us.ibm.com, mel@linux.vnet.ibm.com, dingc@cn.ibm.com, lnxninja@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 15 Dec 2010, Andrea Arcangeli wrote:
> Hello Miklos and everyone,
> 
> On Tue, Dec 14, 2010 at 10:03:33PM +0100, Miklos Szeredi wrote:
> > This is all fine and dandy, but please let's not forget about the
> > other thing that Dave's test uncovered.  Namely that page migration
> > triggered by transparent hugepages takes the page lock on arbitrary
> > filesystems.  This is also deadlocky on fuse, but also not a good idea
> > for any filesystem where page reading time is not bounded (think NFS
> > with network down).
> 
> In #33 I fixed the mmap_sem write issue which is more clear to me and
> it makes the code better.
> 
> The page lock I don't have full picture on it. Notably there is no
> waiting on page lock on khugepaged and khugepaged can't use page
> migration (it's not migrating, it's collapsing).
> 
> The page lock mentioned in migration context I don't see how can it be
> related to THP. There's not a _single_ lock_page in mm/huge_memory.c .
> 
> If fuse has deadlock troubles in migration lock_page then I would
> guess THP has nothing to do with it memory compaction, and it can
> trigger already in upstream stable 2.6.36 when CONFIG_COMPACTION=y by
> just doing:
> 	
> 	echo 1024 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
> 
> or by simply insmodding a driver that tries a large
> alloc_pages(order).
> 
> My understanding of Dave's trace is that THP makes it easier to
> reproduce, but this isn't really THP related, it can happen already
> upstream without my patchset applied, and it's just a pure coincidence
> that THP makes it more easy to reproduce.

Right, it's questionable whether any page migration should wait for
I/O as it can introduce large delays, and even complete lockup of an
unrelated process (as in case of NFS server being offline).

The man page for move_pages() clearly defines I/O as an error
condition:

  -EBUSY The page is currently busy and cannot be moved.  Try again
    later.  This occurs if a page is undergoing I/O or another ker-
    nel subsystem is holding a reference to the page.

yet the actual code waits for I/O, both read and write.  That might be
OK with some timeouts.  Page migration is best effort anyway, so
waiting forever on I/O makes little sense.

>  How to fix I'm not sure yet
> as I didn't look into it closely as I was focusing on rolling a THP
> specific update first, but at the moment it even sounds more like an
> issue with strict migration than memory compaction.

Yes, this is a page migration issue.  But the fact is, THP will make
it more visible exactly because it can be used without any special
configuration.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
