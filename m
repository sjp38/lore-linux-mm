Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 09BE66B0118
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 13:15:27 -0400 (EDT)
Date: Mon, 27 Jun 2011 20:18:42 +0300
From: Kornilios Kourtis <kkourt@cslab.ece.ntua.gr>
Subject: Re: [BUG] Invalid return address of mmap() followed by mbind() in
 multithreaded context
Message-ID: <20110627171842.GA7554@solar.cslab.ece.ntua.gr>
References: <4DFB710D.7000902@cslab.ece.ntua.gr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DFB710D.7000902@cslab.ece.ntua.gr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasileios Karakasis <bkk@cslab.ece.ntua.gr>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org


Hi,

On Fri, Jun 17, 2011 at 06:21:49PM +0300, Vasileios Karakasis wrote:
> Hi,
> 
> I am implementing a multithreaded numa aware code where each thread
> mmap()'s an anonymous private region and then mbind()'s it to its local
> node. The threads are performing a series of such mmap() + mbind()
> operations. My program crashed with SIGSEGV and I noticed that mmap()
> returned an invalid address.

I've taken a closer look at this issue.

As Vasileios said, it can be reproduced by having two threads doing the
following loop:
| for {
| 	addr = mmap(4096, MAP_ANONUMOUS)
| 	if (addr == (void *)-1)
| 		continue
| 	mbind(addr, 4096, 0x1) // do mbind on first NUMA node
| }
After a couple of iterations, mbind() will return EFAULT, although the addr is
valid.

Doing a bisect, pins it down to the following commit (Author added to To:):
	9d8cebd4bcd7c3878462fdfda34bbcdeb4df7ef4
	mm: fix mbind vma merge problem
Which adds merging of vmas in the mbind() path.
Reverting this commit, seems to fix the issue.

I 've added some printks to track down the issue, and EFAULT is returned on:
mm/mempolicy.c: mbind_range()
|   vma = find_vma_prev(mm. start, &prev);
|   if (!vma |vma->vm_start > start)
|       return EFAULT;
Where: vma->start > start

I am not sure what exactly happens, but concurrent merges and splits
of (already mapped) VMAs do not seem to work well together.

cheers,
-Kornilios

-- 
Kornilios Kourtis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
