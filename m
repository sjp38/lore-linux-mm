Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A16B26B01E3
	for <linux-mm@kvack.org>; Sun, 25 Apr 2010 19:53:05 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3PNr2wU004218
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 26 Apr 2010 08:53:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id ADA0445DE52
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 08:53:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AF0445DE51
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 08:53:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 626251DB8043
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 08:53:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FF021DB803F
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 08:52:59 +0900 (JST)
Date: Mon, 26 Apr 2010 08:49:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-Id: <20100426084901.15c09a29.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100424104324.GD14351@csn.ul.ie>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423095922.GJ30306@csn.ul.ie>
	<20100423155801.GA14351@csn.ul.ie>
	<20100424110200.b491ec5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100424104324.GD14351@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 24 Apr 2010 11:43:24 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Sat, Apr 24, 2010 at 11:02:00AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Fri, 23 Apr 2010 16:58:01 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > > I had considered this idea as well as it is vaguely similar to how zones get
> > > > resized with a seqlock. I was hoping that the existing locking on anon_vma
> > > > would be usable by backing off until uncontended but maybe not so lets
> > > > check out this approach.
> > > > 
> > > 
> > > A possible combination of the two approaches is as follows. It uses the
> > > anon_vma lock mostly except where the anon_vma differs between the page
> > > and the VMAs being walked in which case it uses the seq counter. I've
> > > had it running a few hours now without problems but I'll leave it
> > > running at least 24 hours.
> > > 
> > ok, I'll try this, too.
> > 
> > 
> > > ==== CUT HERE ====
> > >  mm,migration: Prevent rmap_walk_[anon|ksm] seeing the wrong VMA information by protecting against vma_adjust with a combination of locks and seq counter
> > > 
> > > vma_adjust() is updating anon VMA information without any locks taken.
> > > In constract, file-backed mappings use the i_mmap_lock. This lack of
> > > locking can result in races with page migration. During rmap_walk(),
> > > vma_address() can return -EFAULT for an address that will soon be valid.
> > > This leaves a dangling migration PTE behind which can later cause a
> > > BUG_ON to trigger when the page is faulted in.
> > > 
> > > With the recent anon_vma changes, there is no single anon_vma->lock that
> > > can be taken that is safe for rmap_walk() to guard against changes by
> > > vma_adjust(). Instead, a lock can be taken on one VMA while changes
> > > happen to another.
> > > 
> > > What this patch does is protect against updates with a combination of
> > > locks and seq counters. First, the vma->anon_vma lock is taken by
> > > vma_adjust() and the sequence counter starts. The lock is released and
> > > the sequence ended when the VMA updates are complete.
> > > 
> > > The lock serialses rmap_walk_anon when the page and VMA share the same
> > > anon_vma. Where the anon_vmas do not match, the seq counter is checked.
> > > If a change is noticed, rmap_walk_anon drops its locks and starts again
> > > from scratch as the VMA list may have changed. The dangling migration
> > > PTE bug was not triggered after several hours of stress testing with
> > > this patch applied.
> > > 
> > > [kamezawa.hiroyu@jp.fujitsu.com: Use of a seq counter]
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > I think this patch is nice!
> > 
> 
> It looks nice but it still broke after 28 hours of running. The
> seq-counter is still insufficient to catch all changes that are made to
> the list. I'm beginning to wonder if a) this really can be fully safely
> locked with the anon_vma changes and b) if it has to be a spinlock to
> catch the majority of cases but still a lazy cleanup if there happens to
> be a race. It's unsatisfactory and I'm expecting I'll either have some
> insight to the new anon_vma changes that allow it to be locked or Rik
> knows how to restore the original behaviour which as Andrea pointed out
> was safe.
> 
Ouch. Hmm, how about the race in fork() I pointed out ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
