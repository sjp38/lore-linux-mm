Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 95E3B6B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 10:03:48 -0400 (EDT)
Received: by yxe32 with SMTP id 32so1343398yxe.23
        for <linux-mm@kvack.org>; Fri, 11 Sep 2009 07:03:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0908241532470.9322@sister.anvils>
References: <alpine.LRH.2.00.0908241110420.21562@tundra.namei.org>
	<Pine.LNX.4.64.0908241258070.27704@sister.anvils> <4A929BF5.2050105@gmail.com>
	<Pine.LNX.4.64.0908241532470.9322@sister.anvils>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 11 Sep 2009 10:03:28 -0400
Message-ID: <8bd0f97a0909110703o4d496a45jddc0d7d6fd8674b4@mail.gmail.com>
Subject: Re: [PATCH] mm: fix hugetlb bug due to user_shm_unlock call
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Stefan Huber <shuber2@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Meerwald <pmeerw@cosy.sbg.ac.at>, James Morris <jmorris@namei.org>, William Irwin <wli@movementarian.org>, Mel Gorman <mel@csn.ul.ie>, Ravikiran G Thirumalai <kiran@scalex86.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 11:30, Hugh Dickins wrote:
> --- 2.6.31-rc7/ipc/shm.c =C2=A0 =C2=A0 =C2=A0 =C2=A02009-06-25 05:18:09.0=
00000000 +0100
> +++ linux/ipc/shm.c =C2=A0 =C2=A0 2009-08-24 16:06:30.000000000 +0100
> @@ -174,7 +174,7 @@ static void shm_destroy(struct ipc_names
> =C2=A0 =C2=A0 =C2=A0 =C2=A0shm_unlock(shp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!is_file_hugepages(shp->shm_file))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shmem_lock(shp->sh=
m_file, 0, shp->mlock_user);
> - =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 else if (shp->mlock_user)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0user_shm_unlock(sh=
p->shm_file->f_path.dentry->d_inode->i_size,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0shp->mlock_user);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fput (shp->shm_file);
> @@ -369,8 +369,8 @@ static int newseg(struct ipc_namespace *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* hugetlb_file_se=
tup applies strict accounting */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (shmflg & SHM_N=
ORESERVE)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0acctflag =3D VM_NORESERVE;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 file =3D hugetlb_file_=
setup(name, size, acctflag);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shp->mlock_user =3D cu=
rrent_user();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 file =3D hugetlb_file_=
setup(name, size, acctflag,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &shp->mlock_user);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Do not allow no=
 accounting for OVERCOMMIT_NEVER, even
> @@ -410,6 +410,8 @@ static int newseg(struct ipc_namespace *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return error;
>
> =C2=A0no_id:
> + =C2=A0 =C2=A0 =C2=A0 if (shp->mlock_user) =C2=A0 =C2=A0/* shmflg & SHM_=
HUGETLB case */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 user_shm_unlock(size, =
shp->mlock_user);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fput(file);
> =C2=A0no_file:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0security_shm_free(shp);

this breaks on no-mmu systems due to user_shm_unlock() being
mmu-specific.  normally gcc is smart enough to do dead code culling so
it hasnt caused problems, but not here.  hugetlb support is not
available on no-mmu systems, so the stubbed hugepage functions prevent
calls to user_shm_unlock() and such, but here gcc cant figure it out:

static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
{
...
    shp->mlock_user =3D NULL;
...
    if (shmflg & SHM_HUGETLB) {
        /* hugetlb_file_setup applies strict accounting */
        if (shmflg & SHM_NORESERVE)
            acctflag =3D VM_NORESERVE;
        file =3D hugetlb_file_setup(name, size, acctflag,
                            &shp->mlock_user);
...
    id =3D ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni);
    if (id < 0) {
        error =3D id;
        goto no_id;
    }
...
no_id:
    if (shp->mlock_user)    /* shmflg & SHM_HUGETLB case */
        user_shm_unlock(size, shp->mlock_user);
...

hugetlb_file_setup() expands to nothing and so mlock_user will never
come back from NULL, but gcc still emits a reference to
user_shm_unlock() in the error path.  perhaps the best thing here is
to just add an #ifdef ?
 no_id:
+#ifdef CONFIG_HUGETLB_PAGE
+    /* gcc isn't smart enough to see that mlock_user goes non-NULL
only by hugetlb */
    if (shp->mlock_user)    /* shmflg & SHM_HUGETLB case */
        user_shm_unlock(size, shp->mlock_user);
+#endif
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
