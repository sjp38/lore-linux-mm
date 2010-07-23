Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 365A16B02A5
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 03:36:24 -0400 (EDT)
Received: by gwj16 with SMTP id 16so681571gwj.14
        for <linux-mm@kvack.org>; Fri, 23 Jul 2010 00:36:22 -0700 (PDT)
Message-ID: <4C49468B.40307@vflare.org>
Date: Fri, 23 Jul 2010 13:06:43 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111@ca-server1.us.oracle.com>
In-Reply-To: <20100621231809.GA11111@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On 06/22/2010 04:48 AM, Dan Magenheimer wrote:
> [PATCH V3 0/8] Cleancache: overview
> 
<snip>
> 
>  Documentation/ABI/testing/sysfs-kernel-mm-cleancache |   11 +
>  Documentation/vm/cleancache.txt                      |  194 +++++++++++++++++++
>  fs/btrfs/extent_io.c                                 |    9 
>  fs/btrfs/super.c                                     |    2 
>  fs/buffer.c                                          |    5 
>  fs/ext3/super.c                                      |    2 
>  fs/ext4/super.c                                      |    2 
>  fs/mpage.c                                           |    7 
>  fs/ocfs2/super.c                                     |    3 
>  fs/super.c                                           |    7 
>  include/linux/cleancache.h                           |   88 ++++++++
>  include/linux/fs.h                                   |    5 
>  mm/Kconfig                                           |   22 ++
>  mm/Makefile                                          |    1 
>  mm/cleancache.c                                      |  169 ++++++++++++++++
>  mm/filemap.c                                         |   11 +
>  mm/truncate.c                                        |   10 
>  17 files changed, 548 insertions(+)
> 
> (following is a copy of Documentation/vm/cleancache.txt)
> 
> MOTIVATION
> 
> Cleancache can be thought of as a page-granularity victim cache for clean
> pages that the kernel's pageframe replacement algorithm (PFRA) would like
> to keep around, but can't since there isn't enough memory.  So when the
> PFRA "evicts" a page, it first attempts to put it into a synchronous
> concurrency-safe page-oriented "pseudo-RAM" device (such as Xen's Transcendent
> Memory, aka "tmem", or in-kernel compressed memory, aka "zmem", or other
> RAM-like devices) which is not directly accessible or addressable by the
> kernel and is of unknown and possibly time-varying size.  And when a
> cleancache-enabled filesystem wishes to access a page in a file on disk,
> it first checks cleancache to see if it already contains it; if it does,
> the page is copied into the kernel and a disk access is avoided.
> 


Since zcache is now one of its use cases, I think the major objection that
remains against cleancache is its intrusiveness -- in particular, need to
change individual filesystems (even though one liners). Changes below should
help avoid these per-fs changes and make it more self contained. I haven't
tested these changes myself, so there might be missed cases or other mysterious
problems:

1. Cleancache requires filesystem specific changes primarily to make a call to
cleancache init and store (per-fs instance) pool_id. I think we can get rid of
these by directly passing 'struct super_block' pointer which is also
sufficient to identify FS instance a page belongs to. This should then be used
as a 'handle' by cleancache_ops provider to find corresponding memory pool or
create a new pool when a new handle is encountered.

This leaves out case of ocfs2 for which cleancache needs 'uuid' to decide if a
shared pool should be created. IMHO, this case (and cleancache.init_shared_fs)
should be removed from cleancache_ops since it is applicable only for Xen's
cleancache_ops provider.

2. I think change in btrfs can be avoided by moving cleancache_get_page()
from do_mpage_reapage() to filemap_fault() and this should work for all
filesystems. See:

handle_pte_fault() -> do_(non)linear_fault() -> __do_fault()
						-> vma->vm_ops->fault()

which is defined as filemap_fault() for all filesystems. If some future
filesystem uses its own custom function (why?) then it will have to arrange for
call to cleancache_get_page(), if it wants this feature.

With above changes, cleancache will be fairly self-contained:
 - cleancache_put_page() when page is removed from page-cache
 - cleacacache_get_page() when PF occurs (and after page-cache is searched)
 - cleancache_flush_*() on truncate_*()

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
