Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA01133
	for <linux-mm@kvack.org>; Fri, 7 May 1999 10:53:02 -0400
Subject: [PATCH] dirty pages in memory & co.
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 07 May 1999 09:56:00 -0500
Message-ID: <m1pv4ddj3z.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

O.k.  I've dug through all of my obvious bugs and I a working set of
kernel patches.
Currently they are against 2.2.5.
Location:
http://ebiederm/files/patches9.tar.gz

I consider this set of patches alpha (as I haven't had a chance to
stress test it yet).  But if you want to see the direction I'm going
it's a good thing to look at.

Documentaion, porting shmfs,  and stress testing are still to come.

The patches included are:
eb1 -- Allow reuse of page->buffers if you aren't the buffer cache
eb2 -- Allow old old a.out binaries to run even if we can't mmap them
       properly because their data isn't page aligned.
eb3 -- Much with page offset.
eb4 -- Allow registration and unregistration for functions needed by
       swap off.
eb5 -- Large file support, basically this removes unused bits from all
       of the relevant interfaces.
eb6 -- Introduction of struct vm_store, and associated cleanups.
       In particular get_inode_page.
eb7 -- Actuall patch for dirty buffers in the page cache.
       I'm fairly well satisfied except for generic_file_write.
       It looks like I need 2 variations on generic_file_write at the
       moment. 
       1) for network filesystems that can get away without filling
          the page on a partial write.
       2) for block based filesystems that must fill the page on a
          partial write because they can't write arbitrary chunks of
          data.

TODO:
1) document the new interfaces
2) porting shmfs
3) stress testing.
4) Experimenting with heuristics so that programs that are writing
   data faster than the disk can handle are put to sleep (think
   floppies).
5) Playing with mapped memory, and removing the need for kpiod.
   This will either require either reverse page tables, or 
   something equally effecting at finding page mappings from a struct page.
6) Removing the need for struct vm_operations in the vm_area_struct.
   A struct vm_store can probably handle everything.
7) Removing the swap lock map, by modify ipc/shm to use the page cache
   and vm_stores.

I'm going to visit my parents this weekend so I don't expect to get
much farther for a while. 

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
