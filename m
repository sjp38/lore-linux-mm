Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] slabasap-mm5_A2
Date: Sun, 8 Sep 2002 17:14:54 -0400
References: <200209071006.18869.tomlins@cam.org> <200209081142.02839.tomlins@cam.org> <3D7BB97A.6B6E4CA5@digeo.com>
In-Reply-To: <3D7BB97A.6B6E4CA5@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209081714.54110.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On September 8, 2002 04:56 pm, Andrew Morton wrote:
> Ed Tomlinson wrote:
> > Hi,
> >
> > Here is a rewritten slablru - this time its not using the lru...  If
> > changes long standing slab behavior.  Now slab.c releases pages as soon
> > as possible.  This was done since we noticed that slablru was taking a
> > long time to release the pages it freed - from other vm experiences this
> > is not a good thing.
>
> Right.  There remains the issue that we're ripping away constructed
> objects from slabs which have constructors, as Stephen points out.

I have a small optimization coded in slab.  If there are not any free
slab objects I do not free the page.   If we have problems with high
order slabs we can change this to be if we do not have <n> objects
do not free it.

> I doubt if that matters.  slab constructors just initialise stuff.
> If the memory is in cache then the initialisation is negligible.
> If the memory is not in cache then the initialisation will pull
> it into cache, which is something which we needed to do anyway.  And
> unless the slab's access pattern is extremely LIFO, chances are that
> most allocations will come in from part-filled slab pages anyway.
>
> And other such waffly words ;)  I'll do the global LIFO page hotlists
> soonl; that'll fix it up.
>
> > In this patch I have tried to make as few changes as possible.
>
> Thanks.  I've shuffled the patching sequence (painful), and diddled
> a few things.  We actually do have the "number of scanned pages"
> in there, so we can use that.  I agree that the ratio should be
> nr_scanned/total rather than nr_reclaimed/total.   This way, if
> nr_reclaimed < nr_scanned (page reclaim is in trouble) then we
> put more pressure on slabs.

OK will change this.  This also means the changes to prune functions
made for slablru will come back - they convert these fuctions so they
age <n> object rather than purge <n>.

> >   With this in mind I am using
> > the percentage of the active+inactive pages reclaimed to recover the same
> > percentage of the pruneable caches.  In slablru the affect was to age the
> > pruneable caches by percentage of the active+inactive pages scanned -
> > this could be done but required more code so I went used pages reclaimed.
> >  The same choise was made about accounting of pages freed by the
> > shrink_<something>_memory calls.
> >
> > There is also a question as to if we should only use the ZONE_DMA and
> > ZONE_NORMAL to drive the cache shrinking.  Talk with Rik on irc convinced
> > me to go with the choise that required less code, so we use all zones.
>
> OK.  We could do with a `gimme_the_direct_addressed_classzone' utility
> anyway.  It is currently open-coded in fs/buffer.c:free_more_memory().
> We can just pull that out of there and use memclass() on it for this.

Ah thanks.  Was wondering the best way to do this.  Will read the code.

> > To apply the patch to mm5 use the follow procedure:
> > copy the two slablru patch and discard all but the vmscan changes.
> > replace the slablru patch with the just created patches that just hit
> > vmscan after applying the mm5 patches apply the following patch to adjust
> > vmscan and add slabasap.
> >
> > This passes the normal group of tests I apply to my patches (mm4 stalled
> > force watchdog to reboot).   The varient for bk linus also survives these
> > tests.
> >
> > I have seen some unexpected messages from the kde artsd daemon when I
> > left kde running all night.  This may imply we want to have slab be a
> > little less aggressive freeing high order slabs. Would like to see if
> > other have problems though - it could just be debian and kde 3.0.3 (which
> > is not offical yet).
>
> hm.

Yeah.  There no messages any logs about high order allocations failing...

> > Please let me know if you want any changes or the addition of any of the
> > options mentioned.
>
> In here:
>
>         int entries = inodes_stat.nr_inodes / ratio + 1;
>
> what is the "+ 1" for?  If it is to avoid divide-by-zero then
> it needs parentheses.  I added the "+ 1" to the call site to cover that.

It was so we would alway do some work.  ratio should never end up
as zero.  Its based on (used pages in all zones) / (reclaimed in one zone)
so we are safe.

> From a quick test, the shrinking rate seems quite reasonable to
> me.  mem=512m, with twenty megs of ext2 inodes in core, a `dd'
> of one gigabyte (twice the size of memory) steadily pushed the
> ext2 inodes down to 2.5 megs (although total memory was still
> 9 megs - internal fragmentation of the slab).
>
> A second 1G dd pushed it down to 1M/3M.
>
> A third 1G dd pushed it down to .25M/1.25M
>
> Seems OK.
>
> A few things we should do later:
>
> - We're calling prune_icache with a teeny number of inodes, many times.
>   Would be better to batch that up a bit.

