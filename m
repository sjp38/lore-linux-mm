Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB3FC6B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 19:51:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p9so4024456pgc.6
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 16:51:09 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s89si4408819pfk.96.2017.10.26.16.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 16:51:07 -0700 (PDT)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove
 'page-less' support
Date: Thu, 26 Oct 2017 23:51:04 +0000
Message-ID: <1509061831.25213.2.camel@intel.com>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20171020074750.GA13568@lst.de> <20171020093148.GA20304@lst.de>
	 <20171026105850.GA31161@quack2.suse.cz>
In-Reply-To: <20171026105850.GA31161@quack2.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <6B1E8E88FC7C9E4D9754113A024144AD@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>, "jack@suse.cz" <jack@suse.cz>
Cc: "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "bfields@fieldses.org" <bfields@fieldses.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hefty, Sean" <sean.hefty@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "mhocko@suse.com" <mhocko@suse.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>, "hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "david@fromorbit.com" <david@fromorbit.com>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "paulus@samba.org" <paulus@samba.org>

On Thu, 2017-10-26 at 12:58 +-0200, Jan Kara wrote:
+AD4- On Fri 20-10-17 11:31:48, Christoph Hellwig wrote:
+AD4- +AD4- On Fri, Oct 20, 2017 at 09:47:50AM +-0200, Christoph Hellwig wr=
ote:
+AD4- +AD4- +AD4- I'd like to brainstorm how we can do something better.
+AD4- +AD4- +AD4-=20
+AD4- +AD4- +AD4- How about:
+AD4- +AD4- +AD4-=20
+AD4- +AD4- +AD4- If we hit a page with an elevated refcount in truncate / =
hole puch
+AD4- +AD4- +AD4- etc for a DAX file system we do not free the blocks in th=
e file system,
+AD4- +AD4- +AD4- but add it to the extent busy list.+AKAAoA-We mark the pa=
ge as delayed
+AD4- +AD4- +AD4- free (e.g. page flag?) so that when it finally hits refco=
unt zero we
+AD4- +AD4- +AD4- call back into the file system to remove it from the busy=
 list.
+AD4- +AD4-=20
+AD4- +AD4- Brainstorming some more:
+AD4- +AD4-=20
+AD4- +AD4- Given that on a DAX file there shouldn't be any long-term page
+AD4- +AD4- references after we unmap it from the page table and don't allo=
w
+AD4- +AD4- get+AF8-user+AF8-pages calls why not wait for the references fo=
r all
+AD4- +AD4- DAX pages to go away first?+AKAAoA-E.g. if we find a DAX page i=
n
+AD4- +AD4- truncate+AF8-inode+AF8-pages+AF8-range that has an elevated ref=
count we set
+AD4- +AD4- a new flag to prevent new references from showing up, and then
+AD4- +AD4- simply wait for it to go away.+AKAAoA-Instead of a busy way we =
can
+AD4- +AD4- do this through a few hashed waitqueued in dev+AF8-pagemap.+AKA=
AoA-And in
+AD4- +AD4- fact put+AF8-zone+AF8-device+AF8-page already gets called when =
putting the
+AD4- +AD4- last page so we can handle the wakeup from there.
+AD4- +AD4-=20
+AD4- +AD4- In fact if we can't find a page flag for the stop new callers
+AD4- +AD4- things we could probably come up with a way to do that through
+AD4- +AD4- dev+AF8-pagemap somehow, but I'm not sure how efficient that wo=
uld
+AD4- +AD4- be.
+AD4-=20
+AD4- We were talking about this yesterday with Dan so some more brainstorm=
ing
+AD4- from us. We can implement the solution with extent busy list in ext4
+AD4- relatively easily - we already have such list currently similarly to =
XFS.
+AD4- There would be some modifications needed but nothing too complex. The
+AD4- biggest downside of this solution I see is that it requires per-files=
ystem
+AD4- solution for busy extents - ext4 and XFS are reasonably fine, however=
 btrfs
+AD4- may have problems and ext2 definitely will need some modifications.
+AD4- Invisible used blocks may be surprising to users at times although gi=
ven
+AD4- page refs should be relatively short term, that should not be a big i=
ssue.
+AD4- But are we guaranteed page refs are short term? E.g. if someone creat=
es
+AD4- v4l2 videobuf in MAP+AF8-SHARED mapping of a file on DAX filesystem, =
page refs
+AD4- can be rather long-term similarly as in RDMA case. Also freeing of bl=
ocks
+AD4- on page reference drop is another async entry point into the filesyst=
em
+AD4- which could unpleasantly surprise us but I guess workqueues would sol=
ve
+AD4- that reasonably fine.
+AD4-=20
+AD4- WRT waiting for page refs to be dropped before proceeding with trunca=
te (or
+AD4- punch hole for that matter - that case is even nastier since we don't=
 have
+AD4- i+AF8-size to guard us). What I like about this solution is that it i=
s very
+AD4- visible there's something unusual going on with the file being trunca=
ted /
+AD4- punched and so problems are easier to diagnose / fix from the admin s=
ide.
+AD4- So far we have guarded hole punching from concurrent faults (and
+AD4- get+AF8-user+AF8-pages() does fault once you do unmap+AF8-mapping+AF8=
-range()) with
+AD4- I+AF8-MMAP+AF8-LOCK (or its equivalent in ext4). We cannot easily wai=
t for page
+AD4- refs to be dropped under I+AF8-MMAP+AF8-LOCK as that could deadlock -=
 the most
+AD4- obvious case Dan came up with is when GUP obtains ref to page A, then=
 hole
+AD4- punch comes grabbing I+AF8-MMAP+AF8-LOCK and waiting for page ref on =
A to be
+AD4- dropped, and then GUP blocks on trying to fault in another page.
+AD4-=20
+AD4- I think we cannot easily prevent new page references to be grabbed as=
 you
+AD4- write above since nobody expects stuff like get+AF8-page() to fail. B=
ut I+AKA-
+AD4- think that unmapping relevant pages and then preventing them to be fa=
ulted
+AD4- in again is workable and stops GUP as well. The problem with that is =
though
+AD4- what to do with page faults to such pages - you cannot just fail them=
 for
+AD4- hole punch, and you cannot easily allocate new blocks either. So we a=
re
+AD4- back at a situation where we need to detach blocks from the inode and=
 then
+AD4- wait for page refs to be dropped - so some form of busy extents. Am I
+AD4- missing something?
+AD4-=20

No, that's a good summary of what we talked about. However, I did go
back and give the new lock approach a try and was able to get my test
to pass. The new locking is not pretty especially since you need to
drop and reacquire the lock so that get+AF8-user+AF8-pages() can finish
grabbing all the pages it needs. Here are the two primary patches in
the series, do you think the extent-busy approach would be cleaner?

---

commit 5023d20a0aa795ddafd43655be1bfb2cbc7f4445
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:   Wed Oct 25 05:14:54 2017 -0700

    mm, dax: handle truncate of dma-busy pages
   =20
    get+AF8-user+AF8-pages() pins file backed memory pages for access by dm=
a
    devices. However, it only pins the memory pages not the page-to-file
    offset association. If a file is truncated the pages are mapped out of
    the file and dma may continue indefinitely into a page that is owned by
    a device driver. This breaks coherency of the file vs dma, but the
    assumption is that if userspace wants the file-space truncated it does
    not matter what data is inbound from the device, it is not relevant
    anymore.
   =20
    The assumptions of the truncate-page-cache model are broken by DAX wher=
