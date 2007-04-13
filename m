From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070413162909.c436a732.dada1@cosmosbay.com> 
References: <20070413162909.c436a732.dada1@cosmosbay.com>  <20070413124303.GD966@wotan.suse.de> <20070413100416.GC31487@wotan.suse.de> <25821.1176466182@redhat.com> <30644.1176471112@redhat.com> 
Subject: Re: [patch] generic rwsems 
Date: Fri, 13 Apr 2007 15:49:06 +0100
Message-ID: <31965.1176475746@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:

> If space considerations are that important, we could then reserve one bit
> for the 'wait_lock spinlock'

That makes life quite a bit more tricky, though it does have the advantage
that it closes the reader-jumping-writer window I mentioned.

> Another possibility to save space would be to move wait_lock/wait_list
> outside of rw_semaphore, in a hashed global array.

I suspect moving wait_list out would be a bad idea.  The ordering of things in
the list is very important.  You need to perform several operations on the
list, all of which would be potentially slower:

 (1) glance at the first element of the list to see what sort of wake up to do

 (2) iteration of the list when waking up multiple readers

 (3) seeing if the list is empty (so you know that there's no more contention)

Moving the spinlock out, on the other hand, might be worth it to cut down on
cacheline bouncing some more...

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
