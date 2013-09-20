Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 028F86B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 23:16:08 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so9224406pbb.28
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 20:16:08 -0700 (PDT)
From: Jonathan Brassow <jbrassow@redhat.com>
Subject: [PATCH] Problems with RAID 4/5/6 and kmem_cache
Date: Thu, 19 Sep 2013 22:15:59 -0500
Message-Id: <1379646960-12553-1-git-send-email-jbrassow@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-raid@vger.kernel.org
Cc: linux-mm@kvack.org, cl@linux.com, Jonathan Brassow <jbrassow@redhat.com>

I'm sending a patch that changes the name string used with
kmem_cache_create.  While I believe this is a bug in the kmem_cache
implementation, it doesn't hurt to work-around it in this simple way.

The problem with kmem_cache* is this:
*) Assume CONFIG_SLUB is set
1) kmem_cache_create(name="foo-a")
- creates new kmem_cache structure
2) kmem_cache_create(name="foo-b")
- If identical cache characteristics, it will be merged with the previously
  created cache associated with "foo-a".  The cache's refcount will be 
  incremented and an alias will be created via sysfs_slab_alias().
3) kmem_cache_destroy(<ptr>)
- Attempting to destroy cache associated with "foo-a", but instead the
  refcount is simply decremented.  I don't even think the sysfs aliases are
  ever removed...
4) kmem_cache_create(name="foo-a")               
- This FAILS because kmem_cache_sanity_check colides with the existing
  name ("foo-a") associated with the non-removed cache.

This is a problem for RAID (specifically dm-raid) because the name used
for the kmem_cache_create is ("raid%d-%p", level, mddev).  If the cache
persists for long enough, the memory address of an old mddev will be 
reused for a new mddev - causing an identical formulation of the cache
name.  Even though kmem_cache_destory had long ago been used to delete
the old cache, the merging of caches has cause the name and cache of that
old instance to be preserved and causes a colision (and thus failure) in
kmem_cache_create().  I see this regularly in my testing.

I haven't tried to reproduce this using MD-specific tools, but I would
think it would be even easier to reproduce there because of the cache
name being used.  (Perhaps create two similar RAID4/5/6 arrays.  Remove
the first one and then try to recreate the first one.  The cache should
stay and the re-use of the name should collide.)

There are a few ways I can think of to correct this bug in kmem_cache,
but none of them seem that clean.
1) force kmem_cache_destroy to be called with a name so that the
   proper alias can be removed (and the name of the cache possibly
   updated).
2) Change structures around so that we return something small from
   kmem_cache_create that contains a name and pointer to the mergable
   cache.  If new caches are mergable with existing ones, then we
   only have to create the small structure.  Having that pointer allows
   us to properly remove the reference and corresponding name when
   calling kmem_cache_destroy().
Perhaps there are cleaner options.  In the meantime, please accept my
MD RAID4/5/6 workaround patch.

thanks,
 brassow

Jonathan Brassow (1):
  RAID5: Change kmem_cache name string of RAID 4/5/6 stripe cache

 drivers/md/raid5.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
