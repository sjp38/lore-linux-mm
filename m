Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 067FC6B0123
	for <linux-mm@kvack.org>; Wed, 13 May 2009 15:00:05 -0400 (EDT)
Date: Wed, 13 May 2009 11:56:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX][PATCH] memcg: fix deadlock between lock_page_cgroup
 and mapping tree_lock
Message-Id: <20090513115626.57844f28.akpm@linux-foundation.org>
In-Reply-To: <20090513133031.f4be15a8.nishimura@mxp.nes.nec.co.jp>
References: <20090513133031.f4be15a8.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, balbir@in.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 13:30:31 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> mapping->tree_lock can be aquired from interrupt context.
> Then, following dead lock can occur.
> 
> Assume "A" as a page.
> 
>  CPU0:
>        lock_page_cgroup(A)
> 		interrupted
> 			-> take mapping->tree_lock.
>  CPU1:
>        take mapping->tree_lock
> 		-> lock_page_cgroup(A)

And we didn't find out about this because lock_page_cgroup() uses
bit_spin_lock(), and lockdep doesn't handle bit_spin_lock().

It would perhaps be useful if one of you guys were to add a spinlock to
struct page, convert lock_page_cgroup() to use that spinlock then run a
full set of tests under lockdep, see if it can shake out any other bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
