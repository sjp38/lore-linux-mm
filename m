Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA07078
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 15:18:20 -0400
Received: from boole.suse.de (Boole.suse.de [192.168.102.7])
	by Galois.suse.de (8.8.8/8.8.8) with ESMTP id VAA04739
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 21:17:41 +0200
Message-ID: <19980723211741.63350@boole.suse.de>
Date: Thu, 23 Jul 1998 21:17:41 +0200
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <87vhooio7e.fsf@atlas.CARNet.hr> <Pine.LNX.3.95.980723132525.6201D-100000@as200.spellcast.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.980723132525.6201D-100000@as200.spellcast.com>; from Benjamin C.R. LaHaise on Thu, Jul 23, 1998 at 01:27:53PM -0400
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 23, 1998 at 01:27:53PM -0400, Benjamin C.R. LaHaise wrote:
> On 23 Jul 1998, Zlatko Calusic wrote:
> 
> > Could you please send me a copy, since I don't know for how long host
> > will be down?
> 
> Okay, there's now a copy at
> http://www.kvack.org/~blah/patches/werner-lowmem.patch-2.1.110.gz (~5k).


One remark ... Bill's (to be exact  Bill Hawes <whawes@star.net>) patch
of a dynamic number of inodes is more elegant then mine included in this
patch :-)


         Werner

--------------------------------------------------------------------------
This is a multi-part message in MIME format.
--------------20E446B52C4B02943B4DB385
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi Bill,

I tried running a test similar to what I think you're using for your
"rust series", and on 2.1.109 I see very little change in compile time
after doing a big find.

After booting into 8M, a compile of net-tools-1.45 takes 83 seconds the
first time, 89 seconds after doing a "find /usr -type f" (about 53,000
files on my system.) Not a speed-up, but a much smaller change than the
typical numbers you've been seeing. Subsequent finds don't have much
effect; compile times remain in the range of 84-89 sec.

My kernel is heavily patched :-), but I think the relative lack of rust
may be largely due to setting inode-max to scale with memory size. For
an 8M system I have inode-max set to 1024, which nicely limits the
fraction of both inode and dcache memory.

If you don't mind trying some further experiments, could you try 2.1.109
with either the attached patch, or just a 

	echo 1024 >/proc/sys/fs/inode-max

right after boot. The patch makes this automatic and also preallocates
the inodes so that there's no fragmentation effect, but the important
part is probably to just get the limit right.

Hope this helps a bit ...

Regards,
Bill
--------------20E446B52C4B02943B4DB385
Content-Type: text/plain; charset=us-ascii; name="inode_prealloc109-patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="inode_prealloc109-patch"

--- linux-2.1.109/include/linux/fs.h.old	Fri Jul 17 09:28:55 1998
+++ linux-2.1.109/include/linux/fs.h	Fri Jul 17 09:33:33 1998
@@ -46,7 +46,17 @@
 /* And dynamically-tunable limits and defaults: */
 extern int max_inodes;
 extern int max_files, nr_files, nr_free_files;
-#define NR_INODE 4096	/* This should no longer be bigger than NR_FILE */
+/*
+ * Make the default inode limit scale with memory size
+ * up to a limit. (A 32M system gets 4096 inodes.)
+ *
+ * Note: NR_INODE may be larger than NR_FILE, as unused
+ * inodes are still useful for preserving page cache.
+ */
+#define NR_INODE_MAX 16384
+#define NR_INODE(pages) \
+	(((pages) >> 1) <= NR_INODE_MAX ? ((pages) >> 1) : NR_INODE_MAX)
+
 #define NR_FILE  4096	/* this can well be larger on a larger system */
 #define NR_RESERVED_FILES 10 /* reserved for root */
 
--- linux-2.1.109/fs/inode.c.old	Fri Jul  3 10:32:32 1998
+++ linux-2.1.109/fs/inode.c	Fri Jul 17 10:05:55 1998
@@ -20,8 +20,12 @@
  * Famous last words.
  */
 
+/* for sizing the inode limit */
+extern unsigned long num_physpages;
+
 #define INODE_PARANOIA 1
 /* #define INODE_DEBUG 1 */
+#define INODE_PREALLOC 1 /* make a CONFIG option */
 
 /*
  * Inode lookup is no longer as critical as it used to be:
@@ -65,7 +69,8 @@
 	int dummy[4];
 } inodes_stat = {0, 0, 0,};
 
-int max_inodes = NR_INODE;
+/* Initialized in inode_init() */
+int max_inodes;
 
 /*
  * Put the inode on the super block's dirty list.
@@ -737,15 +791,35 @@
  */
 void inode_init(void)
 {
-	int i;
 	struct list_head *head = inode_hashtable;
+	int i = HASH_SIZE;
 
-	i = HASH_SIZE;
 	do {
 		INIT_LIST_HEAD(head);
 		head++;
 		i--;
 	} while (i);
+
+	/*
+	 * Initialize the default maximum based on memory size.
+	 */
+	max_inodes = NR_INODE(num_physpages);
+
+#ifdef INODE_PREALLOC
+	/*
+	 * Preallocate the inodes to avoid memory fragmentation.
+	 */
+	spin_lock(&inode_lock);
+	while (inodes_stat.nr_inodes < max_inodes) {
+		struct inode *inode = grow_inodes();
+		if (!inode)
+			goto done;
+		list_add(&inode->i_list, &inode_unused);
+		inodes_stat.nr_free_inodes++;
+	}
+	spin_unlock(&inode_lock);
+done:
+#endif
 }
 
 /* This belongs in file_table.c, not here... */

--------------20E446B52C4B02943B4DB385--


-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.rutgers.edu
Please read the FAQ at http://www.altern.org/andrebalsa/doc/lkml-faq.html

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
