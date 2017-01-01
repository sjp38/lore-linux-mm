Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 447CC6B0038
	for <linux-mm@kvack.org>; Sat, 31 Dec 2016 21:57:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 127so372419669pfg.5
        for <linux-mm@kvack.org>; Sat, 31 Dec 2016 18:57:59 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r90si36734627pfk.118.2016.12.31.18.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 Dec 2016 18:57:58 -0800 (PST)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: [GIT PULL] dax final updates and fixes for 4.10-rc2
Date: Sun, 1 Jan 2017 02:57:56 +0000
Message-ID: <1483239473.2943.17.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <AF13CB2738A7EF44A4F4026C2D15AAF2@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jack@suse.cz" <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

Hi Linus, please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm libnvdimm-fix=
es

...to receive the completion of Jan's DAX work for 4.10.

As I mentioned in the libnvdimm-for-4.10 pull request +AFs-1+AF0-, these ar=
e
some final fixes for the DAX dirty-cacheline-tracking invalidation work
that was merged through the -mm, ext4, and xfs trees in -rc1. These
patches were prepared prior to the merge window, but we waited for
4.10-rc1 to have a stable merge base after all the prerequisites were
merged.

Quoting Jan on the overall changes in these patches:

    So I'd like all these 6 patches to go for rc2. The first three
    patches fix invalidation of exceptional DAX entries (a bug which is
    there for a long time) - without these patches data loss can occur
    on power failure even though user called fsync(2). The other three
    patches change locking of DAX faults so that -+AD4-iomap+AF8-begin() is
    called in a more relaxed locking context and we are safe to start a
    transaction there for ext4.

These have received a build success notification from the kbuild robot,
and pass the latest libnvdimm unit tests. There have not been any -next
releases since -rc1, so they have not appeared there.

+AFs-1+AF0-:+AKA-https://lists.01.org/pipermail/linux-nvdimm/2016-December/=
008279.h
tml

---