e
    the target DMA page +ACo-is+ACo- the filesystem block. Leaving the page=
 pinned
    for DMA, but truncating the file block out of the file, means that the
    filesytem is free to reallocate a block under active DMA to another
    file+ACE-
   =20
    Here are some possible options for fixing this situation ('truncate' an=
d
    'fallocate(punch hole)' are synonymous below):
   =20
        1/ Fail truncate while any file blocks might be under dma
   =20
        2/ Block (sleep-wait) truncate while any file blocks might be under
           dma
   =20
        3/ Remap file blocks to a +ACI-lost+-found+ACI--like file-inode whe=
re
           dma can continue and we might see what inbound data from DMA was
           mapped out of the original file. Blocks in this file could be
           freed back to the filesystem when dma eventually ends.
   =20
        4/ List the blocks under DMA in the extent busy list and either hol=
d
           off commit of the truncate transaction until commit, or otherwis=
e
           keep the blocks marked busy so the allocator does not reuse them
           until DMA completes.
   =20
        5/ Disable dax until option 3 or another long term solution has bee=
n
           implemented. However, filesystem-dax is still marked experimenta=
l
           for concerns like this.
   =20
    Option 1 will throw failures where userspace has never expected them
    before, option 2 might hang the truncating process indefinitely, and
    option 3 requires per filesystem enabling to remap blocks from one inod=
e
    to another.  Option 2 is implemented in this patch for the DAX path wit=
h
    the expectation that non-transient users of get+AF8-user+AF8-pages() (R=
DMA) are
    disallowed from setting up dax mappings and that the potential delay
    introduced to the truncate path is acceptable compared to the response
    time of the page cache case. This can only be seen as a stop-gap until
    we can solve the problem of safely sequestering unallocated filesystem
    blocks under active dma.
   =20
    The solution introduces a new inode semaphore that that is held
    exclusively for get+AF8-user+AF8-pages() and held for read at truncate =
while
    sleep-waiting on a hashed waitqueue.
   =20
    Credit for option 3 goes to Dave Hansen, who proposed something similar
    as an alternative way to solve the problem that MAP+AF8-DIRECT was tryi=
ng to
    solve. Credit for option 4 goes to Christoph Hellwig.
   =20
    Cc: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Cc: Jeff Moyer +ADw-jmoyer+AEA-redhat.com+AD4-
    Cc: Dave Chinner +ADw-david+AEA-fromorbit.com+AD4-
    Cc: Matthew Wilcox +ADw-mawilcox+AEA-microsoft.com+AD4-
    Cc: Alexander Viro +ADw-viro+AEA-zeniv.linux.org.uk+AD4-
    Cc: +ACI-Darrick J. Wong+ACI- +ADw-darrick.wong+AEA-oracle.com+AD4-
    Cc: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
    Cc: Dave Hansen +ADw-dave.hansen+AEA-linux.intel.com+AD4-
    Cc: Andrew Morton +ADw-akpm+AEA-linux-foundation.org+AD4-
    Reported-by: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 4ac359e14777..a5a4b95ffdaf 100644
--- a/drivers/dax/super.c
+-+-+- b/drivers/dax/super.c
+AEAAQA- -167,6 +-167,7 +AEAAQA- struct dax+AF8-device +AHs-
 +ACM-if IS+AF8-ENABLED(CONFIG+AF8-FS+AF8-DAX)
 static void generic+AF8-dax+AF8-pagefree(struct page +ACo-page, void +ACo-=
data)
 +AHs-
+-	wake+AF8-up+AF8-devmap+AF8-idle(+ACY-page-+AD4AXw-refcount)+ADs-
 +AH0-
=20
 struct dax+AF8-device +ACo-fs+AF8-dax+AF8-claim+AF8-bdev(struct block+AF8-=
device +ACo-bdev, void +ACo-owner)
diff --git a/fs/dax.c b/fs/dax.c
index fd5d385988d1..f2c98f9cb833 100644
--- a/fs/dax.c
+-+-+- b/fs/dax.c
+AEAAQA- -346,6 +-346,19 +AEAAQA- static void dax+AF8-disassociate+AF8-entr=
y(void +ACo-entry, struct inode +ACo-inode, bool trunc)
 	+AH0-
 +AH0-
=20
+-static struct page +ACo-dma+AF8-busy+AF8-page(void +ACo-entry)
+-+AHs-
+-	unsigned long pfn, end+AF8-pfn+ADs-
+-
+-	for+AF8-each+AF8-entry+AF8-pfn(entry, pfn, end+AF8-pfn) +AHs-
+-		struct page +ACo-page +AD0- pfn+AF8-to+AF8-page(pfn)+ADs-
+-
+-		if (page+AF8-ref+AF8-count(page) +AD4- 1)
+-			return page+ADs-
+-	+AH0-
+-	return NULL+ADs-
+-+AH0-
+-
 /+ACo-
  +ACo- Find radix tree entry at given index. If it points to an exceptiona=
l entry,
  +ACo- return it with the radix tree entry locked. If the radix tree doesn=
