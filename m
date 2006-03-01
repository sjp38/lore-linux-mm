Date: Wed, 1 Mar 2006 14:12:20 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/1] shrink dentry cache before inode cache
Message-Id: <20060301141220.7728795f.akpm@osdl.org>
In-Reply-To: <20060301170712.GA18066@sgi.com>
References: <20060301170712.GA18066@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Cliff Wickman <cpw@sgi.com> wrote:
>
> The shrink_slab() function must often be called twice to get significant
> slab cache reduction.
> 
> shrink_slab() walks the shrinker_list to call functions that can
> release kernel slab memory.
> 
> The shrinker_list is walked head to tail and, as it is now, comes across the
> inode cache shrinker first.  This releases inodes found on the inode_unused 
> list.  Afterwards the dentry cache shrinker moves many freeable inodes to 
> the list.  But those inodes are not freed until a second invocation of 
> shrink_slab().
> 
> The dentry cache shrinker (shrink_dcache_memory()) should run before 
> the inode cache shrinker (shrink_icache_memory()).
> 
> This can be accomplished by queuing the dentry cache shrinker earlier -
> simply calling inode_init() before dcache_init().

Is logical, although the implementation is fragile.  This came up a year or
so ago and we decided it wouldn't make any difference - iirc because slab
shrinking tends to occur in little bites across the whole list.

Do you have any measurements or instrumentation which show improvement?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