The following changes since commit 7ce7d89f48834cefece7804d38fc5d85382edf77=
:

  Linux 4.10-rc1 (2016-12-25 16:13:08 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm libnvdimm-fix=
es

for you to fetch changes up to 1db175428ee374489448361213e9c3b749d14900:

  ext4: Simplify DAX fault path (2016-12-26 20:29:25 -0800)

----------------------------------------------------------------
Jan Kara (6):
      ext2: Return BH+AF8-New buffers for zeroed blocks
      mm: Invalidate DAX radix tree entries only if appropriate
      dax: Avoid page invalidation races and unnecessary radix tree travers=
als
      dax: Finish fault completely when loading holes
      dax: Call -+AD4-iomap+AF8-begin without entry lock during dax fault
      ext4: Simplify DAX fault path

 fs/dax.c            +AHw- 243 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+-+-+-+-+-+-+-+-+-+-+--------------------
 fs/ext2/inode.c     +AHw-   3 +--
 fs/ext4/file.c      +AHw-  48 +-+-+---------
 include/linux/dax.h +AHw-   3 +-
 mm/truncate.c       +AHw-  75 +-+-+-+-+-+-+-+-+-+-+-+-+----
 5 files changed, 229 insertions(+-), 143 deletions(-)

commit e568df6b84ff05a22467503afc11bee7a6ba0700
Author: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Date:   Wed Aug 10 16:42:53 2016 +-0200

    ext2: Return BH+AF8-New buffers for zeroed blocks
   =20
    So far we did not return BH+AF8-New buffers from ext2+AF8-get+AF8-block=
s() when we
    allocated and zeroed-out a block for DAX inode to avoid racy zeroing in
    DAX code. This zeroing is gone these days so we can remove the
    workaround.
   =20
    Reviewed-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
    Reviewed-by: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
    Signed-off-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

commit c6dcf52c23d2d3fb5235cec42d7dd3f786b87d55
Author: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Date:   Wed Aug 10 17:22:44 2016 +-0200

    mm: Invalidate DAX radix tree entries only if appropriate
   =20
    Currently invalidate+AF8-inode+AF8-pages2+AF8-range() and invalidate+AF=
8-mapping+AF8-pages()
    just delete all exceptional radix tree entries they find. For DAX this
    is not desirable as we track cache dirtiness in these entries and when
    they are evicted, we may not flush caches although it is necessary. Thi=
s
    can for example manifest when we write to the same block both via mmap
    and via write(2) (to different offsets) and fsync(2) then does not
    properly flush CPU caches when modification via write(2) was the last
    one.
   =20
    Create appropriate DAX functions to handle invalidation of DAX entries
    for invalidate+AF8-inode+AF8-pages2+AF8-range() and invalidate+AF8-mapp=
ing+AF8-pages() and
    wire them up into the corresponding mm functions.
   =20
    Acked-by: Johannes Weiner +ADw-hannes+AEA-cmpxchg.org+AD4-
    Reviewed-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
    Signed-off-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

commit e3fce68cdbed297d927e993b3ea7b8b1cee545da
Author: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Date:   Wed Aug 10 17:10:28 2016 +-0200

    dax: Avoid page invalidation races and unnecessary radix tree traversal=
s
   =20
    Currently dax+AF8-iomap+AF8-rw() takes care of invalidating page tables=
 and
    evicting hole pages from the radix tree when write(2) to the file
    happens. This invalidation is only necessary when there is some block
    allocation resulting from write(2). Furthermore in current place the
    invalidation is racy wrt page fault instantiating a hole page just afte=
r
    we have invalidated it.
   =20
    So perform the page invalidation inside dax+AF8-iomap+AF8-actor() where=
 we can
    do it only when really necessary and after blocks have been allocated s=
o
    nobody will be instantiating new hole pages anymore.
   =20
    Reviewed-by: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
    Reviewed-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
    Signed-off-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

commit f449b936f1aff7696b24a338f493d5cee8d48d55
Author: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Date:   Wed Oct 19 14:48:38 2016 +-0200

    dax: Finish fault completely when loading holes
   =20
    The only case when we do not finish the page fault completely is when w=
e
    are loading hole pages into a radix tree. Avoid this special case and
    finish the fault in that case as well inside the DAX fault handler. It
    will allow us for easier iomap handling.
   =20
    Reviewed-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
    Signed-off-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

commit 9f141d6ef6258a3a37a045842d9ba7e68f368956
Author: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Date:   Wed Oct 19 14:34:31 2016 +-0200

    dax: Call -+AD4-iomap+AF8-begin without entry lock during dax fault
   =20
    Currently -+AD4-iomap+AF8-begin() handler is called with entry lock hel=
d. If the
    filesystem held any locks between -+AD4-iomap+AF8-begin() and -+AD4-iom=
ap+AF8-end()
    (such as ext4 which will want to hold transaction open), this would cau=
se
    lock inversion with the iomap+AF8-apply() from standard IO path which f=
irst
    calls -+AD4-iomap+AF8-begin() and only then calls -+AD4-actor() callbac=
k which grabs
    entry locks for DAX (if it faults when copying from/to user provided
    buffers).
   =20
    Fix the problem by nesting grabbing of entry lock inside -+AD4-iomap+AF=
8-begin()
    - -+AD4-iomap+AF8-end() pair.
   =20
    Reviewed-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
    Signed-off-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

commit 1db175428ee374489448361213e9c3b749d14900
Author: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Date:   Fri Oct 21 11:33:49 2016 +-0200

    ext4: Simplify DAX fault path
   =20
    Now that dax+AF8-iomap+AF8-fault() calls -+AD4-iomap+AF8-begin() withou=
t entry lock, we
    can use transaction starting in ext4+AF8-iomap+AF8-begin() and thus sim=
plify
    ext4+AF8-dax+AF8-fault(). It also provides us proper retries in case of=
 ENOSPC.
   =20
    Signed-off-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
    Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
