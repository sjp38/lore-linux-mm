Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E268A6B0007
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 18:01:24 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 2-v6so1393267plc.11
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 15:01:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v6-v6si20171402plo.264.2018.08.15.15.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 15:01:23 -0700 (PDT)
Date: Wed, 15 Aug 2018 15:01:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/4] mm/memory_hotplug: Refactor
 unregister_mem_sect_under_nodes
Message-Id: <20180815150121.7ec35ddabf18aea88d84437f@linux-foundation.org>
In-Reply-To: <20180815144219.6014-4-osalvador@techadventures.net>
References: <20180815144219.6014-1-osalvador@techadventures.net>
	<20180815144219.6014-4-osalvador@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, 15 Aug 2018 16:42:18 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:

> From: Oscar Salvador <osalvador@suse.de>
> 
> unregister_mem_sect_under_nodes() tries to allocate a nodemask_t
> in order to check whithin the loop which nodes have already been unlinked,
> so we do not repeat the operation on them.
> 
> NODEMASK_ALLOC calls kmalloc() if NODES_SHIFT > 8, otherwise
> it just declares a nodemask_t variable whithin the stack.
> 
> Since kamlloc() can fail, we actually check whether NODEMASK_ALLOC failed
> or not, and we return -ENOMEM accordingly.
> remove_memory_section() does not check for the return value though.
> 
> The problem with this is that if we return -ENOMEM, it means that
> unregister_mem_sect_under_nodes will not be able to remove the symlinks,
> but since we do not check the return value, we go ahead and we call
> unregister_memory(), which will remove all the mem_blks directories.
> 
> This will leave us with dangled symlinks.
> 
> The easiest way to overcome this is to fallback by calling
> sysfs_remove_link() unconditionally in case NODEMASK_ALLOC failed.
> This means that we will call sysfs_remove_link on nodes that have been
> already unlinked, but nothing wrong happens as sysfs_remove_link()
> backs off somewhere down the chain in case the link has already been
> removed.
> 
> I think that this is better than
> 
> a) dangled symlinks
> b) having to recovery from such error in remove_memory_section
> 
> Since from now on we will not need to care about return values, we can make
> the function void.
> 
> As we have a safe fallback, one thing that could also be done is to add
> __GFP_NORETRY in the flags when calling NODEMASK_ALLOC, so we do not retry.
> 

Oh boy, lots of things.

That small GFP_KERNEL allocation will basically never fail.  In the
exceedingly-rare-basically-never-happens case, simply bailing out of
unregister_mem_sect_under_nodes() seems acceptable.  But I guess that
addressing it is a reasonable thing to do, if it can be done sanely.

But given that your new unregister_mem_sect_under_nodes() can proceed
happily even if the allocation failed, what's the point in allocating
the nodemask at all?  Why not just go ahead and run sysfs_remove_link()
against possibly-absent sysfs objects every time?  That produces
simpler code and avoids having this basically-never-executed-or-tested
code path in there.

Incidentally, do we have locking in place to prevent
unregister_mem_sect_under_nodes() from accidentally removing sysfs
nodes which were added 2 nanoseconds ago by a concurrent thread?

Also, this stuff in nodemask.h:

: /*
:  * For nodemask scrach area.
:  * NODEMASK_ALLOC(type, name) allocates an object with a specified type and
:  * name.
:  */
: #if NODES_SHIFT > 8 /* nodemask_t > 256 bytes */
: #define NODEMASK_ALLOC(type, name, gfp_flags)	\
:			type *name = kmalloc(sizeof(*name), gfp_flags)
: #define NODEMASK_FREE(m)			kfree(m)
: #else
: #define NODEMASK_ALLOC(type, name, gfp_flags)	type _##name, *name = &_##name
: #define NODEMASK_FREE(m)			do {} while (0)
: #endif

a) s/scrach/scratch/

b) The comment is wrong, isn't it?  "NODES_SHIFT > 8" means
   "nodemask_t > 32 bytes"?

c) If "yes" then we can surely bump that up a bit - "NODES_SHIFT >
   11", say.

d) What's the maximum number of nodes, ever?  Perhaps we can always
   fit a nodemask_t onto the stack, dunno.
