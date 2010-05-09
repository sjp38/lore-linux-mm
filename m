Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 93C686200BD
	for <linux-mm@kvack.org>; Sun,  9 May 2010 16:09:06 -0400 (EDT)
Date: Sun, 9 May 2010 13:06:30 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
 rmap_walk by guaranteeing rmap_walk finds PTEs created within the temporary
 stack
In-Reply-To: <alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1005091257110.3711@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-3-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org> <20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org> <20100509192145.GI4859@csn.ul.ie> <alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>



On Sun, 9 May 2010, Linus Torvalds wrote:
> 
> IOW, a patch like this (this is a pseudo-patch, totally untested, won't 
> compile, yadda yadda - you need to actually make the people who call 
> "move_page_tables()" call that prepare function first etc etc)

Btw, that pseudo-patch is also likely the least efficient way to do this, 
since it re-walks the page directories for each pmd it creates.

Also - the thing is, we can easily choose to do this _just_ for the case 
of shifting argument pages, which really is a special case (the generic 
case of "mremap()" is a lot more complicated, and doesn't have the issue 
with rmap because it's doing all the "new vma" setup etc).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
