Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA00650
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 07:58:02 -0500
Date: Thu, 26 Nov 1998 12:57:37 GMT
Message-Id: <199811261257.MAA16715@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Linux-2.1.129..
In-Reply-To: <m1u2znbhwj.fsf@flinx.ccr.net>
References: <199811241525.PAA00862@dax.scot.redhat.com>
	<Pine.LNX.3.95.981124092641.10767A-100000@penguin.transmeta.com>
	<199811251419.OAA00990@dax.scot.redhat.com>
	<m1u2znbhwj.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Benjamin LaHaise <bcrlahai@calum.csclub.uwaterloo.ca>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 25 Nov 1998 15:07:39 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

> What do you consider a proper PG_dirty fix?

One which allows us to have dirty pages in the page cache without
worrying about who dirtied them.  In the first instance, we at least
need to allow the swap cache to hold dirty pages and allow
mmap(MAP_SHARED) to synchronise dirty page writeback between processes
(so that we don't get multiple accessors writing back the same page).  A
proper solution obviously requires a way to propogate a write to disk
back to all of the dirty bits in any ptes which reference the page,
which is next to impossible to do efficiently in the current VM (at
least for anonymous pages).

The right 2.2 fix is probably just to go with the existing patch which
propogates dirty bits at msync() time: that doesn't have to deal with
anonymous pages at all.

> But as far as MAP_SHARED | MAP_ANONYMOUS to retain our current
> swapping model (of never rewriting a swap page), and for swapoff
> support we need the ability to change which swap page all of the pages
> are associated with.

> There are 2 ways to do this.  
> 1) Implement it like SYSV shared mem.
> 2) Just maintain vma structs for the memory, with vma_next_share used!
>    Then when we allocate a new swap page we can walk the
>    *vm_area_struct's to find the page_tables that need to be updated.

Ben LaHaise and I discussed this extensively a while ago, and Ben has a
really nice solution to the problem of finding all ptes for a given
page.  I still think it's a 2.3 thing, but it should definitely be
possible.

>   The question right now is where do we anchor the vma_next_share
>   linked list, as we don't have an inode.

We have the swapper inode, but that alone is not good enough.

A vma for a file mapped MAP_PRIVATE needs to be on the inode vma list
for that file.  Any anonymous private pages created for that file need
to be kept in the swap cache, which has its own inode.  After fork, we
need to keep the COW pages shared (even over swap) and the clean pages
linked to the page cache.  As a result, we need to support one vma
holding pages both on the inode vma list _and_ the swap inode.  Ben's
solution deals very cleanly with this.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
