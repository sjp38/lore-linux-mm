Date: Wed, 25 Aug 2004 21:37:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
    16gb
In-Reply-To: <1093460701.5677.1881.camel@knk>
Message-ID: <Pine.LNX.4.44.0408252104540.2664-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2004, keith wrote:
> 
> I turned CONFIG_DEBUG_PAGEALLOC off.

Good, thanks.

> I ran into problems when I tried
> building 60 kernel trees or so.  It is using about 10gb of tmpfs space. 
> See http://bugme.osdl.org/attachment.cgi?id=3566&action=view for more
> info.

Okay, that's more to the point.

> It looks like there should be a maximum number of inodes for tmpfs.
> Because I didn't know how many inodes it is using but I gave it a large
> playground to use (mount -t tmpfs -o size=15G,nr_inodes=10000k,mode=0700
> tmpfs /mytmpfs)

Well, by default it does give you a maximum number of inodes for tmpfs:
which at 16GB of RAM (in 4KB pages: odd that that factors in, but I've
no great urge to depart from existing defaults except where it's buggy)
would give you 2M inodes.  But since each might roughly be expected to
consume 1KB (a shmem_inode, a dentry, a longer name, a radix node) of
low memory, we'd want 2GB of lowmem to support all those: too much.

So, how well does the patch below work for you, if you leave nr_inodes
to its default?  Carry on setting size=15G, that should be okay; but
I don't think the kernel should stop you if you insist on setting
nr_inodes to something unfortunate like 10M.  "df -i" will show
how many inodes it's actually giving you by default.

Andrew, this paragraph is more for you...
If you examine my 1KB calculation above, you may conclude that this
won't be quite the final patch: so long as there's ample swap, the
(more than 1) radix nodes shouldn't be a problem since they would
melt away under lowmem pressure (hmm, does lowmem shortage exert
any pressure on highmem cache these days, I wonder?); but doesn't
link(1) imply that dentries can take up almost unlimited space?
Looks as if tmpfs ought to be limiting links as it limits inodes.

Hugh

--- 2.6.8.1-mm4/mm/shmem.c	2004-08-23 12:20:31.000000000 +0100
+++ linux/mm/shmem.c	2004-08-25 20:47:27.072015312 +0100
@@ -1818,9 +1818,10 @@
 
 	/*
 	 * Per default we only allow half of the physical ram per
-	 * tmpfs instance
+	 * tmpfs instance; limiting inodes to 1 per 2 pages of lowmem.
 	 */
 	blocks = inodes = totalram_pages / 2;
+	inodes -= totalhigh_pages / 2;
 
 #ifdef CONFIG_TMPFS
 	if (shmem_parse_options(data, &mode, &uid, &gid, &blocks, &inodes)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