Why not move the prunes to try_to_free_pages?   The should help a little to get 
bigger batches of pages as will using the number of scanned pages.  

> - It would be nice to bring back the pruner callbacks.  The post-facto
>   hook registration thing will be fine.  Hit me with a stick for making
>   you change the kmem_cache_create() prototype.  Sorry about that.

I still have to code from slablru so this is not as painfull as the first time.

> If we have the pruner callbacks then vmscan can just do:
>
> 	kmem_shrink_stuff(ratio);
>
> and then kmem_shrink_stuff() can do:
>
> 	cachep->nr_to_prune += cacheb->inuse / ratio;
> 	if (cachep->nr_to_prune > cachep->prune_batch) {
> 		int prune = cachep->nr_to_prune;
>
> 		cachep->nr_to_prune = 0;
> 		(*cachep->pruner)(nr_to_prune);
> 	}

The callbacks also make it easier to setup ageable caches and quickly
integrate them into the vm.

> But let's get the current code settled in before doing these
> refinements.

I can get the aging changes to you real fast if you want them.  I initially
coded it this way then pull the changes to reduce the code...  see below

The other thing we want to be careful with is to make sure the lack of
free page accounting is detected by oom - we definitly do not want to
oom when slab has freed memory by try_to_free_pages does not
realize it..

> There are some usage patterns in which the dentry/inode aging
> might be going wrong.  Try, with mem=512m
>
> 	cp -a linux a
> 	cp -a linux b
> 	cp -a linux c
>
> etc.
>
> Possibly the inode/dentry cache is just being FIFO here and is doing
> exactly the wrong thing.  But the dcache referenced-bit logic should
> cause the inodes in `linux' to be pinned with this test, so that
> should be OK.  Dunno.
>
> The above test will be hurt a bit by the aggressively lowered (10%)
> background writeback threshold - more reads competing with writes.
> Maybe I should not kick off background writeback until the dirty
> threshold reaches 30% if there are reads queued against the device.
> That's easy enough to do.
>
> drop-behind should help here too.

This converts the prunes in inode and dcache to age <n> entries rather
than purge them.  Think this is the more correct behavior.  Code is from
slablru.

diff -Nru a/fs/inode.c b/fs/inode.c
--- a/fs/inode.c	Wed Aug 28 17:47:15 2002
+++ b/fs/inode.c	Wed Aug 28 17:47:15 2002
@@ -388,10 +388,11 @@
 
 	count = 0;
 	entry = inode_unused.prev;
-	while (entry != &inode_unused)
-	{
+	for(; goal; goal--) {
 		struct list_head *tmp = entry;
 
+		if (entry == &inode_unused)
+			break;
 		entry = entry->prev;
 		inode = INODE(tmp);
 		if (inode->i_state & (I_FREEING|I_CLEAR|I_LOCK))
@@ -405,8 +406,6 @@
 		list_add(tmp, freeable);
 		inode->i_state |= I_FREEING;
 		count++;
-		if (!--goal)
-			break;
 	}
 	inodes_stat.nr_unused -= count;
 	spin_unlock(&inode_lock);

diff -Nru a/fs/dcache.c b/fs/dcache.c
--- a/fs/dcache.c	Wed Aug 28 17:47:13 2002
+++ b/fs/dcache.c	Wed Aug 28 17:47:13 2002
@@ -329,12 +328,11 @@
 void prune_dcache(int count)
 {
 	spin_lock(&dcache_lock);
-	for (;;) {
+	for (; count ; count--) {
 		struct dentry *dentry;
 		struct list_head *tmp;
 
 		tmp = dentry_unused.prev;
-
 		if (tmp == &dentry_unused)
 			break;
 		list_del_init(tmp);
@@ -349,12 +347,8 @@
 		dentry_stat.nr_unused--;
 
 		/* Unused dentry with a count? */
-		if (atomic_read(&dentry->d_count))
-			BUG();
-
+		BUG_ON(atomic_read(&dentry->d_count));
 		prune_one_dentry(dentry);
-		if (!--count)
-			break;
 	}
 	spin_unlock(&dcache_lock);
 }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
