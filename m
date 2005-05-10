Date: Tue, 10 May 2005 15:10:34 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH  Linux 2.6.11 ]  VM / FS:  Metadata-In-Ram Support
Message-Id: <20050510151034.7a338f98.akpm@osdl.org>
In-Reply-To: <002d01c5554e$5a1bab60$230ba8c0@APSLHP>
References: <002d01c5554e$5a1bab60$230ba8c0@APSLHP>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Wang <spwang@corp.netease.com>
Cc: andrea@suse.de, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Peter Wang" <spwang@corp.netease.com> wrote:
>
> Hello:

(Please wrap those emails at column 72!)

> We are trying to implementing an feature for Linux system: metadata in ram,it's a feature we need for many of our servers,and which is also proved helpful in test loads.
> 
> I. Description of the background issue
>   1. Linux have slabs for inode/dentry cache,but that's very expensive in bytes(a few hundred bytes per inode,more than 1 hundred for dentry)__while on disk file store are relatively cheap( Ext3: 128 bytes per inode,about 30 bytes per dentry)
>   2. Linux has buffer cache,but they are treated no different with page cache in page reclaiming.
>   3. For many of our server load(random read write over a large number of files(typically below 50k bytes))slab is as of little use(for randomness and the large number of files).And at the same time,buffer cache are easilly flush away(for the random access and the large number of files too).
> 
> II. Problem with it
> 
> Buffer cache shall be more valued over page cache in the workloads. Considering randomly accessing many files under the same directories over a period of time,in the workload,system accessing different page caches(so cache for them dosent count much),while accesing same metadata buffer pages(for they are under same directory and their on-disk metadata are likely contigours--thus in same buffer page).
> 
> At our real world servers,such problem do exist,buffer pages are relative fewer than they shall be.

OK.  The problems and benefits which you are seeing are fairly specific to
your workload, to the size of your working set, to the amount of memory you
have and to disk layout but yes, space efficiency of inodes and directory
entries can be significantly higher in the on-disk representation.

One thing to bear in mind (which probably isn't relevant here) is access
time modifications.  On an typical filesytem (especially ext3), each atime
update causes the inode's block to be written out at commit time.  It also
marks that block's pagecache page as recently used.  Consequently, for
read-mostly workloads which access a lot of files, atime updates can cause
the amount of blockdev pagecache (aka "Buffers:") to be quite high.

With `mount -o remount,noatime' the kernel has no need to keep those
blockdev pagecache pages in memory and they get reclaimed.  I've seen this
save a couple of hundred megabytes of memory with some workloads on a 2G
machine.


Anyway.  Your patch is a bit scary because it appears that it'll pin
blockdev pagecache in memory, potentially causing an out-of-memory
condition.

I expect that if you increase /proc/sys/vm/vfs_cache_pressure by a large
amount (set it to 1000000) you should get a similar effect.  The kernel
will aggressively reclaim dcache and icache and that will free up more
memory for the now-more-frequently-referenced blockdev pagecache.

Could you please do that and retest?  Also try it with and without `noatime'.


> --- linux-2.6.11/fs/super.c 2005-05-05 21:05:17.000000000 -0400
> +++ linux-2.6.11-Meta/fs/super.c 2005-05-09 12:17:47.000000000 -0400

Your email client replaces tabs with spaces.  Please spend some time with
http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt before sending any
further patches, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
