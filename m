Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C26C96B01F2
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 20:17:47 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S0Hj4D022026
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 09:17:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E5B345DE4F
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:17:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1ECC845DE51
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:17:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 04AEC1DB8043
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:17:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A196F1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:17:44 +0900 (JST)
Date: Wed, 28 Apr 2010 09:13:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
Message-Id: <20100428091345.496ca4c4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100427223242.GG8860@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<alpine.DEB.2.00.1004271723090.24133@router.home>
	<20100427223242.GG8860@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 00:32:42 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Tue, Apr 27, 2010 at 05:27:36PM -0500, Christoph Lameter wrote:
> > Can we simply wait like in the fault path?
> 
> There is no bug there, no need to wait either. I already audited it
> before, and I didn't see any bug. Unless you can show a bug with CPU A
> running the rmap_walk on process1 before process2, there is no bug to
> fix there.
> 
I think there is no bug, either. But that safety is fragile.


> > 
> > > Patch 3 notes that while a VMA is moved under the anon_vma lock, the page
> > > 	tables are not similarly protected. Where migration PTEs are
> > > 	encountered, they are cleaned up.
> > 
> > This means they are copied / moved etc and "cleaned" up in a state when
> > the page was unlocked. Migration entries are not supposed to exist when
> > a page is not locked.
> 
> patch 3 is real, and the first thought I had was to lock down the page
> before running vma_adjust and unlock after move_page_tables. But these
> are virtual addresses. Maybe there's a simpler way to keep migration
> away while we run those two operations.
> 

Doing some check in move_ptes() after vma_adjust() is not safe.
IOW, when vma's information and information in page-table is incosistent...objrmap
is broken and migartion will cause panic.

Then...I think there are 2 ways.
  1. use seqcounter in "mm_struct" as previous patch and lock it at mremap.
or
  2. get_user_pages_fast() when do remap.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
