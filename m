Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 79E366B01AD
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 02:03:25 -0400 (EDT)
Received: by iwn39 with SMTP id 39so1197434iwn.14
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 23:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100528173510.GA12166@ca-server1.us.oracle.com>
References: <20100528173510.GA12166@ca-server1.us.oracle.com>
Date: Wed, 2 Jun 2010 15:03:22 +0900
Message-ID: <AANLkTilV-4_QaNq5O0WSplDx1Oq7JvkgVrEiR1rgf1up@mail.gmail.com>
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

Hello.

I think cleancache approach is cool. :)
I have some suggestions and questions.

On Sat, May 29, 2010 at 2:35 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
>
> Changes since V1:
> - Rebased to 2.6.34 (no functional changes)
> - Convert to sane types (Al Viro)
> - Define some raw constants (Konrad Wilk)
> - Add ack from Andreas Dilger
>
> In previous patch postings, cleancache was part of the Transcendent
> Memory ("tmem") patchset. =C2=A0This patchset refocuses not on the underl=
ying
> technology (tmem) but instead on the useful functionality provided for Li=
nux,
> and provides a clean API so that cleancache can provide this very useful
> functionality either via a Xen tmem driver OR completely independent of t=
mem.
> For example: Nitin Gupta (of compcache and ramzswap fame) is implementing
> an in-kernel compression "backend" for cleancache; some believe
> cleancache will be a very nice interface for building RAM-like functional=
ity
> for pseudo-RAM devices such as SSD or phase-change memory; and a Pune
> University team is looking at a backend for virtio (see OLS'2010).
>
> A more complete description of cleancache can be found in the introductor=
y
> comment in mm/cleancache.c (in PATCH 2/7) which is included below
> for convenience.
>
> Note that an earlier version of this patch is now shipping in OpenSuSE 11=
.2
> and will soon ship in a release of Oracle Enterprise Linux. =C2=A0Underly=
ing
> tmem technology is now shipping in Oracle VM 2.2 and was just released
> in Xen 4.0 on April 15, 2010. =C2=A0(Search news.google.com for Transcend=
ent
> Memory)
>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Jeremy Fitzhardinge <jeremy@goop.org>
>
> =C2=A0fs/btrfs/extent_io.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A09 +
> =C2=A0fs/btrfs/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
2
> =C2=A0fs/buffer.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 =C2=A05 +
> =C2=A0fs/ext3/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =
=C2=A02
> =C2=A0fs/ext4/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =
=C2=A02
> =C2=A0fs/mpage.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 =C2=A07 +
> =C2=A0fs/ocfs2/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
3
> =C2=A0fs/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 =C2=A08 +
> =C2=A0include/linux/cleancache.h | =C2=A0 90 +++++++++++++++++++
> =C2=A0include/linux/fs.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A05 +
> =C2=A0mm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 22 ++++
> =C2=A0mm/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 =C2=A01
> =C2=A0mm/cleancache.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A020=
3 +++++++++++++++++++++++++++++++++++++++++++++
> =C2=A0mm/filemap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 11 ++
> =C2=A0mm/truncate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 10 ++
> =C2=A015 files changed, 380 insertions(+)
>
> Cleancache can be thought of as a page-granularity victim cache for clean
> pages that the kernel's pageframe replacement algorithm (PFRA) would like
> to keep around, but can't since there isn't enough memory. =C2=A0So when =
the
> PFRA "evicts" a page, it first attempts to put it into a synchronous
> concurrency-safe page-oriented pseudo-RAM device (such as Xen's Transcend=
ent
> Memory, aka "tmem", or in-kernel compressed memory, aka "zmem", or other
> RAM-like devices) which is not directly accessible or addressable by the
> kernel and is of unknown and possibly time-varying size. =C2=A0And when a
> cleancache-enabled filesystem wishes to access a page in a file on disk,
> it first checks cleancache to see if it already contains it; if it does,
> the page is copied into the kernel and a disk access is avoided.
> This pseudo-RAM device links itself to cleancache by setting the
> cleancache_ops pointer appropriately and the functions it provides must
> conform to certain semantics as follows:
>
> Most important, cleancache is "ephemeral". =C2=A0Pages which are copied i=
nto
> cleancache have an indefinite lifetime which is completely unknowable
> by the kernel and so may or may not still be in cleancache at any later t=
ime.
> Thus, as its name implies, cleancache is not suitable for dirty pages. =
=C2=A0The
> pseudo-RAM has complete discretion over what pages to preserve and what
> pages to discard and when.
>
> A filesystem calls "init_fs" to obtain a pool id which, if positive, must=
 be
> saved in the filesystem's superblock; a negative return value indicates
> failure. =C2=A0A "put_page" will copy a (presumably about-to-be-evicted) =
page into
> pseudo-RAM and associate it with the pool id, the file inode, and a page
> index into the file. =C2=A0(The combination of a pool id, an inode, and a=
n index
> is called a "handle".) =C2=A0A "get_page" will copy the page, if found, f=
rom
> pseudo-RAM into kernel memory. =C2=A0A "flush_page" will ensure the page =
no longer
> is present in pseudo-RAM; a "flush_inode" will flush all pages associated
> with the specified inode; and a "flush_fs" will flush all pages in all
> inodes specified by the given pool id.
>
> A "init_shared_fs", like init, obtains a pool id but tells the pseudo-RAM
> to treat the pool as shared using a 128-bit UUID as a key. =C2=A0On syste=
ms
> that may run multiple kernels (such as hard partitioned or virtualized
> systems) that may share a clustered filesystem, and where the pseudo-RAM
> may be shared among those kernels, calls to init_shared_fs that specify t=
he
> same UUID will receive the same pool id, thus allowing the pages to
> be shared. =C2=A0Note that any security requirements must be imposed outs=
ide
> of the kernel (e.g. by "tools" that control the pseudo-RAM). =C2=A0Or a
> pseudo-RAM implementation can simply disable shared_init by always
> returning a negative value.
>
> If a get_page is successful on a non-shared pool, the page is flushed (th=
us
> making cleancache an "exclusive" cache). =C2=A0On a shared pool, the page

Do you have any reason about force "exclusive" on a non-shared pool?
To free memory on pesudo-RAM?
I want to make it "inclusive" by some reason but unfortunately I can't
say why I want it now.

While you mentioned it's "exclusive", cleancache_get_page doesn't
flush the page at below code.
Is it a role of user who implement cleancache_ops->get_page?

+int __cleancache_get_page(struct page *page)
+{
+       int ret =3D 0;
+       int pool_id =3D page->mapping->host->i_sb->cleancache_poolid;
+
+       if (pool_id >=3D 0) {
+               ret =3D (*cleancache_ops->get_page)(pool_id,
+                                                 page->mapping->host->i_in=
o,
+                                                 page->index,
+                                                 page);
+               if (ret =3D=3D CLEANCACHE_GET_PAGE_SUCCESS)
+                       succ_gets++;
+               else
+                       failed_gets++;
+       }
+       return ret;
+}
+EXPORT_SYMBOL(__cleancache_get_page);

If backed device is ram(ie), Could we _move_ the pages from page cache
to cleancache?
I mean I don't want to copy page when get/put operation. we can just
move page in case of backed device "ram". Is it possible?

You send the patches which is core of cleancache but I don't see any use ca=
se.
Could you send use case patches with this series?
It could help understand cleancache's benefit.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