't
+AEAAQA- -487,6 +-500,97 +AEAAQA- static void +ACo-grab+AF8-mapping+AF8-ent=
ry(struct address+AF8-space +ACo-mapping, pgoff+AF8-t index,
 	return entry+ADs-
 +AH0-
=20
+-static int wait+AF8-page(atomic+AF8-t +ACoAXw-refcount)
+-+AHs-
+-	struct page +ACo-page +AD0- container+AF8-of(+AF8-refcount, struct page,=
 +AF8-refcount)+ADs-
+-	struct inode +ACo-inode +AD0- page-+AD4-inode+ADs-
+-
+-	if (page+AF8-ref+AF8-count(page) +AD0APQ- 1)
+-		return 0+ADs-
+-
+-	i+AF8-daxdma+AF8-unlock+AF8-shared(inode)+ADs-
+-	schedule()+ADs-
+-	i+AF8-daxdma+AF8-lock+AF8-shared(inode)+ADs-
+-
+-	/+ACo-
+-	 +ACo- if we bounced the daxdma+AF8-lock then we need to rescan the
+-	 +ACo- truncate area.
+-	 +ACo-/
+-	return 1+ADs-
+-+AH0-
+-
+-void dax+AF8-wait+AF8-dma(struct address+AF8-space +ACo-mapping, loff+AF8=
-t lstart, loff+AF8-t len)
+-+AHs-
+-	struct inode +ACo-inode +AD0- mapping-+AD4-host+ADs-
+-	pgoff+AF8-t	indices+AFs-PAGEVEC+AF8-SIZE+AF0AOw-
+-	pgoff+AF8-t	start, end, index+ADs-
+-	struct pagevec pvec+ADs-
+-	unsigned i+ADs-
+-
+-	lockdep+AF8-assert+AF8-held(+ACY-inode-+AD4-i+AF8-dax+AF8-dmasem)+ADs-
+-
+-	if (lstart +ADw- 0 +AHwAfA- len +ADw- -1)
+-		return+ADs-
+-
+-	/+ACo- in the limited case get+AF8-user+AF8-pages for dax is disabled +A=
Co-/
+-	if (IS+AF8-ENABLED(CONFIG+AF8-FS+AF8-DAX+AF8-LIMITED))
+-		return+ADs-
+-
+-	if (+ACE-dax+AF8-mapping(mapping))
+-		return+ADs-
+-
+-	if (mapping-+AD4-nrexceptional +AD0APQ- 0)
+-		return+ADs-
+-
+-	if (len +AD0APQ- -1)
+-		end +AD0- -1+ADs-
+-	else
+-		end +AD0- (lstart +- len) +AD4APg- PAGE+AF8-SHIFT+ADs-
+-	start +AD0- lstart +AD4APg- PAGE+AF8-SHIFT+ADs-
+-
+-retry:
+-	pagevec+AF8-init(+ACY-pvec, 0)+ADs-
+-	index +AD0- start+ADs-
+-	while (index +ADw- end +ACYAJg- pagevec+AF8-lookup+AF8-entries(+ACY-pvec=
, mapping, index,
+-				min(end - index, (pgoff+AF8-t)PAGEVEC+AF8-SIZE),
+-				indices)) +AHs-
+-		for (i +AD0- 0+ADs- i +ADw- pagevec+AF8-count(+ACY-pvec)+ADs- i+-+-) +A=
Hs-
+-			struct page +ACo-pvec+AF8-ent +AD0- pvec.pages+AFs-i+AF0AOw-
+-			struct page +ACo-page +AD0- NULL+ADs-
+-			void +ACo-entry+ADs-
+-
+-			index +AD0- indices+AFs-i+AF0AOw-
+-			if (index +AD4APQ- end)
+-				break+ADs-
+-
+-			if (+ACE-radix+AF8-tree+AF8-exceptional+AF8-entry(pvec+AF8-ent))
+-				continue+ADs-
+-
+-			spin+AF8-lock+AF8-irq(+ACY-mapping-+AD4-tree+AF8-lock)+ADs-
+-			entry +AD0- get+AF8-unlocked+AF8-mapping+AF8-entry(mapping, index, NUL=
L)+ADs-
+-			if (entry)
+-				page +AD0- dma+AF8-busy+AF8-page(entry)+ADs-
+-			put+AF8-unlocked+AF8-mapping+AF8-entry(mapping, index, entry)+ADs-
+-			spin+AF8-unlock+AF8-irq(+ACY-mapping-+AD4-tree+AF8-lock)+ADs-
+-
+-			if (page +ACYAJg- wait+AF8-on+AF8-devmap+AF8-idle(+ACY-page-+AD4AXw-re=
fcount,
+-						wait+AF8-page,
+-						TASK+AF8-UNINTERRUPTIBLE) +ACEAPQ- 0) +AHs-
+-				/+ACo-
+-				 +ACo- We dropped the dma lock, so we need
+-				 +ACo- to revalidate that previously seen
+-				 +ACo- idle pages are still idle.
+-				 +ACo-/
+-				goto retry+ADs-
+-			+AH0-
+-		+AH0-
+-		pagevec+AF8-remove+AF8-exceptionals(+ACY-pvec)+ADs-
+-		pagevec+AF8-release(+ACY-pvec)+ADs-
+-		index+-+-+ADs-
+-	+AH0-
+-+AH0-
+-EXPORT+AF8-SYMBOL+AF8-GPL(dax+AF8-wait+AF8-dma)+ADs-
+-
 static int +AF8AXw-dax+AF8-invalidate+AF8-mapping+AF8-entry(struct address=
+AF8-space +ACo-mapping,
 					  pgoff+AF8-t index, bool trunc)
 +AHs-
+AEAAQA- -509,8 +-613,10 +AEAAQA- static int +AF8AXw-dax+AF8-invalidate+AF8=
-mapping+AF8-entry(struct address+AF8-space +ACo-mapping,
 out:
 	put+AF8-unlocked+AF8-mapping+AF8-entry(mapping, index, entry)+ADs-
 	spin+AF8-unlock+AF8-irq(+ACY-mapping-+AD4-tree+AF8-lock)+ADs-
+-
 	return ret+ADs-
 +AH0-
+-
 /+ACo-
  +ACo- Delete exceptional DAX entry at +AEA-index from +AEA-mapping. Wait =
for radix tree
  +ACo- entry to get unlocked before deleting it.
diff --git a/fs/inode.c b/fs/inode.c
index d1e35b53bb23..95408e87a96c 100644
--- a/fs/inode.c
+-+-+- b/fs/inode.c
+AEAAQA- -192,6 +-192,7 +AEAAQA- int inode+AF8-init+AF8-always(struct super=
+AF8-block +ACo-sb, struct inode +ACo-inode)
 	inode-+AD4-i+AF8-fsnotify+AF8-mask +AD0- 0+ADs-
 +ACM-endif
 	inode-+AD4-i+AF8-flctx +AD0- NULL+ADs-
+-	i+AF8-daxdma+AF8-init(inode)+ADs-
 	this+AF8-cpu+AF8-inc(nr+AF8-inodes)+ADs-
=20
 	return 0+ADs-
diff --git a/include/linux/dax.h b/include/linux/dax.h
index ea21ebfd1889..6ce1c50519e7 100644
--- a/include/linux/dax.h
+-+-+- b/include/linux/dax.h
+AEAAQA- -100,10 +-100,15 +AEAAQA- int dax+AF8-invalidate+AF8-mapping+AF8-e=
ntry+AF8-sync(struct address+AF8-space +ACo-mapping,
 				      pgoff+AF8-t index)+ADs-
=20
 +ACM-ifdef CONFIG+AF8-FS+AF8-DAX
+-void dax+AF8-wait+AF8-dma(struct address+AF8-space +ACo-mapping, loff+AF8=
-t lstart, loff+AF8-t len)+ADs-
 int +AF8AXw-dax+AF8-zero+AF8-page+AF8-range(struct block+AF8-device +ACo-b=
dev,
 		struct dax+AF8-device +ACo-dax+AF8-dev, sector+AF8-t sector,
 		unsigned int offset, unsigned int length)+ADs-
 +ACM-else
+-static inline void dax+AF8-wait+AF8-dma(struct address+AF8-space +ACo-map=
ping, loff+AF8-t lstart,
+-		loff+AF8-t len)
+-+AHs-
+-+AH0-
 static inline int +AF8AXw-dax+AF8-zero+AF8-page+AF8-range(struct block+AF8=
-device +ACo-bdev,
 		struct dax+AF8-device +ACo-dax+AF8-dev, sector+AF8-t sector,
 		unsigned int offset, unsigned int length)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 13dab191a23e..cd5b4a092d1c 100644
--- a/include/linux/fs.h
+-+-+- b/include/linux/fs.h
+AEAAQA- -645,6 +-645,9 +AEAAQA- struct inode +AHs-
 +ACM-ifdef CONFIG+AF8-IMA
 	atomic+AF8-t		i+AF8-readcount+ADs- /+ACo- struct files open RO +ACo-/
 +ACM-endif
+-+ACM-ifdef CONFIG+AF8-FS+AF8-DAX
+-	struct rw+AF8-semaphore	i+AF8-dax+AF8-dmasem+ADs-
+-+ACM-endif
 	const struct file+AF8-operations	+ACo-i+AF8-fop+ADs-	/+ACo- former -+AD4-=
i+AF8-op-+AD4-default+AF8-file+AF8-ops +ACo-/
 	struct file+AF8-lock+AF8-context	+ACo-i+AF8-flctx+ADs-
 	struct address+AF8-space	i+AF8-data+ADs-
+AEAAQA- -747,6 +-750,59 +AEAAQA- static inline void inode+AF8-lock+AF8-nes=
ted(struct inode +ACo-inode, unsigned subclass)
 	down+AF8-write+AF8-nested(+ACY-inode-+AD4-i+AF8-rwsem, subclass)+ADs-
 +AH0-
=20
+-+ACM-ifdef CONFIG+AF8-FS+AF8-DAX
+-static inline void i+AF8-daxdma+AF8-init(struct inode +ACo-inode)
+-+AHs-
+-	init+AF8-rwsem(+ACY-inode-+AD4-i+AF8-dax+AF8-dmasem)+ADs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-lock(struct inode +ACo-inode)
+-+AHs-
+-	down+AF8-write(+ACY-inode-+AD4-i+AF8-dax+AF8-dmasem)+ADs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-unlock(struct inode +ACo-inode)
+-+AHs-
+-	up+AF8-write(+ACY-inode-+AD4-i+AF8-dax+AF8-dmasem)+ADs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-lock+AF8-shared(struct inode +ACo-ino=
de)
+-+AHs-
+-	/+ACo-
+-	 +ACo- The write lock is taken under mmap+AF8-sem in the
+-	 +ACo- get+AF8-user+AF8-pages() path the read lock nests in the truncate
+-	 +ACo- path.
+-	 +ACo-/
+-+ACM-define DAXDMA+AF8-TRUNCATE+AF8-CLASS 1
+-	down+AF8-read+AF8-nested(+ACY-inode-+AD4-i+AF8-dax+AF8-dmasem, DAXDMA+AF=
8-TRUNCATE+AF8-CLASS)+ADs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-unlock+AF8-shared(struct inode +ACo-i=
node)
+-+AHs-
+-	up+AF8-read(+ACY-inode-+AD4-i+AF8-dax+AF8-dmasem)+ADs-
+-+AH0-
+-+ACM-else /+ACo- CONFIG+AF8-FS+AF8-DAX +ACo-/
+-static inline void i+AF8-daxdma+AF8-init(struct inode +ACo-inode)
+-+AHs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-lock(struct inode +ACo-inode)
+-+AHs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-unlock(struct inode +ACo-inode)
+-+AHs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-lock+AF8-shared(struct inode +ACo-ino=
de)
+-+AHs-
+-+AH0-
+-
+-static inline void i+AF8-daxdma+AF8-unlock+AF8-shared(struct inode +ACo-i=
node)
+-+AHs-
+-+AH0-
+-+ACM-endif /+ACo- CONFIG+AF8-FS+AF8-DAX +ACo-/
+-
 void lock+AF8-two+AF8-nondirectories(struct inode +ACo-, struct inode+ACo-=
)+ADs-
 void unlock+AF8-two+AF8-nondirectories(struct inode +ACo-, struct inode+AC=
o-)+ADs-
=20
diff --git a/include/linux/wait+AF8-bit.h b/include/linux/wait+AF8-bit.h
index 12b26660d7e9..6186ecdb9df7 100644
--- a/include/linux/wait+AF8-bit.h
+-+-+- b/include/linux/wait+AF8-bit.h
+AEAAQA- -30,10 +-30,12 +AEAAQA- int +AF8AXw-wait+AF8-on+AF8-bit(struct wai=
t+AF8-queue+AF8-head +ACo-wq+AF8-head, struct wait+AF8-bit+AF8-queue+AF8-en=
try +ACo-
 int +AF8AXw-wait+AF8-on+AF8-bit+AF8-lock(struct wait+AF8-queue+AF8-head +A=
Co-wq+AF8-head, struct wait+AF8-bit+AF8-queue+AF8-entry +ACo-wbq+AF8-entry,=
 wait+AF8-bit+AF8-action+AF8-f +ACo-action, unsigned int mode)+ADs-
 void wake+AF8-up+AF8-bit(void +ACo-word, int bit)+ADs-
 void wake+AF8-up+AF8-atomic+AF8-t(atomic+AF8-t +ACo-p)+ADs-
+-void wake+AF8-up+AF8-devmap+AF8-idle(atomic+AF8-t +ACo-p)+ADs-
 int out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-bit(void +ACo-word, int, wait+=
AF8-bit+AF8-action+AF8-f +ACo-action, unsigned int mode)+ADs-
 int out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-bit+AF8-timeout(void +ACo-word=
, int, wait+AF8-bit+AF8-action+AF8-f +ACo-action, unsigned int mode, unsign=
ed long timeout)+ADs-
 int out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-bit+AF8-lock(void +ACo-word, i=
nt, wait+AF8-bit+AF8-action+AF8-f +ACo-action, unsigned int mode)+ADs-
 int out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-atomic+AF8-t(atomic+AF8-t +ACo=
-p, int (+ACo-)(atomic+AF8-t +ACo-), unsigned int mode)+ADs-
+-int out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-devmap+AF8-idle(atomic+AF8-t =
+ACo-p, int (+ACo-)(atomic+AF8-t +ACo-), unsigned int mode)+ADs-
 struct wait+AF8-queue+AF8-head +ACo-bit+AF8-waitqueue(void +ACo-word, int =
bit)+ADs-
 extern void +AF8AXw-init wait+AF8-bit+AF8-init(void)+ADs-
=20
+AEAAQA- -258,4 +-260,12 +AEAAQA- int wait+AF8-on+AF8-atomic+AF8-t(atomic+A=
F8-t +ACo-val, int (+ACo-action)(atomic+AF8-t +ACo-), unsigned mode)
 	return out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-atomic+AF8-t(val, action, =
mode)+ADs-
 +AH0-
=20
+-static inline
+-int wait+AF8-on+AF8-devmap+AF8-idle(atomic+AF8-t +ACo-val, int (+ACo-acti=
on)(atomic+AF8-t +ACo-), unsigned mode)
+-+AHs-
+-	might+AF8-sleep()+ADs-
+-	if (atomic+AF8-read(val) +AD0APQ- 1)
+-		return 0+ADs-
+-	return out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-devmap+AF8-idle(val, acti=
on, mode)+ADs-
+-+AH0-
 +ACM-endif /+ACo- +AF8-LINUX+AF8-WAIT+AF8-BIT+AF8-H +ACo-/
diff --git a/kernel/sched/wait+AF8-bit.c b/kernel/sched/wait+AF8-bit.c
index f8159698aa4d..6ea93149614a 100644
--- a/kernel/sched/wait+AF8-bit.c
+-+-+- b/kernel/sched/wait+AF8-bit.c
+AEAAQA- -162,11 +-162,17 +AEAAQA- static inline wait+AF8-queue+AF8-head+AF=
8-t +ACo-atomic+AF8-t+AF8-waitqueue(atomic+AF8-t +ACo-p)
 	return bit+AF8-waitqueue(p, 0)+ADs-
 +AH0-
=20
-static int wake+AF8-atomic+AF8-t+AF8-function(struct wait+AF8-queue+AF8-en=
try +ACo-wq+AF8-entry, unsigned mode, int sync,
-				  void +ACo-arg)
+-static inline struct wait+AF8-bit+AF8-queue+AF8-entry +ACo-to+AF8-wait+AF=
8-bit+AF8-q(
+-		struct wait+AF8-queue+AF8-entry +ACo-wq+AF8-entry)
+-+AHs-
+-	return container+AF8-of(wq+AF8-entry, struct wait+AF8-bit+AF8-queue+AF8-=
entry, wq+AF8-entry)+ADs-
+-+AH0-
+-
+-static int wake+AF8-atomic+AF8-t+AF8-function(struct wait+AF8-queue+AF8-e=
ntry +ACo-wq+AF8-entry,
+-		unsigned mode, int sync, void +ACo-arg)
 +AHs-
 	struct wait+AF8-bit+AF8-key +ACo-key +AD0- arg+ADs-
-	struct wait+AF8-bit+AF8-queue+AF8-entry +ACo-wait+AF8-bit +AD0- container=
+AF8-of(wq+AF8-entry, struct wait+AF8-bit+AF8-queue+AF8-entry, wq+AF8-entry=
)+ADs-
+-	struct wait+AF8-bit+AF8-queue+AF8-entry +ACo-wait+AF8-bit +AD0- to+AF8-w=
ait+AF8-bit+AF8-q(wq+AF8-entry)+ADs-
 	atomic+AF8-t +ACo-val +AD0- key-+AD4-flags+ADs-
=20
 	if (wait+AF8-bit-+AD4-key.flags +ACEAPQ- key-+AD4-flags +AHwAfA-
+AEAAQA- -176,14 +-182,29 +AEAAQA- static int wake+AF8-atomic+AF8-t+AF8-fun=
ction(struct wait+AF8-queue+AF8-entry +ACo-wq+AF8-entry, unsigned mo
 	return autoremove+AF8-wake+AF8-function(wq+AF8-entry, mode, sync, key)+AD=
s-
 +AH0-
=20
+-static int wake+AF8-devmap+AF8-idle+AF8-function(struct wait+AF8-queue+AF=
8-entry +ACo-wq+AF8-entry,
+-		unsigned mode, int sync, void +ACo-arg)
+-+AHs-
+-	struct wait+AF8-bit+AF8-key +ACo-key +AD0- arg+ADs-
+-	struct wait+AF8-bit+AF8-queue+AF8-entry +ACo-wait+AF8-bit +AD0- to+AF8-w=
ait+AF8-bit+AF8-q(wq+AF8-entry)+ADs-
+-	atomic+AF8-t +ACo-val +AD0- key-+AD4-flags+ADs-
+-
+-	if (wait+AF8-bit-+AD4-key.flags +ACEAPQ- key-+AD4-flags +AHwAfA-
+-	    wait+AF8-bit-+AD4-key.bit+AF8-nr +ACEAPQ- key-+AD4-bit+AF8-nr +AHwAf=
A-
+-	    atomic+AF8-read(val) +ACEAPQ- 1)
+-		return 0+ADs-
+-	return autoremove+AF8-wake+AF8-function(wq+AF8-entry, mode, sync, key)+A=
Ds-
+-+AH0-
+-
 /+ACo-
  +ACo- To allow interruptible waiting and asynchronous (i.e. nonblocking) =
waiting,
  +ACo- the actions of +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t() are permitted=
 return codes.  Nonzero
  +ACo- return codes halt waiting and return.
  +ACo-/
 static +AF8AXw-sched
-int +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t(struct wait+AF8-queue+AF8-head +A=
Co-wq+AF8-head, struct wait+AF8-bit+AF8-queue+AF8-entry +ACo-wbq+AF8-entry,
-		       int (+ACo-action)(atomic+AF8-t +ACo-), unsigned mode)
+-int +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t(struct wait+AF8-queue+AF8-head +=
ACo-wq+AF8-head,
+-		struct wait+AF8-bit+AF8-queue+AF8-entry +ACo-wbq+AF8-entry,
+-		int (+ACo-action)(atomic+AF8-t +ACo-), unsigned mode, int target)
 +AHs-
 	atomic+AF8-t +ACo-val+ADs-
 	int ret +AD0- 0+ADs-
+AEAAQA- -191,10 +-212,10 +AEAAQA- int +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t=
(struct wait+AF8-queue+AF8-head +ACo-wq+AF8-head, struct wait+AF8-bit+AF8-q=
ueue+AF8-en
 	do +AHs-
 		prepare+AF8-to+AF8-wait(wq+AF8-head, +ACY-wbq+AF8-entry-+AD4-wq+AF8-entr=
y, mode)+ADs-
 		val +AD0- wbq+AF8-entry-+AD4-key.flags+ADs-
-		if (atomic+AF8-read(val) +AD0APQ- 0)
+-		if (atomic+AF8-read(val) +AD0APQ- target)
 			break+ADs-
 		ret +AD0- (+ACo-action)(val)+ADs-
-	+AH0- while (+ACE-ret +ACYAJg- atomic+AF8-read(val) +ACEAPQ- 0)+ADs-
+-	+AH0- while (+ACE-ret +ACYAJg- atomic+AF8-read(val) +ACEAPQ- target)+ADs=
-
 	finish+AF8-wait(wq+AF8-head, +ACY-wbq+AF8-entry-+AD4-wq+AF8-entry)+ADs-
 	return ret+ADs-
 +AH0-
+AEAAQA- -210,16 +-231,37 +AEAAQA- int +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t=
(struct wait+AF8-queue+AF8-head +ACo-wq+AF8-head, struct wait+AF8-bit+AF8-q=
ueue+AF8-en
 		+AH0-,							+AFw-
 	+AH0-
=20
+-+ACM-define DEFINE+AF8-WAIT+AF8-DEVMAP+AF8-IDLE(name, p)					+AFw-
+-	struct wait+AF8-bit+AF8-queue+AF8-entry name +AD0- +AHs-				+AFw-
+-		.key +AD0- +AF8AXw-WAIT+AF8-ATOMIC+AF8-T+AF8-KEY+AF8-INITIALIZER(p),		+=
AFw-
+-		.wq+AF8-entry +AD0- +AHs-						+AFw-
+-			.private	+AD0- current,			+AFw-
+-			.func		+AD0- wake+AF8-devmap+AF8-idle+AF8-function,	+AFw-
+-			.entry		+AD0-				+AFw-
+-				LIST+AF8-HEAD+AF8-INIT((name).wq+AF8-entry.entry),	+AFw-
+-		+AH0-,							+AFw-
+-	+AH0-
+-
 +AF8AXw-sched int out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-atomic+AF8-t(ato=
mic+AF8-t +ACo-p, int (+ACo-action)(atomic+AF8-t +ACo-),
 					 unsigned mode)
 +AHs-
 	struct wait+AF8-queue+AF8-head +ACo-wq+AF8-head +AD0- atomic+AF8-t+AF8-wa=
itqueue(p)+ADs-
 	DEFINE+AF8-WAIT+AF8-ATOMIC+AF8-T(wq+AF8-entry, p)+ADs-
=20
-	return +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t(wq+AF8-head, +ACY-wq+AF8-entr=
y, action, mode)+ADs-
+-	return +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t(wq+AF8-head, +ACY-wq+AF8-ent=
ry, action, mode, 0)+ADs-
 +AH0-
 EXPORT+AF8-SYMBOL(out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-atomic+AF8-t)+AD=
s-
=20
+-+AF8AXw-sched int out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-devmap+AF8-idle=
(atomic+AF8-t +ACo-p, int (+ACo-action)(atomic+AF8-t +ACo-),
+-					 unsigned mode)
+-+AHs-
+-	struct wait+AF8-queue+AF8-head +ACo-wq+AF8-head +AD0- atomic+AF8-t+AF8-w=
aitqueue(p)+ADs-
+-	DEFINE+AF8-WAIT+AF8-DEVMAP+AF8-IDLE(wq+AF8-entry, p)+ADs-
+-
+-	return +AF8AXw-wait+AF8-on+AF8-atomic+AF8-t(wq+AF8-head, +ACY-wq+AF8-ent=
ry, action, mode, 1)+ADs-
+-+AH0-
+-EXPORT+AF8-SYMBOL(out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-devmap+AF8-idle=
)+ADs-
+-
 /+ACoAKg-
  +ACo- wake+AF8-up+AF8-atomic+AF8-t - Wake up a waiter on a atomic+AF8-t
  +ACo- +AEA-p: The atomic+AF8-t being waited on, a kernel virtual address
+AEAAQA- -235,6 +-277,12 +AEAAQA- void wake+AF8-up+AF8-atomic+AF8-t(atomic+=
AF8-t +ACo-p)
 +AH0-
 EXPORT+AF8-SYMBOL(wake+AF8-up+AF8-atomic+AF8-t)+ADs-
=20
+-void wake+AF8-up+AF8-devmap+AF8-idle(atomic+AF8-t +ACo-p)
+-+AHs-
+-	+AF8AXw-wake+AF8-up+AF8-bit(atomic+AF8-t+AF8-waitqueue(p), p, WAIT+AF8-A=
TOMIC+AF8-T+AF8-BIT+AF8-NR)+ADs-
+-+AH0-
+-EXPORT+AF8-SYMBOL(wake+AF8-up+AF8-devmap+AF8-idle)+ADs-
+-
 +AF8AXw-sched int bit+AF8-wait(struct wait+AF8-bit+AF8-key +ACo-word, int =
mode)
 +AHs-
 	schedule()+ADs-
diff --git a/mm/gup.c b/mm/gup.c
index 308be897d22a..fd7b2a2e2d19 100644
--- a/mm/gup.c
+-+-+- b/mm/gup.c
+AEAAQA- -579,6 +-579,41 +AEAAQA- static int check+AF8-vma+AF8-flags(struct=
 vm+AF8-area+AF8-struct +ACo-vma, unsigned long gup+AF8-flags)
 	return 0+ADs-
 +AH0-
=20
+-static struct inode +ACo-do+AF8-dax+AF8-lock(struct vm+AF8-area+AF8-struc=
t +ACo-vma,
+-		unsigned int foll+AF8-flags)
+-+AHs-
+-	struct file +ACo-file+ADs-
+-	struct inode +ACo-inode+ADs-
+-
+-	if (+ACE-(foll+AF8-flags +ACY- FOLL+AF8-GET))
+-		return NULL+ADs-
+-	if (+ACE-vma+AF8-is+AF8-dax(vma))
+-		return NULL+ADs-
+-	file +AD0- vma-+AD4-vm+AF8-file+ADs-
+-	inode +AD0- file+AF8-inode(file)+ADs-
+-	if (inode-+AD4-i+AF8-mode +AD0APQ- S+AF8-IFCHR)
+-		return NULL+ADs-
+-	return inode+ADs-
+-+AH0-
+-
+-static struct inode +ACo-dax+AF8-truncate+AF8-lock(struct vm+AF8-area+AF8=
-struct +ACo-vma,
+-		unsigned int foll+AF8-flags)
+-+AHs-
+-	struct inode +ACo-inode +AD0- do+AF8-dax+AF8-lock(vma, foll+AF8-flags)+A=
Ds-
+-
+-	if (+ACE-inode)
+-		return NULL+ADs-
+-	i+AF8-daxdma+AF8-lock(inode)+ADs-
+-	return inode+ADs-
+-+AH0-
+-
+-static void dax+AF8-truncate+AF8-unlock(struct inode +ACo-inode)
+-+AHs-
+-	if (+ACE-inode)
+-		return+ADs-
+-	i+AF8-daxdma+AF8-unlock(inode)+ADs-
+-+AH0-
+-
 /+ACoAKg-
  +ACo- +AF8AXw-get+AF8-user+AF8-pages() - pin user pages in memory
  +ACo- +AEA-tsk:	task+AF8-struct of target task
+AEAAQA- -659,6 +-694,7 +AEAAQA- static long +AF8AXw-get+AF8-user+AF8-pages=
(struct task+AF8-struct +ACo-tsk, struct mm+AF8-struct +ACo-mm,
=20
 	do +AHs-
 		struct page +ACo-page+ADs-
+-		struct inode +ACo-inode+ADs-
 		unsigned int foll+AF8-flags +AD0- gup+AF8-flags+ADs-
 		unsigned int page+AF8-increm+ADs-
=20
+AEAAQA- -693,7 +-729,9 +AEAAQA- static long +AF8AXw-get+AF8-user+AF8-pages=
(struct task+AF8-struct +ACo-tsk, struct mm+AF8-struct +ACo-mm,
 		if (unlikely(fatal+AF8-signal+AF8-pending(current)))
 			return i ? i : -ERESTARTSYS+ADs-
 		cond+AF8-resched()+ADs-
+-		inode +AD0- dax+AF8-truncate+AF8-lock(vma, foll+AF8-flags)+ADs-
 		page +AD0- follow+AF8-page+AF8-mask(vma, start, foll+AF8-flags, +ACY-pag=
e+AF8-mask)+ADs-
+-		dax+AF8-truncate+AF8-unlock(inode)+ADs-
 		if (+ACE-page) +AHs-
 			int ret+ADs-
 			ret +AD0- faultin+AF8-page(tsk, vma, start, +ACY-foll+AF8-flags,

commit 67d952314e9989b3b1945c50488f4a0f760264c3
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:   Tue Oct 24 13:41:22 2017 -0700

    xfs: wire up dax dma waiting
   =20
    The dax-dma vs truncate collision avoidance involves acquiring the new
    i+AF8-dax+AF8-dmasem and validating the no ranges that are to be mapped=
 out of
    the file are active for dma. If any are found we wait for page idle
    and retry the scan. The locations where we implement this wait line up
    with where we currently wait for pnfs layout leases to expire.
   =20
    Since we need both dma to be idle and leases to be broken, and since
    xfs+AF8-break+AF8-layouts drops locks, we need to retry the dma busy sc=
an until
    we can complete one that finds no busy pages.
   =20
    Cc: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Cc: Dave Chinner +ADw-david+AEA-fromorbit.com+AD4-
    Cc: +ACI-Darrick J. Wong+ACI- +ADw-darrick.wong+AEA-oracle.com+AD4-
    Cc: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
    Cc: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

diff --git a/fs/xfs/xfs+AF8-file.c b/fs/xfs/xfs+AF8-file.c
index c6780743f8ec..e3ec46c28c60 100644
--- a/fs/xfs/xfs+AF8-file.c
+-+-+- b/fs/xfs/xfs+AF8-file.c
+AEAAQA- -347,7 +-347,7 +AEAAQA- xfs+AF8-file+AF8-aio+AF8-write+AF8-checks(
 		return error+ADs-
=20
 	error +AD0- xfs+AF8-break+AF8-layouts(inode, iolock)+ADs-
-	if (error)
+-	if (error +ADw- 0)
 		return error+ADs-
=20
 	/+ACo-
+AEAAQA- -762,7 +-762,7 +AEAAQA- xfs+AF8-file+AF8-fallocate(
 	struct xfs+AF8-inode	+ACo-ip +AD0- XFS+AF8-I(inode)+ADs-
 	long			error+ADs-
 	enum xfs+AF8-prealloc+AF8-flags	flags +AD0- 0+ADs-
-	uint			iolock +AD0- XFS+AF8-IOLOCK+AF8-EXCL+ADs-
+-	uint			iolock +AD0- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED+ADs-
 	loff+AF8-t			new+AF8-size +AD0- 0+ADs-
 	bool			do+AF8-file+AF8-insert +AD0- 0+ADs-
=20
+AEAAQA- -771,10 +-771,20 +AEAAQA- xfs+AF8-file+AF8-fallocate(
 	if (mode +ACY- +AH4-XFS+AF8-FALLOC+AF8-FL+AF8-SUPPORTED)
 		return -EOPNOTSUPP+ADs-
=20
+-retry:
 	xfs+AF8-ilock(ip, iolock)+ADs-
+-	dax+AF8-wait+AF8-dma(inode-+AD4-i+AF8-mapping, offset, len)+ADs-
+-
+-	xfs+AF8-ilock(ip, XFS+AF8-IOLOCK+AF8-EXCL)+ADs-
+-	iolock +AHwAPQ- XFS+AF8-IOLOCK+AF8-EXCL+ADs-
 	error +AD0- xfs+AF8-break+AF8-layouts(inode, +ACY-iolock)+ADs-
-	if (error)
+-	if (error +ADw- 0)
 		goto out+AF8-unlock+ADs-
+-	else if (error +AD4- 0 +ACYAJg- IS+AF8-ENABLED(CONFIG+AF8-FS+AF8-DAX)) +=
AHs-
+-		xfs+AF8-iunlock(ip, iolock)+ADs-
+-		iolock +AD0- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED+ADs-
+-		goto retry+ADs-
+-	+AH0-
=20
 	xfs+AF8-ilock(ip, XFS+AF8-MMAPLOCK+AF8-EXCL)+ADs-
 	iolock +AHwAPQ- XFS+AF8-MMAPLOCK+AF8-EXCL+ADs-
diff --git a/fs/xfs/xfs+AF8-inode.c b/fs/xfs/xfs+AF8-inode.c
index 4ec5b7f45401..783f15894b7b 100644
--- a/fs/xfs/xfs+AF8-inode.c
+-+-+- b/fs/xfs/xfs+AF8-inode.c
+AEAAQA- -171,7 +-171,14 +AEAAQA- xfs+AF8-ilock+AF8-attr+AF8-map+AF8-shared=
(
  +ACo- taken in places where we need to invalidate the page cache in a rac=
e
  +ACo- free manner (e.g. truncate, hole punch and other extent manipulatio=
n
  +ACo- functions).
- +ACo-/
+- +ACo-
+- +ACo- The XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED lock is a CONFIG+AF8-FS+AF8=
-DAX special case lock
+- +ACo- for synchronizing truncate vs ongoing DMA. The get+AF8-user+AF8-pa=
ges() path
+- +ACo- will hold this lock exclusively when incrementing page reference
+- +ACo- counts for DMA. Before an extent can be truncated we need to compl=
ete
+- +ACo- a validate-idle sweep of all pages in the range while holding this
+- +ACo- lock in shared mode.
+-+ACo-/
 void
 xfs+AF8-ilock(
 	xfs+AF8-inode+AF8-t		+ACo-ip,
+AEAAQA- -192,6 +-199,9 +AEAAQA- xfs+AF8-ilock(
 	       (XFS+AF8-ILOCK+AF8-SHARED +AHw- XFS+AF8-ILOCK+AF8-EXCL))+ADs-
 	ASSERT((lock+AF8-flags +ACY- +AH4-(XFS+AF8-LOCK+AF8-MASK +AHw- XFS+AF8-LO=
CK+AF8-SUBCLASS+AF8-MASK)) +AD0APQ- 0)+ADs-
=20
+-	if (lock+AF8-flags +ACY- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED)
+-		i+AF8-daxdma+AF8-lock+AF8-shared(VFS+AF8-I(ip))+ADs-
+-
 	if (lock+AF8-flags +ACY- XFS+AF8-IOLOCK+AF8-EXCL) +AHs-
 		down+AF8-write+AF8-nested(+ACY-VFS+AF8-I(ip)-+AD4-i+AF8-rwsem,
 				  XFS+AF8-IOLOCK+AF8-DEP(lock+AF8-flags))+ADs-
+AEAAQA- -328,6 +-338,9 +AEAAQA- xfs+AF8-iunlock(
 	else if (lock+AF8-flags +ACY- XFS+AF8-ILOCK+AF8-SHARED)
 		mrunlock+AF8-shared(+ACY-ip-+AD4-i+AF8-lock)+ADs-
=20
+-	if (lock+AF8-flags +ACY- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED)
+-		i+AF8-daxdma+AF8-unlock+AF8-shared(VFS+AF8-I(ip))+ADs-
+-
 	trace+AF8-xfs+AF8-iunlock(ip, lock+AF8-flags, +AF8-RET+AF8-IP+AF8-)+ADs-
 +AH0-
=20
diff --git a/fs/xfs/xfs+AF8-inode.h b/fs/xfs/xfs+AF8-inode.h
index 0ee453de239a..0662edf00529 100644
--- a/fs/xfs/xfs+AF8-inode.h
+-+-+- b/fs/xfs/xfs+AF8-inode.h
+AEAAQA- -283,10 +-283,12 +AEAAQA- static inline void xfs+AF8-ifunlock(stru=
ct xfs+AF8-inode +ACo-ip)
 +ACM-define	XFS+AF8-ILOCK+AF8-SHARED	(1+ADwAPA-3)
 +ACM-define	XFS+AF8-MMAPLOCK+AF8-EXCL	(1+ADwAPA-4)
 +ACM-define	XFS+AF8-MMAPLOCK+AF8-SHARED	(1+ADwAPA-5)
+-+ACM-define	XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED	(1+ADwAPA-6)
=20
 +ACM-define XFS+AF8-LOCK+AF8-MASK		(XFS+AF8-IOLOCK+AF8-EXCL +AHw- XFS+AF8-=
IOLOCK+AF8-SHARED +AFw-
 				+AHw- XFS+AF8-ILOCK+AF8-EXCL +AHw- XFS+AF8-ILOCK+AF8-SHARED +AFw-
-				+AHw- XFS+AF8-MMAPLOCK+AF8-EXCL +AHw- XFS+AF8-MMAPLOCK+AF8-SHARED)
+-				+AHw- XFS+AF8-MMAPLOCK+AF8-EXCL +AHw- XFS+AF8-MMAPLOCK+AF8-SHARED +AF=
w-
+-				+AHw- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED)
=20
 +ACM-define XFS+AF8-LOCK+AF8-FLAGS +AFw-
 	+AHs- XFS+AF8-IOLOCK+AF8-EXCL,	+ACI-IOLOCK+AF8-EXCL+ACI- +AH0-, +AFw-
+AEAAQA- -294,7 +-296,8 +AEAAQA- static inline void xfs+AF8-ifunlock(struct=
 xfs+AF8-inode +ACo-ip)
 	+AHs- XFS+AF8-ILOCK+AF8-EXCL,	+ACI-ILOCK+AF8-EXCL+ACI- +AH0-, +AFw-
 	+AHs- XFS+AF8-ILOCK+AF8-SHARED,	+ACI-ILOCK+AF8-SHARED+ACI- +AH0-, +AFw-
 	+AHs- XFS+AF8-MMAPLOCK+AF8-EXCL,	+ACI-MMAPLOCK+AF8-EXCL+ACI- +AH0-, +AFw-
-	+AHs- XFS+AF8-MMAPLOCK+AF8-SHARED,	+ACI-MMAPLOCK+AF8-SHARED+ACI- +AH0-
+-	+AHs- XFS+AF8-MMAPLOCK+AF8-SHARED,	+ACI-MMAPLOCK+AF8-SHARED+ACI- +AH0-, =
+AFw-
+-	+AHs- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED, +ACI-XFS+AF8-DAXDMA+AF8-LOCK+A=
F8-SHARED+ACI- +AH0-
=20
=20
 /+ACo-
diff --git a/fs/xfs/xfs+AF8-ioctl.c b/fs/xfs/xfs+AF8-ioctl.c
index aa75389be8cf..fd384ea00ede 100644
--- a/fs/xfs/xfs+AF8-ioctl.c
+-+-+- b/fs/xfs/xfs+AF8-ioctl.c
+AEAAQA- -612,7 +-612,7 +AEAAQA- xfs+AF8-ioc+AF8-space(
 	struct xfs+AF8-inode	+ACo-ip +AD0- XFS+AF8-I(inode)+ADs-
 	struct iattr		iattr+ADs-
 	enum xfs+AF8-prealloc+AF8-flags	flags +AD0- 0+ADs-
-	uint			iolock +AD0- XFS+AF8-IOLOCK+AF8-EXCL+ADs-
+-	uint			iolock +AD0- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED+ADs-
 	int			error+ADs-
=20
 	/+ACo-
+AEAAQA- -637,18 +-637,6 +AEAAQA- xfs+AF8-ioc+AF8-space(
 	if (filp-+AD4-f+AF8-mode +ACY- FMODE+AF8-NOCMTIME)
 		flags +AHwAPQ- XFS+AF8-PREALLOC+AF8-INVISIBLE+ADs-
=20
-	error +AD0- mnt+AF8-want+AF8-write+AF8-file(filp)+ADs-
-	if (error)
-		return error+ADs-
-
-	xfs+AF8-ilock(ip, iolock)+ADs-
-	error +AD0- xfs+AF8-break+AF8-layouts(inode, +ACY-iolock)+ADs-
-	if (error)
-		goto out+AF8-unlock+ADs-
-
-	xfs+AF8-ilock(ip, XFS+AF8-MMAPLOCK+AF8-EXCL)+ADs-
-	iolock +AHwAPQ- XFS+AF8-MMAPLOCK+AF8-EXCL+ADs-
-
 	switch (bf-+AD4-l+AF8-whence) +AHs-
 	case 0: /+ACo-SEEK+AF8-SET+ACo-/
 		break+ADs-
+AEAAQA- -659,10 +-647,31 +AEAAQA- xfs+AF8-ioc+AF8-space(
 		bf-+AD4-l+AF8-start +-+AD0- XFS+AF8-ISIZE(ip)+ADs-
 		break+ADs-
 	default:
-		error +AD0- -EINVAL+ADs-
+-		return -EINVAL+ADs-
+-	+AH0-
+-
+-	error +AD0- mnt+AF8-want+AF8-write+AF8-file(filp)+ADs-
+-	if (error)
+-		return error+ADs-
+-
+-retry:
+-	xfs+AF8-ilock(ip, iolock)+ADs-
+-	dax+AF8-wait+AF8-dma(inode-+AD4-i+AF8-mapping, bf-+AD4-l+AF8-start, bf-+=
AD4-l+AF8-len)+ADs-
+-
+-	xfs+AF8-ilock(ip, XFS+AF8-IOLOCK+AF8-EXCL)+ADs-
+-	iolock +AHwAPQ- XFS+AF8-IOLOCK+AF8-EXCL+ADs-
+-	error +AD0- xfs+AF8-break+AF8-layouts(inode, +ACY-iolock)+ADs-
+-	if (error +ADw- 0)
 		goto out+AF8-unlock+ADs-
+-	else if (error +AD4- 0 +ACYAJg- IS+AF8-ENABLED(CONFIG+AF8-FS+AF8-DAX)) +=
AHs-
+-		xfs+AF8-iunlock(ip, iolock)+ADs-
+-		iolock +AD0- XFS+AF8-DAXDMA+AF8-LOCK+AF8-SHARED+ADs-
+-		goto retry+ADs-
 	+AH0-
=20
+-	xfs+AF8-ilock(ip, XFS+AF8-MMAPLOCK+AF8-EXCL)+ADs-
+-	iolock +AHwAPQ- XFS+AF8-MMAPLOCK+AF8-EXCL+ADs-
+-
 	/+ACo-
 	 +ACo- length of +ADwAPQ- 0 for resv/unresv/zero is invalid.  length for
 	 +ACo- alloc/free is ignored completely and we have no idea what userspac=
e
diff --git a/fs/xfs/xfs+AF8-pnfs.c b/fs/xfs/xfs+AF8-pnfs.c
index 4246876df7b7..5f4d46b3cd7f 100644
--- a/fs/xfs/xfs+AF8-pnfs.c
+-+-+- b/fs/xfs/xfs+AF8-pnfs.c
+AEAAQA- -35,18 +-35,19 +AEAAQA- xfs+AF8-break+AF8-layouts(
 	uint			+ACo-iolock)
 +AHs-
 	struct xfs+AF8-inode	+ACo-ip +AD0- XFS+AF8-I(inode)+ADs-
-	int			error+ADs-
+-	int			error, did+AF8-unlock +AD0- 0+ADs-
=20
 	ASSERT(xfs+AF8-isilocked(ip, XFS+AF8-IOLOCK+AF8-SHARED+AHw-XFS+AF8-IOLOCK=
+AF8-EXCL))+ADs-
=20
 	while ((error +AD0- break+AF8-layout(inode, false) +AD0APQ- -EWOULDBLOCK)=
) +AHs-
 		xfs+AF8-iunlock(ip, +ACo-iolock)+ADs-
+-		did+AF8-unlock +AD0- 1+ADs-
 		error +AD0- break+AF8-layout(inode, true)+ADs-
 		+ACo-iolock +AD0- XFS+AF8-IOLOCK+AF8-EXCL+ADs-
 		xfs+AF8-ilock(ip, +ACo-iolock)+ADs-
 	+AH0-
=20
-	return error+ADs-
+-	return error +ADw- 0 ? error : did+AF8-unlock+ADs-
 +AH0-
=20
 /+ACo-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
