Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 6F3156B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 14:27:50 -0400 (EDT)
Date: Thu, 1 Aug 2013 11:27:49 -0700 (PDT)
From: Sage Weil <sage@inktank.com>
Subject: Re: [PATCH V5 2/8] fs/ceph: vfs __set_page_dirty_nobuffers interface
 instead of doing it inside filesystem
In-Reply-To: <CAAM7YAmxmmA6g2WPVtGN1-42rtDBYzLhF-gvNXxcBN6dUveBYQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1308011121080.22584@cobra.newdream.net>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com> <1375357892-10188-1-git-send-email-handai.szj@taobao.com> <CAAM7YAmxmmA6g2WPVtGN1-42rtDBYzLhF-gvNXxcBN6dUveBYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="557981400-154103058-1375381669=:22584"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <ukernel@gmail.com>
Cc: Sha Zhengju <handai.szj@gmail.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@taobao.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--557981400-154103058-1375381669=:22584
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, 1 Aug 2013, Yan, Zheng wrote:
> On Thu, Aug 1, 2013 at 7:51 PM, Sha Zhengju <handai.szj@gmail.com> wrot=
e:
> > From: Sha Zhengju <handai.szj@taobao.com>
> >
> > Following we will begin to add memcg dirty page accounting around
> __set_page_dirty_
> > {buffers,nobuffers} in vfs layer, so we'd better use vfs interface to
> avoid exporting
> > those details to filesystems.
> >
> > Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> > ---
> > =A0fs/ceph/addr.c | =A0 13 +------------
> > =A01 file changed, 1 insertion(+), 12 deletions(-)
> >
> > diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> > index 3e68ac1..1445bf1 100644
> > --- a/fs/ceph/addr.c
> > +++ b/fs/ceph/addr.c
> > @@ -76,7 +76,7 @@ static int ceph_set_page_dirty(struct page *page)
> > =A0 =A0 =A0 =A0 if (unlikely(!mapping))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return !TestSetPageDirty(page);
> >
> > - =A0 =A0 =A0 if (TestSetPageDirty(page)) {
> > + =A0 =A0 =A0 if (!__set_page_dirty_nobuffers(page)) {
> it's too early to set the radix tree tag here. We should set page's sna=
pshot
> context and increase the i_wrbuffer_ref first. This is because once the=
 tag
> is set, writeback thread can find and start flushing the page.

Unfortunately I only remember being frustrated by this code.  :)  Looking=
=20
at it now, though, it seems like the minimum fix is to set the=20
page->private before marking the page dirty.  I don't know the locking=20
rules around that, though.  If that is potentially racy, maybe the safest=
=20
thing would be if __set_page_dirty_nobuffers() took a void* to set=20
page->private to atomically while holding the tree_lock.

sage

>=20
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dout("%p set_page_dirty %p idx %lu --=
 already dirty\n",
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mapping->host, page, page-=
>index);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> > @@ -107,14 +107,7 @@ static int ceph_set_page_dirty(struct page *page=
)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0snapc, snapc->seq, snapc->num_snaps);
> > =A0 =A0 =A0 =A0 spin_unlock(&ci->i_ceph_lock);
> >
> > - =A0 =A0 =A0 /* now adjust page */
> > - =A0 =A0 =A0 spin_lock_irq(&mapping->tree_lock);
> > =A0 =A0 =A0 =A0 if (page->mapping) { =A0 =A0/* Race with truncate? */
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(!PageUptodate(page));
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 account_page_dirtied(page, page->mappin=
g);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 radix_tree_tag_set(&mapping->page_tree,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_in=
dex(page), PAGECACHE_TAG_DIRTY);
> > -
>=20
> this code was coped from __set_page_dirty_nobuffers(). I think the reas=
on
> Sage did this is to handle the race described in
> __set_page_dirty_nobuffers()'s comment. But I'm wonder if "page->mappin=
g =3D=3D
> NULL" can still happen here. Because truncate_inode_page() unmap page f=
rom
> processes's address spaces first, then delete page from page cache.
>=20
> Regards
> Yan, Zheng
>=20
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Reference snap context in page->=
private. =A0Also set
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* PagePrivate so that we get inval=
idatepage callback.
> > @@ -126,14 +119,10 @@ static int ceph_set_page_dirty(struct page *pag=
e)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 undo =3D 1;
> > =A0 =A0 =A0 =A0 }
> >
> > - =A0 =A0 =A0 spin_unlock_irq(&mapping->tree_lock);
>=20
>=20
>=20
>=20
> > -
> > =A0 =A0 =A0 =A0 if (undo)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* whoops, we failed to dirty the pag=
e */
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ceph_put_wrbuffer_cap_refs(ci, 1, sna=
pc);
> >
> > - =A0 =A0 =A0 __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> > -
> > =A0 =A0 =A0 =A0 BUG_ON(!PageDirty(page));
> > =A0 =A0 =A0 =A0 return 1;
> > =A0}
> > --
> > 1.7.9.5
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe ceph-devel"=
 in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>=20
>=20
>=20
--557981400-154103058-1375381669=:22584--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
