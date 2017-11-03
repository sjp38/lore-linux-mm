Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0C766B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 12:02:34 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j126so3197858oib.9
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 09:02:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 73si3562154oik.359.2017.11.03.09.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 09:02:28 -0700 (PDT)
Date: Fri, 3 Nov 2017 12:02:26 -0400 (EDT)
From: =?utf-8?Q?Marc-Andr=C3=A9?= Lureau <marcandre.lureau@redhat.com>
Message-ID: <847029229.35880816.1509724946936.JavaMail.zimbra@redhat.com>
In-Reply-To: <c884ed14-cb4e-fa04-e5be-5a732e64f988@oracle.com>
References: <20171031184052.25253-1-marcandre.lureau@redhat.com> <20171031184052.25253-3-marcandre.lureau@redhat.com> <c884ed14-cb4e-fa04-e5be-5a732e64f988@oracle.com>
Subject: Re: [PATCH 2/6] shmem: rename functions that are memfd-related
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

Hi

----- Original Message -----
> On 10/31/2017 11:40 AM, Marc-Andr=C3=A9 Lureau wrote:
> > Those functions are called for memfd files, backed by shmem or
> > hugetlb (the next patches will handle hugetlb).
> >=20
> > Signed-off-by: Marc-Andr=C3=A9 Lureau <marcandre.lureau@redhat.com>
> > ---
> >  fs/fcntl.c               |  2 +-
> >  include/linux/shmem_fs.h |  4 ++--
> >  mm/shmem.c               | 10 +++++-----
> >  3 files changed, 8 insertions(+), 8 deletions(-)
> >=20
> > diff --git a/fs/fcntl.c b/fs/fcntl.c
> > index 448a1119f0be..752c23743616 100644
> > --- a/fs/fcntl.c
> > +++ b/fs/fcntl.c
> > @@ -417,7 +417,7 @@ static long do_fcntl(int fd, unsigned int cmd, unsi=
gned
> > long arg,
> >  =09=09break;
> >  =09case F_ADD_SEALS:
> >  =09case F_GET_SEALS:
> > -=09=09err =3D shmem_fcntl(filp, cmd, arg);
> > +=09=09err =3D memfd_fcntl(filp, cmd, arg);
> >  =09=09break;
> >  =09case F_GET_RW_HINT:
> >  =09case F_SET_RW_HINT:
> > diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> > index 557d0c3b6eca..0dac8c0f4aa4 100644
> > --- a/include/linux/shmem_fs.h
> > +++ b/include/linux/shmem_fs.h
> > @@ -109,11 +109,11 @@ extern void shmem_uncharge(struct inode *inode, l=
ong
> > pages);
> > =20
> >  #ifdef CONFIG_TMPFS
> > =20
> > -extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned =
long
> > arg);
> > +extern long memfd_fcntl(struct file *file, unsigned int cmd, unsigned =
long
> > arg);
> > =20
> >  #else
> > =20
> > -static inline long shmem_fcntl(struct file *f, unsigned int c, unsigne=
d
> > long a)
> > +static inline long memfd_fcntl(struct file *f, unsigned int c, unsigne=
d
> > long a)
> >  {
> >  =09return -EINVAL;
> >  }
>=20
> Do we want memfd_fcntl() to work for hugetlbfs if CONFIG_TMPFS is not
> defined?  I admit that having CONFIG_HUGETLBFS defined without CONFIG_TMP=
FS
> is unlikely, but I think possible.  Based on the above #ifdef/#else, I
> think hugetlbfs seals will not work if CONFIG_TMPFS is not defined.

Good point, memfd_create() will not exists either.

I think this is a separate concern, and preexisting from this patch series =
though.

Ack the function renaming part?

> --
> Mike Kravetz
>=20
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 37260c5e12fa..b7811979611f 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -2722,7 +2722,7 @@ static int shmem_wait_for_pins(struct address_spa=
ce
> > *mapping)
> >  =09=09     F_SEAL_GROW | \
> >  =09=09     F_SEAL_WRITE)
> > =20
> > -static int shmem_add_seals(struct file *file, unsigned int seals)
> > +static int memfd_add_seals(struct file *file, unsigned int seals)
> >  {
> >  =09struct inode *inode =3D file_inode(file);
> >  =09struct shmem_inode_info *info =3D SHMEM_I(inode);
> > @@ -2792,7 +2792,7 @@ static int shmem_add_seals(struct file *file,
> > unsigned int seals)
> >  =09return error;
> >  }
> > =20
> > -static int shmem_get_seals(struct file *file)
> > +static int memfd_get_seals(struct file *file)
> >  {
> >  =09if (file->f_op !=3D &shmem_file_operations)
> >  =09=09return -EINVAL;
> > @@ -2800,7 +2800,7 @@ static int shmem_get_seals(struct file *file)
> >  =09return SHMEM_I(file_inode(file))->seals;
> >  }
> > =20
> > -long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long ar=
g)
> > +long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long ar=
g)
> >  {
> >  =09long error;
> > =20
> > @@ -2810,10 +2810,10 @@ long shmem_fcntl(struct file *file, unsigned in=
t
> > cmd, unsigned long arg)
> >  =09=09if (arg > UINT_MAX)
> >  =09=09=09return -EINVAL;
> > =20
> > -=09=09error =3D shmem_add_seals(file, arg);
> > +=09=09error =3D memfd_add_seals(file, arg);
> >  =09=09break;
> >  =09case F_GET_SEALS:
> > -=09=09error =3D shmem_get_seals(file);
> > +=09=09error =3D memfd_get_seals(file);
> >  =09=09break;
> >  =09default:
> >  =09=09error =3D -EINVAL;
> >=20
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
