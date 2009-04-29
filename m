Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CEAEE6B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 01:50:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3T5p9wn007121
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 29 Apr 2009 14:51:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6617A45DE51
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 14:51:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D37145DE50
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 14:51:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BBFB1DB8042
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 14:51:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DA8E81DB803A
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 14:51:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
In-Reply-To: <20090428120818.GH22104@mit.edu>
References: <20090428090916.GC17038@localhost> <20090428120818.GH22104@mit.edu>
Message-Id: <20090429130430.4B11.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 29 Apr 2009 14:51:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> On Tue, Apr 28, 2009 at 05:09:16PM +0800, Wu Fengguang wrote:
> > The semi-drop-behind is a great idea for the desktop - to put just
> > accessed pages to end of LRU. However I'm still afraid it vastly
> > changes the caching behavior and wont work well as expected in server
> > workloads - shall we verify this?
> > 
> > Back to this big-cp-hurts-responsibility issue. Background write
> > requests can easily pass the io scheduler's obstacles and fill up
> > the disk queue. Now every read request will have to wait 10+ writes
> > - leading to 10x slow down of major page faults.
> > 
> > I reach this conclusion based on recent CFQ code reviews. Will bring up
> > a queue depth limiting patch for more exercises..
> 
> We can muck with the I/O scheduler, but another thing to consider is
> whether the VM should be more aggressively throttling writes in this
> case; it sounds like the big cp in this case may be dirtying pages so
> aggressively that it's driving other (more useful) pages out of the
> page cache --- if the target disk is slower than the source disk (for
> example, backing up a SATA primary disk to a USB-attached backup disk)
> no amount of drop-behind is going to help the situation.
> 
> So that leaves three areas for exploration:
> 
> * Write-throttling
> * Drop-behind
> * background writes pushing aside foreground reads
> 
> Hmm, note that although the original bug reporter is running Ubuntu
> Jaunty, and hence 2.6.28, this problem is going to get *worse* with
> 2.6.30, since we have the ext3 data=ordered latency fixes which will
> write out the any journal activity, and worse, any synchornous commits
> (i.e., caused by fsync) will force out all of the dirty pages with
> WRITE_SYNC priority.  So with a heavy load, I suspect this is going to
> be more of a VM issue, and especially figuring out how to tune more
> aggressive write-throttling may be key here.

firstly, I'd like to report my reproduce test result.

test environment: no lvm, copy ext3 to ext3 (not mv), no change swappiness, 
                  CFQ is used, userland is Fedora10, mmotm(2.6.30-rc1 + mm patch),
                  CPU opteronx4, mem 4G

mouse move lag:               not happend
window move lag:              not happend
Mapped page decrease rapidly: not happend (I guess, these page stay in 
                                          active list on my system)
page fault large latency:     happend (latencytop display >200ms)


Then, I don't doubt vm replacement logic now.
but I need more investigate.
I plan to try following thing today and tommorow.

 - XFS
 - LVM
 - another io scheduler (thanks Ted, good view point)
 - Rik's new patch




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
