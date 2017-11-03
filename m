Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE986B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 12:13:08 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b189so3206632oia.10
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 09:13:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e16si3225716oig.552.2017.11.03.09.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 09:13:06 -0700 (PDT)
Date: Fri, 3 Nov 2017 12:13:05 -0400 (EDT)
From: =?utf-8?Q?Marc-Andr=C3=A9?= Lureau <marcandre.lureau@redhat.com>
Message-ID: <1255476707.35881664.1509725585691.JavaMail.zimbra@redhat.com>
In-Reply-To: <e9b1cda0-4216-3d04-233b-d229069bf529@oracle.com>
References: <20171031184052.25253-1-marcandre.lureau@redhat.com> <20171031184052.25253-6-marcandre.lureau@redhat.com> <e9b1cda0-4216-3d04-233b-d229069bf529@oracle.com>
Subject: Re: [PATCH 5/6] shmem: add sealing support to hugetlb-backed memfd
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
> > Adapt add_seals()/get_seals() to work with hugetbfs-backed memory.
> >=20
> > Teach memfd_create() to allow sealing operations on MFD_HUGETLB.
> >=20
> > Signed-off-by: Marc-Andr=C3=A9 Lureau <marcandre.lureau@redhat.com>
> > ---
> >  mm/shmem.c | 51 ++++++++++++++++++++++++++++++---------------------
> >  1 file changed, 30 insertions(+), 21 deletions(-)
> >=20
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index b7811979611f..b7c59d993c19 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -2717,6 +2717,19 @@ static int shmem_wait_for_pins(struct address_sp=
ace
> > *mapping)
> >  =09return error;
> >  }
> > =20
> > +static unsigned int *memfd_get_seals(struct file *file)
>=20
> I would have named this something like 'memfd_file_seal_ptr', and not
> changed the name of memfd_get_seals below.  Just my preference, and it
> does not carry as much weight as Hugh who originally write this code.
>=20

agreed and changed, thanks

> > +{
> > +=09if (file->f_op =3D=3D &shmem_file_operations)
> > +=09=09return &SHMEM_I(file_inode(file))->seals;
> > +
> > +#ifdef CONFIG_HUGETLBFS
> > +=09if (file->f_op =3D=3D &hugetlbfs_file_operations)
> > +=09=09return &HUGETLBFS_I(file_inode(file))->seals;
> > +#endif
> > +
> > +=09return NULL;
> > +}
> > +
>=20
> As mentioned in patch 2, I think this code will need to be restructured
> so that hugetlbfs file sealing will work even is CONFIG_TMPFS is not
> defined.  The above routine is behind #ifdef CONFIG_TMPFS.
>=20
> In general the code looks fine, but this config issue needs to be address=
ed.

See discussion in patch 2

