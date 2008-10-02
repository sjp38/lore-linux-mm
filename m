Subject: nfs mmap vs i_mutex inversion
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Date: Thu, 02 Oct 2008 16:53:35 +0200
Message-Id: <1222959215.27875.8.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Hi Trond,

About that lock order inversion I remembered, I still have the patches:

http://programming.kicks-ass.net/kernel-patches/mmap-vs-nfs/

Although they would want updating a little.

But looking at a recent (.27-rc5-mm1) the offending code path:

down_write(&mm->mmap_sem)
...
->nfs_file_mmap()
    nfs_revalidate_mapping()
      nfs_invalidate_mapping()
        mutex_lock(&inode->i_mutex);


vs the regular order of

  inode->i_mutex
    mm->mmap_sem

as described in mm/rmap.c

Seems to still exist.

If you agree its a valid concern, I'll brush up the patches and repost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
