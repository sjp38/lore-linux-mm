Date: Sun, 22 Jun 2008 10:35:50 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix race in COW logic
In-Reply-To: <Pine.LNX.4.64.0806221742330.31172@blonde.site>
Message-ID: <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
References: <20080622153035.GA31114@wotan.suse.de> <Pine.LNX.4.64.0806221742330.31172@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


On Sun, 22 Jun 2008, Hugh Dickins wrote:
> 
> You have a wicked mind, and I think you're right, and the fix right.

Agreed. I think the patch is fine, although I'd personally probably like 
it even more if the mm counter updates to follow the rmap updates.

> One thing though, in moving the page_remove_rmap in that way, aren't
> you assuming that there's an appropriate wmbarrier between the two
> locations?  If that is necessarily so (there's plenty happening in
> between), it may deserve a comment to say just where that barrier is.

In this case, I don't think memory ordering matters.

What matters is that the map count never goes down to one - and by 
re-ordering the inc/dec accesses, that simply won't happen. IOW, memory 
ordering is immaterial, only the ordering of count updates (from the 
standpoint of the faulting CPU - so that's not even an SMP issue) matters.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
