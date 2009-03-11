Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 205C16B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 16:36:28 -0400 (EDT)
Date: Wed, 11 Mar 2009 13:33:17 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random>
 <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain> <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Linus Torvalds wrote:
> 
> Agreed. However, I really think this is a O_DIRECT problem. Just document 
> it. Tell people that O_DIRECT simply doesn't work with COW, and 
> fundamentally can never work well.
> 
> If you use O_DIRECT with threading, you had better know what the hell 
> you're doing anyway. I do not think that the kernel should do stupid 
> things just because stupid users don't understand the semantics of the 
> _non-stupid_ thing (which is to just let people think about COW for five 
> seconds).

Btw, if we don't do that, then there are better alternatives. One is:

 - fork already always takes the write lock on mmap_sem (and f*ck no, I 
   doubt anybody will ever care one whit how "parallel" you can do forks 
   from threads, so I don't think this is an issue)

 - Just make the rule be that people who use get_user_pages() always 
   have to have the read-lock on mmap_sem until they've used the pages.

We already take the read-lock for the lookup (well, not for the gup, but 
for all the slow cases), but I'm saying that we could go one step further 
- just read-lock over the _whole_ O_DIRECT read or write. That way you 
literally protect against concurrent fork()s.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
