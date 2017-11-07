Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7CB6280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 07:12:15 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w197so12625211oif.23
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 04:12:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t30si483501ote.125.2017.11.07.04.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 04:12:14 -0800 (PST)
Date: Tue, 7 Nov 2017 07:12:12 -0500 (EST)
From: =?utf-8?Q?Marc-Andr=C3=A9?= Lureau <marcandre.lureau@redhat.com>
Message-ID: <1272204993.37283597.1510056732810.JavaMail.zimbra@redhat.com>
In-Reply-To: <988f32e8-9073-0022-076b-6f86dc650a9c@oracle.com>
References: <20171106143944.13821-1-marcandre.lureau@redhat.com> <20171106143944.13821-10-marcandre.lureau@redhat.com> <988f32e8-9073-0022-076b-6f86dc650a9c@oracle.com>
Subject: Re: [PATCH v2 9/9] memfd-test: run fuse test on hugetlb backend
 memory
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

Hi

----- Original Message -----
> On 11/06/2017 06:39 AM, Marc-Andr=C3=A9 Lureau wrote:
> > Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
> > Signed-off-by: Marc-Andr=C3=A9 Lureau <marcandre.lureau@redhat.com>
> > ---
> >  tools/testing/selftests/memfd/fuse_test.c      | 30
> >  ++++++++++++++++++++++----
> >  tools/testing/selftests/memfd/run_fuse_test.sh |  2 +-
> >  tools/testing/selftests/memfd/run_tests.sh     |  1 +
> >  3 files changed, 28 insertions(+), 5 deletions(-)
> >=20
> > diff --git a/tools/testing/selftests/memfd/fuse_test.c
> > b/tools/testing/selftests/memfd/fuse_test.c
> > index 795a25ba8521..0a85b34929e1 100644
> > --- a/tools/testing/selftests/memfd/fuse_test.c
> > +++ b/tools/testing/selftests/memfd/fuse_test.c
> > @@ -38,6 +38,8 @@
> >  #define MFD_DEF_SIZE 8192
> >  #define STACK_SIZE 65536
> > =20
> > +static size_t mfd_def_size =3D MFD_DEF_SIZE;
> > +
> >  static int mfd_assert_new(const char *name, loff_t sz, unsigned int fl=
ags)
> >  {
> >  =09int r, fd;
> > @@ -123,7 +125,7 @@ static void *mfd_assert_mmap_shared(int fd)
> >  =09void *p;
> > =20
> >  =09p =3D mmap(NULL,
> > -=09=09 MFD_DEF_SIZE,
> > +=09=09 mfd_def_size,
> >  =09=09 PROT_READ | PROT_WRITE,
> >  =09=09 MAP_SHARED,
> >  =09=09 fd,
> > @@ -141,7 +143,7 @@ static void *mfd_assert_mmap_private(int fd)
> >  =09void *p;
> > =20
> >  =09p =3D mmap(NULL,
> > -=09=09 MFD_DEF_SIZE,
> > +=09=09 mfd_def_size,
> >  =09=09 PROT_READ | PROT_WRITE,
> >  =09=09 MAP_PRIVATE,
> >  =09=09 fd,
> > @@ -174,7 +176,7 @@ static int sealing_thread_fn(void *arg)
> >  =09usleep(200000);
> > =20
> >  =09/* unmount mapping before sealing to avoid i_mmap_writable failures=
 */
> > -=09munmap(global_p, MFD_DEF_SIZE);
> > +=09munmap(global_p, mfd_def_size);
> > =20
> >  =09/* Try sealing the global file; expect EBUSY or success. Current
> >  =09 * kernels will never succeed, but in the future, kernels might
> > @@ -224,7 +226,7 @@ static void join_sealing_thread(pid_t pid)
> > =20
> >  int main(int argc, char **argv)
> >  {
> > -=09static const char zero[MFD_DEF_SIZE];
> > +=09char *zero;
> >  =09int fd, mfd, r;
> >  =09void *p;
> >  =09int was_sealed;
> > @@ -235,6 +237,25 @@ int main(int argc, char **argv)
> >  =09=09abort();
> >  =09}
> > =20
> > +=09if (argc >=3D 3) {
> > +=09=09if (!strcmp(argv[2], "hugetlbfs")) {
> > +=09=09=09unsigned long hpage_size =3D default_huge_page_size();
> > +
> > +=09=09=09if (!hpage_size) {
> > +=09=09=09=09printf("Unable to determine huge page size\n");
> > +=09=09=09=09abort();
> > +=09=09=09}
> > +
> > +=09=09=09hugetlbfs_test =3D 1;
> > +=09=09=09mfd_def_size =3D hpage_size * 2;
> > +=09=09} else {
> > +=09=09=09printf("Unknown option: %s\n", argv[2]);
> > +=09=09=09abort();
> > +=09=09}
> > +=09}
> > +
> > +=09zero =3D calloc(sizeof(*zero), mfd_def_size);
> > +
> >  =09/* open FUSE memfd file for GUP testing */
> >  =09printf("opening: %s\n", argv[1]);
> >  =09fd =3D open(argv[1], O_RDONLY | O_CLOEXEC);
>=20
> When ftruncate'ing the newly created file, you need to make sure length i=
s
> a multiple of huge page size for hugetlbfs files.  So, you will want to
> do something like:
>=20
> --- a/tools/testing/selftests/memfd/fuse_test.c
> +++ b/tools/testing/selftests/memfd/fuse_test.c
> @@ -265,7 +265,7 @@ int main(int argc, char **argv)
> =20
>         /* create new memfd-object */
>         mfd =3D mfd_assert_new("kern_memfd_fuse",
> -                            MFD_DEF_SIZE,
> +                            mfd_def_size,
>                              MFD_CLOEXEC | MFD_ALLOW_SEALING);
> =20
>         /* mmap memfd-object for writing */
>=20
> Leaving MFD_DEF_SIZE for the size of reads and writes should be fine.

I actually intended to replace all MFD_DEF_SIZE with mfd_def_size. Should b=
e fine too. Resending updated series.

>=20
> --
> Mike Kravetz
>=20
> > @@ -303,6 +324,7 @@ int main(int argc, char **argv)
> >  =09close(fd);
> > =20
> >  =09printf("fuse: DONE\n");
> > +=09free(zero);
> > =20
> >  =09return 0;
> >  }
> > diff --git a/tools/testing/selftests/memfd/run_fuse_test.sh
> > b/tools/testing/selftests/memfd/run_fuse_test.sh
> > index 407df68dfe27..22e572e2d66a 100755
> > --- a/tools/testing/selftests/memfd/run_fuse_test.sh
> > +++ b/tools/testing/selftests/memfd/run_fuse_test.sh
> > @@ -10,6 +10,6 @@ set -e
> > =20
> >  mkdir mnt
> >  ./fuse_mnt ./mnt
> > -./fuse_test ./mnt/memfd
> > +./fuse_test ./mnt/memfd $@
> >  fusermount -u ./mnt
> >  rmdir ./mnt
> > diff --git a/tools/testing/selftests/memfd/run_tests.sh
> > b/tools/testing/selftests/memfd/run_tests.sh
> > index daabb350697c..c2d41ed81b24 100755
> > --- a/tools/testing/selftests/memfd/run_tests.sh
> > +++ b/tools/testing/selftests/memfd/run_tests.sh
> > @@ -60,6 +60,7 @@ fi
> >  # Run the hugetlbfs test
> >  #
> >  ./memfd_test hugetlbfs
> > +./run_fuse_test.sh hugetlbfs
> > =20
> >  #
> >  # Give back any huge pages allocated for the test
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
