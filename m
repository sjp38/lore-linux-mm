Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE926B0397
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:10:48 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id a185so56890308ioe.13
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:10:48 -0700 (PDT)
Received: from fldsmtpe03.verizon.com (fldsmtpe03.verizon.com. [140.108.26.142])
        by mx.google.com with ESMTPS id r23si14531216ioi.218.2017.04.10.08.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 08:10:47 -0700 (PDT)
From: alexander.levin@verizon.com
Subject: Re: [patch 1/3] mm: protect set_page_dirty() from ongoing truncation
Date: Mon, 10 Apr 2017 15:07:58 +0000
Message-ID: <20170410150755.kd2gjqyfmvschtxd@sasha-lappy>
References: <1417791166-32226-1-git-send-email-hannes@cmpxchg.org>
 <20170410022230.xe5sukvflvoh4ula@sasha-lappy>
 <20170410120638.GD3224@quack2.suse.cz>
In-Reply-To: <20170410120638.GD3224@quack2.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7C5DAAEEC8E1DC4D871FE18EF9EF3D30@vzwcorp.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Apr 10, 2017 at 02:06:38PM +0200, Jan Kara wrote:
> On Mon 10-04-17 02:22:33, alexander.levin@verizon.com wrote:
> > On Fri, Dec 05, 2014 at 09:52:44AM -0500, Johannes Weiner wrote:
> > > Tejun, while reviewing the code, spotted the following race condition
> > > between the dirtying and truncation of a page:
> > >=20
> > > __set_page_dirty_nobuffers()       __delete_from_page_cache()
> > >   if (TestSetPageDirty(page))
> > >                                      page->mapping =3D NULL
> > > 				     if (PageDirty())
> > > 				       dec_zone_page_state(page, NR_FILE_DIRTY);
> > > 				       dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> > >     if (page->mapping)
> > >       account_page_dirtied(page)
> > >         __inc_zone_page_state(page, NR_FILE_DIRTY);
> > > 	__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> > >=20
> > > which results in an imbalance of NR_FILE_DIRTY and BDI_RECLAIMABLE.
> > >=20
> > > Dirtiers usually lock out truncation, either by holding the page lock
> > > directly, or in case of zap_pte_range(), by pinning the mapcount with
> > > the page table lock held.  The notable exception to this rule, though=
,
> > > is do_wp_page(), for which this race exists.  However, do_wp_page()
> > > already waits for a locked page to unlock before setting the dirty
> > > bit, in order to prevent a race where clear_page_dirty() misses the
> > > page bit in the presence of dirty ptes.  Upgrade that wait to a fully
> > > locked set_page_dirty() to also cover the situation explained above.
> > >=20
> > > Afterwards, the code in set_page_dirty() dealing with a truncation
> > > race is no longer needed.  Remove it.
> > >=20
> > > Reported-by: Tejun Heo <tj@kernel.org>
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: <stable@vger.kernel.org>
> > > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >=20
> > Hi Johannes,
> >=20
> > I'm seeing the following while fuzzing with trinity on linux-next (I've=
 changed
> > the WARN to a VM_BUG_ON_PAGE for some extra page info).
>=20
> But this looks more like a bug in 9p which allows v9fs_write_end() to dir=
ty
> a !Uptodate page?

I thought that 77469c3f5 ("9p: saner ->write_end() on failing copy into
non-uptodate page") prevented from that happening, but that's actually the
change that's causing it (I ended up misreading it last night).

Will fix it as follows:

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c=20
index adaf6f6..be84c0c 100644=20
--- a/fs/9p/vfs_addr.c=20
+++ b/fs/9p/vfs_addr.c=20
@@ -310,9 +310,13 @@ static int v9fs_write_end(struct file *filp, struct ad=
dress_space *mapping,=20
 =20
        p9_debug(P9_DEBUG_VFS, "filp %p, mapping %p\n", filp, mapping);=20
 =20
-       if (unlikely(copied < len && !PageUptodate(page))) {=20
-               copied =3D 0;=20
-               goto out;=20
+       if (!PageUptodate(page)) {=20
+               if (unlikely(copied < len)) {=20
+                       copied =3D 0;
+                       goto out;=20
+               } else {=20
+                       SetPageUptodate(page);=20
+               }=20
        }=20
        /*=20
         * No need to use i_size_read() here, the i_size
=20
--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
