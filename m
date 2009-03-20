Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B63D6B0055
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:09:56 -0400 (EDT)
Subject: Re: [PATCH 0/2] Make the Unevictable LRU available on NOMMU
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <28c262360903131727l4ef41db5xf917c7c5eb4825a8@mail.gmail.com>
References: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
	 <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
	 <28c262360903131727l4ef41db5xf917c7c5eb4825a8@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 20 Mar 2009 12:08:25 -0400
Message-Id: <1237565305.27431.48.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

On Sat, 2009-03-14 at 09:27 +0900, Minchan Kim wrote:
> Hi, David.
> 
> It seems your patch is better than mine.  Thanks. :)
> But my concern is that as Peter pointed out, unevictable lru's
> solution is not fundamental one.
> 
> He want to remove ramfs page from lru list to begin with.
> I guess Andrew also thought same thing with Peter.
> 
> I think it's a fundamental solution. but it may be long term solution.
> This patch can solve NOMMU problem in current status.
> 
> Andrew, What do you think about it ?

[been meaning to respond to this...]

I just want to point out [again :)] that removing the ramfs pages from
the lru will prevent them from being migrated--e.g., for mem hot unplug,
defrag or such.  We currently have this situation with the new ram disk
driver [brd.c] which, unlike the old rd driver, doesn't place its pages
on the LRU.

Migration uses isolation of pages from lru to arbitrate between tasks
trying to migrate or reclaim the same page.  If migration doesn't find
the page on the lru, it assumes that it lost the race and skips the
page.  This is one of the reasons we chose to keep unevictable pages on
an lru-like list known to isolate_lru_page().

Something to keep in mind if/when this comes up again.  Maybe we don't
care?  Maybe ram disk/fs pages should come only from non-movable zone?
Or maybe migration can be reworked not to require the page be
"isolatable" from the lru [haven't thought about how one might do this].

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
