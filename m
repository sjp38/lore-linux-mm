Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AF84E6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 16:03:53 -0500 (EST)
In-reply-to: <20101214174626.GN5638@random.random> (message from Andrea
	Arcangeli on Tue, 14 Dec 2010 18:46:26 +0100)
Subject: Re: Deadlocks with transparent huge pages and userspace fs daemons
References: <1288817005.4235.11393.camel@nimitz> <20101214174626.GN5638@random.random>
Message-Id: <E1PSc21-0004ob-M6@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 14 Dec 2010 22:03:33 +0100
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: dave@linux.vnet.ibm.com, miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shenlinf@cn.ibm.com, volobuev@us.ibm.com, mel@linux.vnet.ibm.com, dingc@cn.ibm.com, lnxninja@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010, Andrea Arcangeli wrote:
> Hello Dave and everyone,
> 
> On Wed, Nov 03, 2010 at 01:43:25PM -0700, Dave Hansen wrote:
> > Hey Miklos,
> > 
> > When testing with a transparent huge page kernel:
> > 
> > 	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/andrea/aa.git;a=summary
> > 
> > some IBM testers ran into some deadlocks.  It appears that the
> > khugepaged process is trying to migrate one of a filesystem daemon's
> > pages while khugepaged holds the daemon's mmap_sem for write.
> 
> The allocation under mmap_sem write mode in khugepaged bug should be
> fixed in current aa.git based on 37-rc5:
> 
> http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog
> http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=83e4d55d0014b3eeb982005d73f55ffcf2813504
> 
> Let me know how it goes, it's not very well tested yet (which is why I
> didn't make a new submit yet).
> 
> I stick to my idea this is bug in userland and may trigger if your
> daemon does mmap/munmap and the vma allocation under mmap_sem waits
> for the I/O, but I don't want to show it with THP enabled, and this is
> more scalable so it's definitely good idea and no downside whatsoever.

This is all fine and dandy, but please let's not forget about the
other thing that Dave's test uncovered.  Namely that page migration
triggered by transparent hugepages takes the page lock on arbitrary
filesystems.  This is also deadlocky on fuse, but also not a good idea
for any filesystem where page reading time is not bounded (think NFS
with network down).

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
