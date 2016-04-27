Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCE76B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:42:05 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k129so107896343iof.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:42:05 -0700 (PDT)
Received: from mail-ig0-x244.google.com (mail-ig0-x244.google.com. [2607:f8b0:4001:c05::244])
        by mx.google.com with ESMTPS id z72si11129183iod.137.2016.04.27.10.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 10:42:03 -0700 (PDT)
Received: by mail-ig0-x244.google.com with SMTP id qu10so8079423igc.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:42:03 -0700 (PDT)
Subject: Re: [PATCH 1.1/2] xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_E2A13889-F5F8-484A-9C14-046AD6B7906F"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <1461758075-21815-1-git-send-email-mhocko@kernel.org>
Date: Wed, 27 Apr 2016 11:41:51 -0600
Message-Id: <04798BA8-2157-4611-B4EA-B8BCBA88AEC3@dilger.ca>
References: <1461671772-1269-2-git-send-email-mhocko@kernel.org> <1461758075-21815-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel <cluster-devel@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, logfs@logfs.org, XFS Developers <xfs@oss.sgi.com>, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--Apple-Mail=_E2A13889-F5F8-484A-9C14-046AD6B7906F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 27, 2016, at 5:54 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> From: Michal Hocko <mhocko@suse.com>
>=20
> xfs has defined PF_FSTRANS to declare a scope GFP_NOFS semantic quite
> some time ago. We would like to make this concept more generic and use
> it for other filesystems as well. Let's start by giving the flag a
> more genric name PF_MEMALLOC_NOFS which is in line with an exiting
> PF_MEMALLOC_NOIO already used for the same purpose for GFP_NOIO
> contexts. Replace all PF_FSTRANS usage from the xfs code in the first
> step before we introduce a full API for it as xfs uses the flag =
directly
> anyway.
>=20
> This patch doesn't introduce any functional change.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> as suggested by Dave, I have split up [1] into two parts. The first =
one
> addes a new PF flag which is just an alias to the existing PF_FSTRANS
> and does all the renaming and the second one to introduce the generic
> API which only changes the bare minimum in the xfs proper.
>=20
> fs/xfs/kmem.c             |  4 ++--
> fs/xfs/kmem.h             |  2 +-
> fs/xfs/libxfs/xfs_btree.c |  2 +-
> fs/xfs/xfs_aops.c         |  6 +++---
> fs/xfs/xfs_trans.c        | 12 ++++++------
> include/linux/sched.h     |  2 ++
> 6 files changed, 15 insertions(+), 13 deletions(-)
>=20
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index 686ba6fb20dd..73f6ab59c664 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -80,13 +80,13 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t =
flags)
> 	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim =
re-entering
> 	 * the filesystem here and potentially deadlocking.
> 	 */
> -	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> +	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> 		noio_flag =3D memalloc_noio_save();
>=20
> 	lflags =3D kmem_flags_convert(flags);
> 	ptr =3D __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, =
PAGE_KERNEL);
>=20
> -	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> +	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> 		memalloc_noio_restore(noio_flag);

Not really the fault of this patch, but it brings this nasty bit of code =
into
the light.  Is all of this machinery still needed given that __vmalloc() =
can
accept GFP flags?  If yes, wouldn't it be better to fix __vmalloc() to =
honor
the GFP flags instead of working around it in the filesystem code?

Cheers, Andreas

