Date: Fri, 18 May 2007 22:34:53 +0200 (MEST)
From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [patch 08/10] shmem: inode defragmentation support
In-Reply-To: <20070518181120.477184338@sgi.com>
Message-ID: <Pine.LNX.4.61.0705182233120.9015@yvahk01.tjqt.qr>
References: <20070518181040.465335396@sgi.com> <20070518181120.477184338@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On May 18 2007 11:10, clameter@sgi.com wrote:
>
>Index: slub/mm/shmem.c
>===================================================================
>--- slub.orig/mm/shmem.c	2007-05-18 00:54:30.000000000 -0700
>+++ slub/mm/shmem.c	2007-05-18 01:02:26.000000000 -0700

Do we need *this*? (compare procfs)

I believe that shmfs's inodes remain "more" in memory than those of
procfs. That is, procfs ones can find their way out (we can regenerate
it), while shmfs/tmpfs/ramfs/etc. should not do that (we'd lose the
file).

>@@ -2337,11 +2337,22 @@ static void init_once(void *foo, struct 
> #endif
> }
> 
>+static void *shmem_get_inodes(struct kmem_cache *s, int nr, void **v)
>+{
>+	return fs_get_inodes(s, nr, v,
>+			offsetof(struct shmem_inode_info, vfs_inode));
>+}
>+
>+static struct kmem_cache_ops shmem_kmem_cache_ops = {
>+	.get = shmem_get_inodes,
>+	.kick = kick_inodes
>+};
>+
> static int init_inodecache(void)
> {
> 	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
> 				sizeof(struct shmem_inode_info),
>-				0, 0, init_once, NULL);
>+				0, 0, init_once, &shmem_kmem_cache_ops);
> 	if (shmem_inode_cachep == NULL)
> 		return -ENOMEM;
> 	return 0;
>
>-- 
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>

	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
