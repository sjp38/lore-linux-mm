Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BFA7B6B0088
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 12:46:33 -0500 (EST)
Date: Tue, 14 Dec 2010 18:46:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Deadlocks with transparent huge pages and userspace fs daemons
Message-ID: <20101214174626.GN5638@random.random>
References: <1288817005.4235.11393.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288817005.4235.11393.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Lin Feng Shen <shenlinf@cn.ibm.com>, Yuri L Volobuev <volobuev@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, dingc@cn.ibm.com, lnxninja <lnxninja@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello Dave and everyone,

On Wed, Nov 03, 2010 at 01:43:25PM -0700, Dave Hansen wrote:
> Hey Miklos,
> 
> When testing with a transparent huge page kernel:
> 
> 	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/andrea/aa.git;a=summary
> 
> some IBM testers ran into some deadlocks.  It appears that the
> khugepaged process is trying to migrate one of a filesystem daemon's
> pages while khugepaged holds the daemon's mmap_sem for write.

The allocation under mmap_sem write mode in khugepaged bug should be
fixed in current aa.git based on 37-rc5:

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=83e4d55d0014b3eeb982005d73f55ffcf2813504

Let me know how it goes, it's not very well tested yet (which is why I
didn't make a new submit yet).

I stick to my idea this is bug in userland and may trigger if your
daemon does mmap/munmap and the vma allocation under mmap_sem waits
for the I/O, but I don't want to show it with THP enabled, and this is
more scalable so it's definitely good idea and no downside whatsoever.

Thanks for the report,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