> 	return ptr;
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index d1c66e465ca5..0d83f332e5c2 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -50,7 +50,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
> 		lflags =3D GFP_ATOMIC | __GFP_NOWARN;
> 	} else {
> 		lflags =3D GFP_KERNEL | __GFP_NOWARN;
> -		if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> +		if ((current->flags & PF_MEMALLOC_NOFS) || (flags & =
KM_NOFS))
> 			lflags &=3D ~__GFP_FS;
> 	}
>=20
> diff --git a/fs/xfs/libxfs/xfs_btree.c b/fs/xfs/libxfs/xfs_btree.c
> index a0eb18ce3ad3..326566f4a131 100644
> --- a/fs/xfs/libxfs/xfs_btree.c
> +++ b/fs/xfs/libxfs/xfs_btree.c
> @@ -2540,7 +2540,7 @@ xfs_btree_split_worker(
> 	struct xfs_btree_split_args	*args =3D container_of(work,
> 						struct =
xfs_btree_split_args, work);
> 	unsigned long		pflags;
> -	unsigned long		new_pflags =3D PF_FSTRANS;
> +	unsigned long		new_pflags =3D PF_MEMALLOC_NOFS;
>=20
> 	/*
> 	 * we are in a transaction context here, but may also be doing =
work
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index d12dfcfd0cc8..6d816ff0b763 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -124,7 +124,7 @@ xfs_setfilesize_trans_alloc(
> 	 * We hand off the transaction to the completion thread now, so
> 	 * clear the flag here.
> 	 */
> -	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
> +	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
> 	return 0;
> }
>=20
> @@ -169,7 +169,7 @@ xfs_setfilesize_ioend(
> 	 * thus we need to mark ourselves as being in a transaction =
manually.
> 	 * Similarly for freeze protection.
> 	 */
> -	current_set_flags_nested(&tp->t_pflags, PF_FSTRANS);
> +	current_set_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
> 	__sb_writers_acquired(VFS_I(ip)->i_sb, SB_FREEZE_FS);
>=20
> 	/* we abort the update if there was an IO error */
> @@ -979,7 +979,7 @@ xfs_vm_writepage(
> 	 * Given that we do not allow direct reclaim to call us, we =
should
> 	 * never be called while in a filesystem transaction.
> 	 */
> -	if (WARN_ON_ONCE(current->flags & PF_FSTRANS))
> +	if (WARN_ON_ONCE(current->flags & PF_MEMALLOC_NOFS))
> 		goto redirty;
>=20
> 	/* Is this page beyond the end of the file? */
> diff --git a/fs/xfs/xfs_trans.c b/fs/xfs/xfs_trans.c
> index 748b16aff45a..1d247366c733 100644
> --- a/fs/xfs/xfs_trans.c
> +++ b/fs/xfs/xfs_trans.c
> @@ -176,7 +176,7 @@ xfs_trans_reserve(
> 	bool		rsvd =3D (tp->t_flags & XFS_TRANS_RESERVE) !=3D =
0;
>=20
> 	/* Mark this thread as being in a transaction */
> -	current_set_flags_nested(&tp->t_pflags, PF_FSTRANS);
> +	current_set_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
>=20
> 	/*
> 	 * Attempt to reserve the needed disk blocks by decrementing
> @@ -186,7 +186,7 @@ xfs_trans_reserve(
> 	if (blocks > 0) {
> 		error =3D xfs_mod_fdblocks(tp->t_mountp, =
-((int64_t)blocks), rsvd);
> 		if (error !=3D 0) {
> -			current_restore_flags_nested(&tp->t_pflags, =
PF_FSTRANS);
> +			current_restore_flags_nested(&tp->t_pflags, =
PF_MEMALLOC_NOFS);
> 			return -ENOSPC;
> 		}
> 		tp->t_blk_res +=3D blocks;
> @@ -263,7 +263,7 @@ xfs_trans_reserve(
> 		tp->t_blk_res =3D 0;
> 	}
>=20
> -	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
> +	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
>=20
> 	return error;
> }
> @@ -921,7 +921,7 @@ __xfs_trans_commit(
>=20
> 	xfs_log_commit_cil(mp, tp, &commit_lsn, regrant);
>=20
> -	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
> +	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
> 	xfs_trans_free(tp);
>=20
> 	/*
> @@ -951,7 +951,7 @@ __xfs_trans_commit(
> 		if (commit_lsn =3D=3D -1 && !error)
> 			error =3D -EIO;
> 	}
> -	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
> +	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
> 	xfs_trans_free_items(tp, NULLCOMMITLSN, !!error);
> 	xfs_trans_free(tp);
>=20
> @@ -1005,7 +1005,7 @@ xfs_trans_cancel(
> 		xfs_log_done(mp, tp->t_ticket, NULL, false);
>=20
> 	/* mark this thread as no longer being in a transaction */
> -	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
> +	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
>=20
> 	xfs_trans_free_items(tp, NULLCOMMITLSN, dirty);
> 	xfs_trans_free(tp);
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index acfc32b30704..820db8f98bfc 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2115,6 +2115,8 @@ extern void thread_group_cputime_adjusted(struct =
task_struct *p, cputime_t *ut,
> #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not =
count it as freezable */
> #define PF_SUSPEND_TASK 0x80000000      /* this thread called =
freeze_processes and should not be frozen */
>=20
> +#define PF_MEMALLOC_NOFS PF_FSTRANS	/* Transition to a more generic =
GFP_NOFS scope semantic */
> +
> /*
>  * Only the _current_ task can read/write to tsk->flags, but other
>  * tasks can access tsk->flags in readonly mode for example
> --
> 2.8.0.rc3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_E2A13889-F5F8-484A-9C14-046AD6B7906F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVyD54HKl2rkXzB/gAQhFgA//ZYuehVpoM5drnP3bbKWtQjn+P6DN/JN+
Tm6ZVTirAPubH6MoXJ2+c7UHpnxzIRKlauzLQkZih1i3oYUyC58bNJuSeJNmffsY
QVqB/INiLvJhfSwzzUzJEAZBrrrMp5laltsy4fgc13GqRoeT4wY3IoTb4ZofuC9G
ij6BiTMALIp6IkhPNk/9Ru5jBqWbcVTMHngMfeYrWRuzKOM7QO58ceqCYM4xsz7n
QuH/685BricBeQYPxQXaaAM0Gh6LAUd4ctzWFBpJavT+oaJoG7/JLSTUoLU/2W0b
pGJHCCWpY59eUz1AT13PGTYcCxo6+ta+PRtWX8qEuME5vrsCkfYgUHjkislp3avM
dahSdlxRLo5Ji4kxUiKS9RATKRfh1G7ucKsUC+PIeaXjfQEGXaihjFFHj0ioHVtl
vqVlOmxSCSXhwHbvLiwehrb2njBhtfTplbQ1YL370/c00tezhDbDMrp4q1GmuCGJ
1ewQTTHhixNPogyV5ameP/4oq8CMCztnmGw65/54BCcORcOkgE4Vprwwvi+AOJP4
DG5SdP+Sj4DdcOHI2MtDjvna9vGLbiINSsu76YPgltbvnQMqp+CUyK9qBoBsXNUi
Aco5N8PaQWzKloGPDOeVzHdMBononKFf+4wtbaQ0kEUkX0bXdvkSJqxlDsK/6wnE
05SCP6c8sd4=
=dU5k
-----END PGP SIGNATURE-----

--Apple-Mail=_E2A13889-F5F8-484A-9C14-046AD6B7906F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
