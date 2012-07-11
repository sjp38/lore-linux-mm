Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9E8296B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 14:16:36 -0400 (EDT)
Received: by ggm4 with SMTP id 4so1826312ggm.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 11:16:35 -0700 (PDT)
Date: Wed, 11 Jul 2012 11:15:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] shmem: fix negative rss in memcg memory.stat
In-Reply-To: <20120710124107.GE1779@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1207111048410.1797@eggly.anvils>
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils> <alpine.LSU.2.00.1207091541310.2051@eggly.anvils> <20120710124107.GE1779@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 10 Jul 2012, Johannes Weiner wrote:
> 
> I couldn't see anything wrong with shmem_replace_page(), either, but
> maybe the comment in its error path could be updated as the callsite
> does not rely on page_private alone anymore to confirm correct swap.

I went in to make an incremental fix to update that comment as you
suggest, but found that actually the comment should stay as is.

We're dealing with two different radix trees here: shmem_confirm_swap()
and shmem_add_to_page_cache() are operating on the tmpfs file radix tree,
but shmem_replace_page() is using shmem_radix_tree_replace() to operate
on the "swapper_space" radix tree, exchanging the page pointer there.

The preliminary page_private test (under page lock) should indeed be
guaranteeing that the page pointer found in the swapper_space radix
tree at that (swp_entry_t) offset is the one we expect there, as before.

Whereas the new shmem_confirm_swap() test doesn't help to guarantee that
part at all: it's for confirming that the swap entry is still being used
for the offset in the file that we're interested in.

The comment I would like to change is the "nice clean interface" one!
While it does make for a nice old-page-in/new-page-out interface to that
function, I've come to feel that it would be much better not to mess with
the swapcache at all there - leave the old page in the swapcache, and
remove it at the same time as inserting the new page into filecache.

But I'm also reluctant to mess with what's working: I'm in no rush
to change that around, I'd be sure to screw it up at first.

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
