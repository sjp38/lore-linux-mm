Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 02CA76B0216
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 22:06:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3O266kP014763
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 24 Apr 2010 11:06:07 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A5D6445DE54
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:06:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 73D0F45DE53
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:06:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 57AB21DB8038
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:06:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 12BCF1DB803C
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:06:06 +0900 (JST)
Date: Sat, 24 Apr 2010 11:02:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-Id: <20100424110200.b491ec5f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100423155801.GA14351@csn.ul.ie>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423095922.GJ30306@csn.ul.ie>
	<20100423155801.GA14351@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 16:58:01 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> > I had considered this idea as well as it is vaguely similar to how zones get
> > resized with a seqlock. I was hoping that the existing locking on anon_vma
> > would be usable by backing off until uncontended but maybe not so lets
> > check out this approach.
> > 
> 
> A possible combination of the two approaches is as follows. It uses the
> anon_vma lock mostly except where the anon_vma differs between the page
> and the VMAs being walked in which case it uses the seq counter. I've
> had it running a few hours now without problems but I'll leave it
> running at least 24 hours.
> 
ok, I'll try this, too.


> ==== CUT HERE ====
>  mm,migration: Prevent rmap_walk_[anon|ksm] seeing the wrong VMA information by protecting against vma_adjust with a combination of locks and seq counter
> 
> vma_adjust() is updating anon VMA information without any locks taken.
> In constract, file-backed mappings use the i_mmap_lock. This lack of
> locking can result in races with page migration. During rmap_walk(),
> vma_address() can return -EFAULT for an address that will soon be valid.
> This leaves a dangling migration PTE behind which can later cause a
> BUG_ON to trigger when the page is faulted in.
> 
> With the recent anon_vma changes, there is no single anon_vma->lock that
> can be taken that is safe for rmap_walk() to guard against changes by
> vma_adjust(). Instead, a lock can be taken on one VMA while changes
> happen to another.
> 
> What this patch does is protect against updates with a combination of
> locks and seq counters. First, the vma->anon_vma lock is taken by
> vma_adjust() and the sequence counter starts. The lock is released and
> the sequence ended when the VMA updates are complete.
> 
> The lock serialses rmap_walk_anon when the page and VMA share the same
> anon_vma. Where the anon_vmas do not match, the seq counter is checked.
> If a change is noticed, rmap_walk_anon drops its locks and starts again
> from scratch as the VMA list may have changed. The dangling migration
> PTE bug was not triggered after several hours of stress testing with
> this patch applied.
> 
> [kamezawa.hiroyu@jp.fujitsu.com: Use of a seq counter]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I think this patch is nice!

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
