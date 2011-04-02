Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5147F8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 23:39:25 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p323dLtD025104
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:39:21 -0700
Received: from yie30 (yie30.prod.google.com [10.243.66.30])
	by wpaz33.hot.corp.google.com with ESMTP id p323dKaC008166
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:39:20 -0700
Received: by yie30 with SMTP id 30so1919699yie.23
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 20:39:20 -0700 (PDT)
Date: Fri, 1 Apr 2011 20:39:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ramfs: fix memleak on no-mmu arch
In-Reply-To: <AANLkTikN2DFtZWTR=+Fq8GWaXJLaQOFuUsmYQLTo04Hd@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1104012036460.3340@sister.anvils>
References: <1301290355-8980-1-git-send-email-lliubbo@gmail.com> <20110328170220.fc61fb5c.akpm@linux-foundation.org> <AANLkTikN2DFtZWTR=+Fq8GWaXJLaQOFuUsmYQLTo04Hd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-735827335-1301715570=:3340"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, dhowells@redhat.com, lethal@linux-sh.org, magnus.damm@gmail.com, Mike Frysinger <vapier@gentoo.org>, horms@verge.net.au, gerg@uclinux.org, ithamar.adema@team-embedded.nl

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-735827335-1301715570=:3340
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 1 Apr 2011, Bob Liu wrote:
> Hi, Andrew
>=20
> cc'd some folks working on nommu.
>=20
> On Tue, Mar 29, 2011 at 8:02 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Mon, 28 Mar 2011 13:32:35 +0800
> > Bob Liu <lliubbo@gmail.com> wrote:
> >
> >> On no-mmu arch, there is a memleak duirng shmem test.
> >> The cause of this memleak is ramfs_nommu_expand_for_mapping() added pa=
ge
> >> refcount to 2 which makes iput() can't free that pages.
> >>
> >> The simple test file is like this:
> >> int main(void)
> >> {
> >> =C2=A0 =C2=A0 =C2=A0 int i;
> >> =C2=A0 =C2=A0 =C2=A0 key_t k =3D ftok("/etc", 42);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 for ( i=3D0; i<100; ++i) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int id =3D shmget(k, =
10000, 0644|IPC_CREAT);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (id =3D=3D -1) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 printf("shmget error\n");
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if(shmctl(id, IPC_RMI=
D, NULL ) =3D=3D -1) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 printf("shm =C2=A0rm error\n");
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return -1;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 printf("run ok...\n");
> >> =C2=A0 =C2=A0 =C2=A0 return 0;
> >> }
> >>
> >> ...
> >>
> >> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
> >> index 9eead2c..fbb0b47 100644
> >> --- a/fs/ramfs/file-nommu.c
> >> +++ b/fs/ramfs/file-nommu.c
> >> @@ -112,6 +112,7 @@ int ramfs_nommu_expand_for_mapping(struct inode *i=
node, size_t newsize)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageDirty(page);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page(page);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(page);
> >> =C2=A0 =C2=A0 =C2=A0 }
> >>
> >> =C2=A0 =C2=A0 =C2=A0 return 0;
> >
> > Something is still wrong here.
> >
> > A live, in-use page should have a refcount of three. =C2=A0One for the
> > existence of the page, one for its presence on the page LRU and one for
> > its existence in the pagecache radix tree.
> >
> > So allocation should do:
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0alloc_pages()
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_page_cache()
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_lru()
> >
> > and deallocation should do
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_lru()
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_page_cache()
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0put_page()
> >
> > If this protocol is followed correctly, there is no need to do a
> > put_page() during the allocation/setup phase!
> >
> > I suspect that the problem in nommu really lies in the
> > deallocation/teardown phase.
> >
>=20
> What about below patch ?
>=20
> BTW: It seems that in MMU cases shmem pages are freed during memory recla=
im,
> since I didn't find the direct free place.
> I am not sure maybe I got something wrong ?
>=20
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

No, I really think this ramfs_evict_inode() thing is a quite
unnecessary complication: your little put_page() patch much nicer.

Hugh

> ---
>  fs/ramfs/file-nommu.c |    1 +
>  fs/ramfs/inode.c      |   22 ++++++++++++++++++++++
>  2 files changed, 23 insertions(+), 0 deletions(-)
>=20
> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
> index fbb0b47..11f48eb 100644
> --- a/fs/ramfs/file-nommu.c
> +++ b/fs/ramfs/file-nommu.c
> @@ -114,6 +114,7 @@ int ramfs_nommu_expand_for_mapping(struct inode
> *inode, size_t newsize)
>  =09=09unlock_page(page);
>  =09=09put_page(page);
>  =09}
> +=09inode->i_private =3D pages;
>=20
>  =09return 0;
>=20
> diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
> index eacb166..e446d9f 100644
> --- a/fs/ramfs/inode.c
> +++ b/fs/ramfs/inode.c
> @@ -151,9 +151,31 @@ static const struct inode_operations
> ramfs_dir_inode_operations =3D {
>  =09.rename=09=09=3D simple_rename,
>  };
>=20
> +#ifndef CONFIG_MMU
> +static void ramfs_evict_inode(struct inode *inode)
> +{
> +=09int i;
> +=09struct page *free_pages =3D (struct page *)inode->i_private;
> +
> +=09/*
> +=09 * for nommu arch, need an extra put_page so that pages gotten
> +=09 * by ramfs_nommu_expand_for_mapping() can be freed
> +=09 */
> +=09for (i =3D 0; i < inode->i_data.nrpages; i++)
> +=09=09put_page(free_pages + i);
> +
> +=09if (inode->i_data.nrpages)
> +=09=09truncate_inode_pages(&inode->i_data, 0);
> +=09end_writeback(inode);
> +}
> +#endif
> +
>  static const struct super_operations ramfs_ops =3D {
>  =09.statfs=09=09=3D simple_statfs,
>  =09.drop_inode=09=3D generic_delete_inode,
> +#ifndef CONFIG_MMU
> +=09.evict_inode    =3D ramfs_evict_inode,
> +#endif
>  =09.show_options=09=3D generic_show_options,
>  };
>=20
> --=20
> 1.6.3.3
--8323584-735827335-1301715570=:3340--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
