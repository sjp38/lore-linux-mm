Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE516007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:34:30 -0500 (EST)
Date: Tue, 5 Jan 2010 07:34:02 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <1262681834.2400.31.camel@laptop>
Message-ID: <alpine.LFD.2.00.1001050727400.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001041904250.3630@localhost.localdomain> <1262681834.2400.31.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Peter Zijlstra wrote:
> 
> If it were only unmount it would be rather easy to fix by putting that
> RCU synchronization in unmount, unmount does a lot of sync things
> anyway. But I suspect there's more cases where that non-busy matters
> (but I'd need to educate myself on filesystems/vfs to come up with any).

unmount may well be the only really huge piece.

The only other effects of delaying closing a file I can see are

 - the ETXTBUSY thing, but we don't need to delay _that_ part, so this may 
   be a non-issue.

 - the actual freeing of the data on disk (ie people may expect that the 
   last close really frees up the space on the filesystem). However, this 
   is _such_ a subtle semantic thing that maybe nobody cares.

It's perhaps worth noting that I think Nick's VFS scalability patches did 
at least _some_ of the "struct filp" freeing in RCU context too, so this 
whole "vfs delays things in RCU" is not a new thing.

But I think that in Nick's case it was stricly just the freeing of the 
inode/dentry data structure (because he needed to traverse the dentry list 
locklessly - he didn't then _use_ the results locklessly). So the actual 
filesystem operations didn't get deferred, and as a result it didn't have 
this particular semantic nightmare.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
