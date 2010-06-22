Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 361A36B0071
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 13:08:56 -0400 (EDT)
Date: Tue, 22 Jun 2010 10:08:16 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH V3 1/8] Cleancache: Documentation
Message-Id: <20100622100816.7d57f588.randy.dunlap@oracle.com>
In-Reply-To: <20100621231839.GA19454@ca-server1.us.oracle.com>
References: <20100621231839.GA19454@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010 16:18:39 -0700 Dan Magenheimer wrote:

> [PATCH V3 1/8] Cleancache: Documentation
> 
> Add cleancache documentation to Documentation/vm and
> sysfs ABI documentation to Documentation/ABI
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> Diffstat:
>  ABI/testing/sysfs-kernel-mm-cleancache   |   11 +
>  vm/cleancache.txt                        |  194 +++++++++++++++++++++
>  2 files changed, 205 insertions(+)


> --- linux-2.6.35-rc2/Documentation/vm/cleancache.txt	1969-12-31 17:00:00.000000000 -0700
> +++ linux-2.6.35-rc2-cleancache/Documentation/vm/cleancache.txt	2010-06-21 16:51:54.000000000 -0600
> @@ -0,0 +1,194 @@

> +A FAQ is included below:

   FAQs are included below.

> +
> +IMPLEMENTATION OVERVIEW

> +A "init_shared_fs", like init, obtains a pool id but tells cleancache

   An "init_shared_fs" call, like init_fs,

> +to treat the pool as shared using a 128-bit UUID as a key.  On systems
> +that may run multiple kernels (such as hard partitioned or virtualized
> +systems) that may share a clustered filesystem, and where cleancache
> +may be shared among those kernels, calls to init_shared_fs that specify the
> +same UUID will receive the same pool id, thus allowing the pages to
> +be shared.  Note that any security requirements must be imposed outside
> +of the kernel (e.g. by "tools" that control cleancache).  Or a
> +cleancache implementation can simply disable shared_init by always
> +returning a negative value.
> +
...

> +FAQ
> +
> +1) Where's the value? (Andrew Morton)
> +
> +Cleancache (and its sister code "frontswap") provide interfaces for
> +a new pseudo-RAM memory type that conceptually lies between fast
> +kernel-directly-addressable RAM and slower DMA/asynchronous devices.
> +Disallowing direct kernel or userland reads/writes to this pseudo-RAM
> +is ideal when data is transformed to a different form and size (such
> +as wiht compression) or secretly moved (as might be useful for write-

      with

> +balancing for some RAM-like devices).  Evicted page-cache pages (and
> +swap pages) are a great use for this kind of slower-than-RAM-but-much-
> +faster-than-disk pseudo-RAM and the cleancache (and frontswap)
> +"page-object-oriented" specification provides a nice way to read and
> +write -- and indirectly "name" -- the pages.
> +
...
> +
> +2) Why does cleancache have its sticky fingers so deep inside the
> +   filesystems and VFS? (Andrew Morton and Christophe Hellwig)
> +
> +The core hooks for cleancache in VFS are in most cases a single line
> +and the minimum set are placed precisely where needed to maintain
> +coherency (via cleancache_flush operatings) between cleancache,

                                   operations ?

> +the page cache, and disk.  All hooks compile into nothingness if
> +cleancache is config'ed off and turn into a function-pointer-
> +compare-to-NULL if config'ed on but no backend claims the ops
> +functions, or to a compare-struct-element-to-negative if a
> +backend claims the ops functions but a filesystem doesn't enable
> +cleancache.
> +
> +Some filesystems are built entirely on top of VFS and the hooks
> +in VFS are sufficient, so don't require a "init_fs" hook; the

                                           an

> +initial implementation of cleancache didn't provide this hook.
> +But for some filesystems (such as btrfs), the VFS hooks are
> +incomplete and one or more hooks in fs-specific code are required.
> +And for some other filesystems, such as tmpfs, cleancache may
> +be counterproductive.  So it seemed prudent to require a filesystem
> +to "opt in" to use cleancache, which requires adding a hook in
> +each filesystem.  Not all filesystems are supported by cleancache
> +only because they haven't been tested.  The existing set should
> +be sufficient to validate the concept, the opt-in approach means
> +that untested filesystems are not affected, and the hooks in the
> +existing filesystems should make it very easy to add more
> +filesystems in the future.
> +
> +3) Why not make cleancache asynchronous and batched so it can
> +   more easily interface with real devices with DMA instead
> +   of copying each individual page? (Minchan Kim)
> +
> +The one-page-at-a-time copy semantics simplifies the implementation
> +on both the frontend and backend and also allows the backend to
> +do fancy things on-the-fly like page compression and
> +page deduplication.  And since the data is "gone" (copied into/out
> +of the pageframe) before the cleancache get/put call returns,
> +a great deal of race conditions and potential coherency issues
> +are avoided.  While the interface seems odd for a "real device"
> +or for real kernel-addressible RAM, it makes perfect sense for

               kernel-addressable

> +pseudo-RAM.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