> --
> Mike Kravetz
>=20
> >  #define F_ALL_SEALS (F_SEAL_SEAL | \
> >  =09=09     F_SEAL_SHRINK | \
> >  =09=09     F_SEAL_GROW | \
> > @@ -2725,7 +2738,7 @@ static int shmem_wait_for_pins(struct address_spa=
ce
> > *mapping)
> >  static int memfd_add_seals(struct file *file, unsigned int seals)
> >  {
> >  =09struct inode *inode =3D file_inode(file);
> > -=09struct shmem_inode_info *info =3D SHMEM_I(inode);
> > +=09unsigned int *file_seals;
> >  =09int error;
> > =20
> >  =09/*
> > @@ -2758,8 +2771,6 @@ static int memfd_add_seals(struct file *file,
> > unsigned int seals)
> >  =09 * other file types.
> >  =09 */
> > =20
> > -=09if (file->f_op !=3D &shmem_file_operations)
> > -=09=09return -EINVAL;
> >  =09if (!(file->f_mode & FMODE_WRITE))
> >  =09=09return -EPERM;
> >  =09if (seals & ~(unsigned int)F_ALL_SEALS)
> > @@ -2767,12 +2778,18 @@ static int memfd_add_seals(struct file *file,
> > unsigned int seals)
> > =20
> >  =09inode_lock(inode);
> > =20
> > -=09if (info->seals & F_SEAL_SEAL) {
> > +=09file_seals =3D memfd_get_seals(file);
> > +=09if (!file_seals) {
> > +=09=09error =3D -EINVAL;
> > +=09=09goto unlock;
> > +=09}
> > +
> > +=09if (*file_seals & F_SEAL_SEAL) {
> >  =09=09error =3D -EPERM;
> >  =09=09goto unlock;
> >  =09}
> > =20
> > -=09if ((seals & F_SEAL_WRITE) && !(info->seals & F_SEAL_WRITE)) {
> > +=09if ((seals & F_SEAL_WRITE) && !(*file_seals & F_SEAL_WRITE)) {
> >  =09=09error =3D mapping_deny_writable(file->f_mapping);
> >  =09=09if (error)
> >  =09=09=09goto unlock;
> > @@ -2784,7 +2801,7 @@ static int memfd_add_seals(struct file *file,
> > unsigned int seals)
> >  =09=09}
> >  =09}
> > =20
> > -=09info->seals |=3D seals;
> > +=09*file_seals |=3D seals;
> >  =09error =3D 0;
> > =20
> >  unlock:
> > @@ -2792,12 +2809,11 @@ static int memfd_add_seals(struct file *file,
> > unsigned int seals)
> >  =09return error;
> >  }
> > =20
> > -static int memfd_get_seals(struct file *file)
> > +static int memfd_fcntl_get_seals(struct file *file)
> >  {
> > -=09if (file->f_op !=3D &shmem_file_operations)
> > -=09=09return -EINVAL;
> > +=09unsigned int *seals =3D memfd_get_seals(file);
> > =20
> > -=09return SHMEM_I(file_inode(file))->seals;
> > +=09return seals ? *seals : -EINVAL;
> >  }
> > =20
> >  long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long ar=
g)
> > @@ -2813,7 +2829,7 @@ long memfd_fcntl(struct file *file, unsigned int =
cmd,
> > unsigned long arg)
> >  =09=09error =3D memfd_add_seals(file, arg);
> >  =09=09break;
> >  =09case F_GET_SEALS:
> > -=09=09error =3D memfd_get_seals(file);
> > +=09=09error =3D memfd_fcntl_get_seals(file);
> >  =09=09break;
> >  =09default:
> >  =09=09error =3D -EINVAL;
> > @@ -3657,7 +3673,7 @@ SYSCALL_DEFINE2(memfd_create,
> >  =09=09const char __user *, uname,
> >  =09=09unsigned int, flags)
> >  {
> > -=09struct shmem_inode_info *info;
> > +=09unsigned int *file_seals;
> >  =09struct file *file;
> >  =09int fd, error;
> >  =09char *name;
> > @@ -3667,9 +3683,6 @@ SYSCALL_DEFINE2(memfd_create,
> >  =09=09if (flags & ~(unsigned int)MFD_ALL_FLAGS)
> >  =09=09=09return -EINVAL;
> >  =09} else {
> > -=09=09/* Sealing not supported in hugetlbfs (MFD_HUGETLB) */
> > -=09=09if (flags & MFD_ALLOW_SEALING)
> > -=09=09=09return -EINVAL;
> >  =09=09/* Allow huge page size encoding in flags. */
> >  =09=09if (flags & ~(unsigned int)(MFD_ALL_FLAGS |
> >  =09=09=09=09(MFD_HUGE_MASK << MFD_HUGE_SHIFT)))
> > @@ -3722,12 +3735,8 @@ SYSCALL_DEFINE2(memfd_create,
> >  =09file->f_flags |=3D O_RDWR | O_LARGEFILE;
> > =20
> >  =09if (flags & MFD_ALLOW_SEALING) {
> > -=09=09/*
> > -=09=09 * flags check at beginning of function ensures
> > -=09=09 * this is not a hugetlbfs (MFD_HUGETLB) file.
> > -=09=09 */
> > -=09=09info =3D SHMEM_I(file_inode(file));
> > -=09=09info->seals &=3D ~F_SEAL_SEAL;
> > +=09=09file_seals =3D memfd_get_seals(file);
> > +=09=09*file_seals &=3D ~F_SEAL_SEAL;
> >  =09}
> > =20
> >  =09fd_install(fd, file);
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
