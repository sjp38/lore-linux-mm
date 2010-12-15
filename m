Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 025746B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 00:24:56 -0500 (EST)
Date: Wed, 15 Dec 2010 06:24:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Deadlocks with transparent huge pages and userspace fs daemons
Message-ID: <20101215052450.GQ5638@random.random>
References: <1288817005.4235.11393.camel@nimitz>
 <20101214174626.GN5638@random.random>
 <E1PSc21-0004ob-M6@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1PSc21-0004ob-M6@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: dave@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shenlinf@cn.ibm.com, volobuev@us.ibm.com, mel@linux.vnet.ibm.com, dingc@cn.ibm.com, lnxninja@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hello Miklos and everyone,

On Tue, Dec 14, 2010 at 10:03:33PM +0100, Miklos Szeredi wrote:
> This is all fine and dandy, but please let's not forget about the
> other thing that Dave's test uncovered.  Namely that page migration
> triggered by transparent hugepages takes the page lock on arbitrary
> filesystems.  This is also deadlocky on fuse, but also not a good idea
> for any filesystem where page reading time is not bounded (think NFS
> with network down).

In #33 I fixed the mmap_sem write issue which is more clear to me and
it makes the code better.

The page lock I don't have full picture on it. Notably there is no
waiting on page lock on khugepaged and khugepaged can't use page
migration (it's not migrating, it's collapsing).

The page lock mentioned in migration context I don't see how can it be
related to THP. There's not a _single_ lock_page in mm/huge_memory.c .

If fuse has deadlock troubles in migration lock_page then I would
guess THP has nothing to do with it memory compaction, and it can
trigger already in upstream stable 2.6.36 when CONFIG_COMPACTION=y by
just doing:
	
	echo 1024 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

or by simply insmodding a driver that tries a large
alloc_pages(order).

My understanding of Dave's trace is that THP makes it easier to
reproduce, but this isn't really THP related, it can happen already
upstream without my patchset applied, and it's just a pure coincidence
that THP makes it more easy to reproduce. How to fix I'm not sure yet
as I didn't look into it closely as I was focusing on rolling a THP
specific update first, but at the moment it even sounds more like an
issue with strict migration than memory compaction.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
