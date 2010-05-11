Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 758BC6B0234
	for <linux-mm@kvack.org>; Mon, 10 May 2010 20:14:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4B0EOmb013134
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 11 May 2010 09:14:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E5AC845DE55
	for <linux-mm@kvack.org>; Tue, 11 May 2010 09:14:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A2FC145DE5B
	for <linux-mm@kvack.org>; Tue, 11 May 2010 09:14:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 821851DB8013
	for <linux-mm@kvack.org>; Tue, 11 May 2010 09:14:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A17E1DB8019
	for <linux-mm@kvack.org>; Tue, 11 May 2010 09:14:23 +0900 (JST)
Date: Tue, 11 May 2010 09:10:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
Message-Id: <20100511091022.347785db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100510190559.GD22632@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
	<1272529930-29505-3-git-send-email-mel@csn.ul.ie>
	<alpine.DEB.2.00.1005012055010.2663@router.home>
	<20100504094522.GA20979@csn.ul.ie>
	<alpine.DEB.2.00.1005101239400.13652@router.home>
	<20100510190559.GD22632@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 10 May 2010 21:05:59 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Mon, May 10, 2010 at 12:41:07PM -0500, Christoph Lameter wrote:
> > A simple way to disallow migration of pages is to increment the refcount
> > of a page.
> 
> Ok for migrate but it won't prevent to crash in split_huge_page rmap
> walk, nor the PG_lock. Why for a rmap bug have a migrate specific fix?
> The fix that makes execve the only special place to handle in every
> rmap walk, is at least more maintainable than a fix that makes one of
> the rmap walk users special and won't fix the others, as there will be
> more than just 1 user that requires this. My fix didn't make execve
> special and it didn't require execve knowledge into the every rmap
> walk like migrate (split_huge_page etc...) but as long as the kernel
> doesn't crash I'm fine ;).
> 

At first, I like step-by-step approach even if it makes our cost double
because it's easy to understand and makes chasing change-log easy.

Ok, your split_huge_page() has some problems with current rmap+migration.
But I don't like a patch for never-happen-now bug in change-log.

I believe it can be fixed by the same approach for execs.
Renaming 
#define VM_STACK_INCOMPLETE_SETUP
to be
#define VM_TEMPORARY_INCONSITENT_RMAP
in _your_ patch series and add some check in rmap_walk() seems enough.

Of course, I may misunderstand your problem. Could you show your patch
which meets the problem with rmap+migration ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
