Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F41A6B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 23:24:32 -0400 (EDT)
Date: Sat, 2 May 2009 23:24:03 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-ID: <20090502232403.3ca10b97@riellaptop.surriel.com>
In-Reply-To: <20090503031539.GC5702@localhost>
References: <1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<20090430072057.GA4663@eskimo.com>
	<20090430174536.d0f438dd.akpm@linux-foundation.org>
	<20090430205936.0f8b29fc@riellaptop.surriel.com>
	<20090430181340.6f07421d.akpm@linux-foundation.org>
	<20090430215034.4748e615@riellaptop.surriel.com>
	<20090430195439.e02edc26.akpm@linux-foundation.org>
	<49FB01C1.6050204@redhat.com>
	<20090501123541.7983a8ae.akpm@linux-foundation.org>
	<20090503031539.GC5702@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 May 2009 11:15:39 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Commit 7e9cd484204f(vmscan: fix pagecache reclaim referenced bit
> check) tries to address scalability problem when every page get
> mapped and referenced, so that logic(which lowed the priority of
> mapped pages) could be enabled only on conditions like (priority <
> DEF_PRIORITY).
> 
> Or preferably we can explicitly protect the mapped executables,
> as illustrated by this patch (a quick prototype).

Over time, given enough streaming IO and idle applications,
executables will still be evicted with just this patch.

However, a combination of your patch and mine might do the
trick.  I suspect that executables are never a very big
part of memory, except on small memory systems, so protecting
just the mapped executables should not be a scalability
problem.

My patch in combination with your patch should make sure
that if something gets evicted from the active list, it's
not executables - meanwhile, lots of the time streaming
IO will completely leave the active file list alone.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
