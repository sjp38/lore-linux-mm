Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 618DC6B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 16:11:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d79so1043423wma.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 13:11:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g17si7891259wmc.157.2017.04.26.13.11.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Apr 2017 13:11:29 -0700 (PDT)
Date: Wed, 26 Apr 2017 22:11:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 4/4] mm: Adaptive hash table scaling
Message-ID: <20170426201126.GA32407@dhcp22.suse.cz>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
 <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
 <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Fri 03-03-17 15:32:47, Andrew Morton wrote:
> On Thu,  2 Mar 2017 00:33:45 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> 
> > Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
> > is provided every time memory quadruples the sizes of hash tables will only
> > double instead of quadrupling as well. This algorithm starts working only
> > when memory size reaches a certain point, currently set to 64G.
> > 
> > This is example of dentry hash table size, before and after four various
> > memory configurations:
> > 
> > MEMORY	   SCALE	 HASH_SIZE
> > 	old	new	old	new
> >     8G	 13	 13      8M      8M
> >    16G	 13	 13     16M     16M
> >    32G	 13	 13     32M     32M
> >    64G	 13	 13     64M     64M
> >   128G	 13	 14    128M     64M
> >   256G	 13	 14    256M    128M
> >   512G	 13	 15    512M    128M
> >  1024G	 13	 15   1024M    256M
> >  2048G	 13	 16   2048M    256M
> >  4096G	 13	 16   4096M    512M
> >  8192G	 13	 17   8192M    512M
> > 16384G	 13	 17  16384M   1024M
> > 32768G	 13	 18  32768M   1024M
> > 65536G	 13	 18  65536M   2048M
> 
> OK, but what are the runtime effects?  Presumably some workloads will
> slow down a bit.  How much? How do we know that this is a worthwhile
> tradeoff?
> 
> If the effect of this change is "undetectable" then those hash tables
> are simply too large, and additional tuning is needed, yes?

I am playing with a 3TB and have hit the following
[    0.961309] Dentry cache hash table entries: 536870912 (order: 20, 4294967296 bytes)
[    2.300012] vmalloc: allocation failure, allocated 1383612416 of 2147487744 bytes
[    2.307473] swapper/0: page allocation failure: order:0, mode:0x2080020(GFP_ATOMIC)
[    2.315101] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W          4.4.49-hotplug19-default #1
[    2.324017] Hardware name: Huawei 9008/IT91SMUB, BIOS BLXSV607 04/17/2017
[    2.330775]  ffffffff8101aba5 ffffffff8130efa0 ffffffff81863f48 ffffffff81c03e40
[    2.338201]  ffffffff8118c9a2 02080020fff00300 ffffffff81863f48 ffffffff81c03de0
[    2.345628]  0000000000000018 ffffffff81c03e50 ffffffff81c03df8 ffffffff811d28e6
[    2.353056] Call Trace:
[    2.355507]  [<ffffffff81019a99>] dump_trace+0x59/0x310
[    2.360710]  [<ffffffff81019e3a>] show_stack_log_lvl+0xea/0x170
[    2.366605]  [<ffffffff8101abc1>] show_stack+0x21/0x40
[    2.371723]  [<ffffffff8130efa0>] dump_stack+0x5c/0x7c
[    2.376842]  [<ffffffff8118c9a2>] warn_alloc_failed+0xe2/0x150
[    2.382655]  [<ffffffff811c2a10>] __vmalloc_node_range+0x240/0x280
[    2.388814]  [<ffffffff811c2a97>] __vmalloc+0x47/0x50
[    2.393851]  [<ffffffff81da02ae>] alloc_large_system_hash+0x189/0x25d
[    2.400264]  [<ffffffff81da7625>] inode_init+0x74/0xa3
[    2.405381]  [<ffffffff81da7483>] vfs_caches_init+0x59/0xe1
[    2.410930]  [<ffffffff81d6f070>] start_kernel+0x474/0x4d0
[    2.416392]  [<ffffffff81d6e719>] x86_64_start_kernel+0x147/0x156

Allocating 4G for a hash table is just ridiculous. 512MB which this
patch should give looks much reasonable, although I would argue it is
still a _lot_.
I cannot say I would be really happy about the chosen approach,
though. Why HASH_ADAPT is not implicit? Which hash table would need
gigabytes of memory and still benefit from it? Even if there is such an
example then it should use the explicit high_limit. I do not like this
opt-in because it is just too easy to miss that and hit the same issue
again. And in fact only few users of alloc_large_system_hash are using
the flag. E.g. why {dcache,inode}_init_early do not have the flag? I
am pretty sure that having a physically contiguous hash table would be
better over vmalloc from the TLB point of view.

mount_hashtable resp. mountpoint_hashtable are another example. Other
users just have a reasonable max value. So can we do the following
on top of your commit? I think that we should rethink the scaling as
well but I do not have a good answer for the maximum size so let's just
start with a more reasonable API first.
---
diff --git a/fs/dcache.c b/fs/dcache.c
index 808ea99062c2..363502faa328 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3585,7 +3585,7 @@ static void __init dcache_init(void)
 					sizeof(struct hlist_bl_head),
 					dhash_entries,
 					13,
-					HASH_ZERO | HASH_ADAPT,
+					HASH_ZERO,
 					&d_hash_shift,
 					&d_hash_mask,
 					0,
diff --git a/fs/inode.c b/fs/inode.c
index a9caf53df446..b3c0731ec1fe 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1950,7 +1950,7 @@ void __init inode_init(void)
 					sizeof(struct hlist_head),
 					ihash_entries,
 					14,
-					HASH_ZERO | HASH_ADAPT,
+					HASH_ZERO,
 					&i_hash_shift,
 					&i_hash_mask,
 					0,
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index dbaf312b3317..e223d91b6439 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -359,7 +359,6 @@ extern void *alloc_large_system_hash(const char *tablename,
 #define HASH_SMALL	0x00000002	/* sub-page allocation allowed, min
 					 * shift passed via *_hash_shift */
 #define HASH_ZERO	0x00000004	/* Zero allocated hash table */
-#define	HASH_ADAPT	0x00000008	/* Adaptive scale for large memory */
 
 /* Only NUMA needs hash distribution. 64bit NUMA architectures have
  * sufficient vmalloc space.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fa752de84eef..3bf60669d200 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7226,7 +7226,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 		if (PAGE_SHIFT < 20)
 			numentries = round_up(numentries, (1<<20)/PAGE_SIZE);
 
-		if (flags & HASH_ADAPT) {
+		if (!high_limit) {
 			unsigned long adapt;
 
 			for (adapt = ADAPT_SCALE_NPAGES; adapt < numentries;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
