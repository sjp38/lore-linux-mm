Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA31269
	for <linux-mm@kvack.org>; Sun, 9 May 1999 20:49:26 -0400
Date: Mon, 10 May 1999 02:57:54 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [PATCH] dirty pages in memory & co.
In-Reply-To: <m1pv4ddj3z.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.4.05.9905090427420.1025-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7 May 1999, Eric W. Biederman wrote:

>7) Removing the swap lock map, by modify ipc/shm to use the page cache
>   and vm_stores.

I just killed the swap lock map and I just use the swap cache for ipc shm
memory.

Now I was thinking at the reverse lookup from pagemap to pagetable that
you mentioned. It would be easy to that at least for the page/swap cache
mappings with the interface I added in my tree.

But to support dynamic relocation/defrag of memory on the whole VM we
should do that for _all_ pages. And to do the relocation we should run
with the GFP pages mapped in a separate pte (not in the 4mbyte page table
with the kernel). So I don't know if it would be better to just move all
kernel memory (the one available through GFP) to virtual memory and to
support the reverse lookup for all pages in the system, or if I should
only do the quite-easy backdoor for the page/swap cache. The point is that
supporting the reverse lookup for all kernel memory and having all kernel
memory in virtual memory, will be a _major_ performance hit for all
operations according to me.

Right now i would need the reverse lookup only for the mapped cache
because I would like to avoid to run swap_out to know if the pte is been
accessed or not and in the case it's an old pte I could unmap the
mmapped-page directly from shrink_mmap. But I am not convinced this will
be an improvement too because I just run swap_out at the right time...

Comments?

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
