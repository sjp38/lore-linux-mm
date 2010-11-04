Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F53C6B00B2
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 15:53:56 -0400 (EDT)
In-reply-to: <20101104164144.GI11602@random.random> (message from Andrea
	Arcangeli on Thu, 4 Nov 2010 17:41:44 +0100)
Subject: Re: Deadlocks with transparent huge pages and userspace fs daemons
References: <1288817005.4235.11393.camel@nimitz> <20101104164144.GI11602@random.random>
Message-Id: <E1PE5sG-0005Em-Qb@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 04 Nov 2010 20:53:28 +0100
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: dave@linux.vnet.ibm.com, miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shenlinf@cn.ibm.com, volobuev@us.ibm.com, mel@linux.vnet.ibm.com, dingc@cn.ibm.com, lnxninja@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 2010, Andrea Arcangeli wrote:
> On Wed, Nov 03, 2010 at 01:43:25PM -0700, Dave Hansen wrote:
> > some IBM testers ran into some deadlocks.  It appears that the
> > khugepaged process is trying to migrate one of a filesystem daemon's
> > pages while khugepaged holds the daemon's mmap_sem for write.
> 
> Correct. So now I'm wondering what happens if some library of this
> daemon happens to execute a munmap that calls split_vma and allocates
> memory while holding the mmap_sem, and the memory allocation triggers
> I/O that will have to be executed by the daemon.

mmap_sem is not really relevant here(*), page lock is.  And in vmscan.c,
there's not a single blocking lock_page().

Also, as I mentioned, fuse does writeback in a special way: it copies dirty
pages to non-page cache pages which don't interact in any way with
reclaim.  Fuse writeback is instantaneous from the reclaim PoV.

> I think this could be fixed in userland, this applies to openvpn too
> if used as nfs backend.

How?

Thanks,
Miklos

(*) In the original gpfs trace it is relevant but only because the
page migration is triggered by khugepaged.  In the reproduced example
the page migration is triggered directly by an allocation.  Since page
migration does blocking lock_page(), there's really no way to avoid a
deadlock in that case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
