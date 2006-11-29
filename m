Message-ID: <456D23A0.9020008@yahoo.com.au>
Date: Wed, 29 Nov 2006 17:07:28 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
References: <20061129030655.941148000@menage.corp.google.com> <20061129033826.268090000@menage.corp.google.com>
In-Reply-To: <20061129033826.268090000@menage.corp.google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

menage@google.com wrote:
> Currently the page migration APIs allow you to migrate pages from
> particular processes, but don't provide a clean and efficient way to
> migrate and/or reclaim memory from individual nodes.

The mechanism for that should probably go in mm/migrate.c, shouldn't
it?

Also, why don't you scan the lru lists of the zones in the node, which
will a) be much more efficient if there are lots of non LRU pages, and
b) allow you to batch the lru lock.

> 
> This patch provides:
> 
> - an additional parameter to try_to_free_pages() to specify the
>   priority at which the reclaim should give up if it doesn't make
>   progress

Dang. It would be nice not to export this "priority" stuff outside
vmscan.c too much because it is really an implementation detail and
I would like to get rid of it one day...

> 
> - a way to trigger try_to_free_pages() for a given node with a given
>   minimum priority, vy writing an integer to
>   /sys/device/system/node/node<id>/try_to_free_pages

... especially not to userspace. Why does this have to be exposed to
userspace at all? Can you not wire it up to your resource isolation
implementation in the kernel?

> 
> - a way to request that any migratable pages on a given node be
>   migrated to availage pages on a specified set of nodes by writing a
>   destination nodemask (in ASCII form) to
>   /sys/device/system/node/node<id>/migrate_node

... yeah it would obviously be much nicer to do it in kernel space,
behind your higher level APIs. There's probably a good reason why you
aren't, and I haven't been following the lists very much over the
past couple of weeks... Can you describe your problems (or point me
to a post)?

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
