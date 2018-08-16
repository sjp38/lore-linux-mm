Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3C16B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:48:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y18-v6so2142275wma.9
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 00:48:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g204-v6sor101653wmf.35.2018.08.16.00.48.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 00:48:15 -0700 (PDT)
Date: Thu, 16 Aug 2018 09:48:13 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 3/4] mm/memory_hotplug: Refactor
 unregister_mem_sect_under_nodes
Message-ID: <20180816074813.GA16221@techadventures.net>
References: <20180815144219.6014-1-osalvador@techadventures.net>
 <20180815144219.6014-4-osalvador@techadventures.net>
 <20180815150121.7ec35ddabf18aea88d84437f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815150121.7ec35ddabf18aea88d84437f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 15, 2018 at 03:01:21PM -0700, Andrew Morton wrote:
> Oh boy, lots of things.
> 
> That small GFP_KERNEL allocation will basically never fail.  In the
> exceedingly-rare-basically-never-happens case, simply bailing out of
> unregister_mem_sect_under_nodes() seems acceptable.  But I guess that
> addressing it is a reasonable thing to do, if it can be done sanely.

Yes, I think this can be fixed as the patch showed.
Currently, if we bail out, we will have dangled symlinks, but we do not
really need to bail out, as we can proceed anyway.

> But given that your new unregister_mem_sect_under_nodes() can proceed
> happily even if the allocation failed, what's the point in allocating
> the nodemask at all?  Why not just go ahead and run sysfs_remove_link()
> against possibly-absent sysfs objects every time?  That produces
> simpler code and avoids having this basically-never-executed-or-tested
> code path in there.

Unless I am mistaken, the whole point to allocate a nodemask_t there is to
try to perform as less operations as possible.
If we already unlinked a link, let us not call syfs_remove_link again,
although doing it more than once on the same node is not harmful.
I will have a small impact in performance though, as we will repeat
operations.

Of course we can get rid of the nodemask_t and just call syfs_remove_link,
but I wonder if that is a bit suboptimal.

> Incidentally, do we have locking in place to prevent
> unregister_mem_sect_under_nodes() from accidentally removing sysfs
> nodes which were added 2 nanoseconds ago by a concurrent thread?

Well, remove_memory() and  add_memory_resource() is being serialized with
mem_hotplug_begin()/mem_hotplug_done().

Since registering node's on mem_blk's is done in add_memory_resource(),
and unregistering them it is done in remove_memory() patch, I think they
cannot step on each other's feet.

Although, I saw that remove_memory_section() takes mem_sysfs_mutex.
I wonder if we should do the same in link_mem_sections(), just to be on the
safe side.

> Also, this stuff in nodemask.h:
> 
> : /*
> :  * For nodemask scrach area.
> :  * NODEMASK_ALLOC(type, name) allocates an object with a specified type and
> :  * name.
> :  */
> : #if NODES_SHIFT > 8 /* nodemask_t > 256 bytes */
> : #define NODEMASK_ALLOC(type, name, gfp_flags)	\
> :			type *name = kmalloc(sizeof(*name), gfp_flags)
> : #define NODEMASK_FREE(m)			kfree(m)
> : #else
> : #define NODEMASK_ALLOC(type, name, gfp_flags)	type _##name, *name = &_##name
> : #define NODEMASK_FREE(m)			do {} while (0)
> : #endif
> 
> a) s/scrach/scratch/
> 
> b) The comment is wrong, isn't it?  "NODES_SHIFT > 8" means
>    "nodemask_t > 32 bytes"?

It is wrong yes.
For example, if NODES_SHIFT = 9, that makes 64 bytes.

> c) If "yes" then we can surely bump that up a bit - "NODES_SHIFT >
>    11", say.

I checked all architectures that define NODES_SHIFT in Kconfig.
The maximum we can get is NODES_SHIFT = 10, and this makes 128 bytes.

> d) What's the maximum number of nodes, ever?  Perhaps we can always
>    fit a nodemask_t onto the stack, dunno.

Right now, we define the maximum as NODES_SHIFT = 10, so:

1 << 10 = 1024 Maximum nodes.

Since this makes only 128 bytes, I wonder if we can just go ahead and define a nodemask_t
whithin the stack.
128 bytes is not that much, is it?

Thanks
-- 
Oscar Salvador
SUSE L3
