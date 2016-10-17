Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 321606B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:25:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b75so105168575lfg.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:25:51 -0700 (PDT)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTPS id br5si42666864wjb.189.2016.10.17.10.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 10:25:49 -0700 (PDT)
Date: Mon, 17 Oct 2016 19:25:47 +0200
From: Jann Horn <jann@thejh.net>
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
 ptrace_may_access
Message-ID: <20161017172547.GJ14666@pc.thejh.net>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rWTGJt96jR0TCFDW"
Content-Disposition: inline
In-Reply-To: <87twcbq696.fsf@x220.int.ebiederm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org


--rWTGJt96jR0TCFDW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 17, 2016 at 11:39:49AM -0500, Eric W. Biederman wrote:
>=20
> During exec dumpable is cleared if the file that is being executed is
> not readable by the user executing the file.  A bug in
> ptrace_may_access allows reading the file if the executable happens to
> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
>=20
> This problem is fixed with only necessary userspace breakage by adding
> a user namespace owner to mm_struct, captured at the time of exec,
> so it is clear in which user namespace CAP_SYS_PTRACE must be present
> in to be able to safely give read permission to the executable.
>=20
> The function ptrace_may_access is modified to verify that the ptracer
> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
> This ensures that if the task changes it's cred into a subordinate
> user namespace it does not become ptraceable.

This looks good! Basically applies the same rules that already apply to
EUID/... changes to namespace changes, and anyone entering a user
namespace can now safely drop UIDs and GIDs to namespace root.

This integrates better in the existing security concept than my old
patch "ptrace: being capable wrt a process requires mapped uids/gids",
and it has less issues in cases where e.g. the extra privileges of an
entering process are the filesystem root or so.

FWIW, if you want, you can add "Reviewed-by: Jann Horn <jann@thejh.net>".

> Cc: stable@vger.kernel.org
> Fixes: 8409cca70561 ("userns: allow ptrace from non-init user namespaces")
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>=20
> It turns out that dumpable needs to be fixed to be user namespace
> aware to fix this issue.  When this patch is ready I plan to place it in
> my userns tree and send it to Linus, hopefully for -rc2.
>=20
>  include/linux/mm_types.h |  1 +
>  kernel/fork.c            |  9 ++++++---
>  kernel/ptrace.c          | 17 ++++++-----------
>  mm/init-mm.c             |  2 ++
>  4 files changed, 15 insertions(+), 14 deletions(-)
>=20
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 4a8acedf4b7d..08d947fc4c59 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -473,6 +473,7 @@ struct mm_struct {
>  	 */
>  	struct task_struct __rcu *owner;
>  #endif
> +	struct user_namespace *user_ns;
> =20
>  	/* store ref to file /proc/<pid>/exe symlink points to */
>  	struct file __rcu *exe_file;
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 623259fc794d..fd85c68c2791 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -742,7 +742,8 @@ static void mm_init_owner(struct mm_struct *mm, struc=
t task_struct *p)
>  #endif
>  }
> =20
> -static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struc=
t *p)
> +static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struc=
t *p,
> +	struct user_namespace *user_ns)
>  {
>  	mm->mmap =3D NULL;
>  	mm->mm_rb =3D RB_ROOT;
> @@ -782,6 +783,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm=
, struct task_struct *p)
>  	if (init_new_context(p, mm))
>  		goto fail_nocontext;
> =20
> +	mm->user_ns =3D get_user_ns(user_ns);
>  	return mm;
> =20
>  fail_nocontext:
> @@ -827,7 +829,7 @@ struct mm_struct *mm_alloc(void)
>  		return NULL;
> =20
>  	memset(mm, 0, sizeof(*mm));
> -	return mm_init(mm, current);
> +	return mm_init(mm, current, current_user_ns());
>  }
> =20
>  /*
> @@ -842,6 +844,7 @@ void __mmdrop(struct mm_struct *mm)
>  	destroy_context(mm);
>  	mmu_notifier_mm_destroy(mm);
>  	check_mm(mm);
> +	put_user_ns(mm->user_ns);
>  	free_mm(mm);
>  }
>  EXPORT_SYMBOL_GPL(__mmdrop);
> @@ -1123,7 +1126,7 @@ static struct mm_struct *dup_mm(struct task_struct =
*tsk)
> =20
>  	memcpy(mm, oldmm, sizeof(*mm));
> =20
> -	if (!mm_init(mm, tsk))
> +	if (!mm_init(mm, tsk, mm->user_ns))
>  		goto fail_nomem;
> =20
>  	err =3D dup_mmap(mm, oldmm);
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 2a99027312a6..f2d1b9afb3f8 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -220,7 +220,7 @@ static int ptrace_has_cap(struct user_namespace *ns, =
unsigned int mode)
>  static int __ptrace_may_access(struct task_struct *task, unsigned int mo=
de)
>  {
>  	const struct cred *cred =3D current_cred(), *tcred;
> -	int dumpable =3D 0;
> +	struct mm_struct *mm;
>  	kuid_t caller_uid;
>  	kgid_t caller_gid;
> =20
> @@ -271,16 +271,11 @@ static int __ptrace_may_access(struct task_struct *=
task, unsigned int mode)
>  	return -EPERM;
>  ok:
>  	rcu_read_unlock();
> -	smp_rmb();
> -	if (task->mm)
> -		dumpable =3D get_dumpable(task->mm);
> -	rcu_read_lock();
> -	if (dumpable !=3D SUID_DUMP_USER &&
> -	    !ptrace_has_cap(__task_cred(task)->user_ns, mode)) {
> -		rcu_read_unlock();
> -		return -EPERM;
> -	}
> -	rcu_read_unlock();
> +	mm =3D task->mm;
> +	if (!mm ||
> +	    ((get_dumpable(mm) !=3D SUID_DUMP_USER) &&
> +	     !ptrace_has_cap(mm->user_ns, mode)))
> +	    return -EPERM;
> =20
>  	return security_ptrace_access_check(task, mode);
>  }
> diff --git a/mm/init-mm.c b/mm/init-mm.c
> index a56a851908d2..975e49f00f34 100644
> --- a/mm/init-mm.c
> +++ b/mm/init-mm.c
> @@ -6,6 +6,7 @@
>  #include <linux/cpumask.h>
> =20
>  #include <linux/atomic.h>
> +#include <linux/user_namespace.h>
>  #include <asm/pgtable.h>
>  #include <asm/mmu.h>
> =20
> @@ -21,5 +22,6 @@ struct mm_struct init_mm =3D {
>  	.mmap_sem	=3D __RWSEM_INITIALIZER(init_mm.mmap_sem),
>  	.page_table_lock =3D  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
>  	.mmlist		=3D LIST_HEAD_INIT(init_mm.mmlist),
> +	.user_ns	=3D &init_user_ns,
>  	INIT_MM_CONTEXT(init_mm)
>  };
> --=20
> 2.8.3

--rWTGJt96jR0TCFDW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYBQmbAAoJED4KNFJOeCOoWXMQAL8eeq81wx1yAohE/eQGPyPl
Ru6PBy5LIq7cFSba4UwiAA/L/q6bXcpRaAKSbn6FDWFYmOUGFbep22Ons2A0XwwI
EGJ3MfRKa7srzJ+VsTk1m59GdgsC6V2oZdTGAqBhxXK/BhR6cx5ua4CPNb58b3+C
YpS1A7x4wT3NMVFSZRKcgW1pjp2dAC80wdeC0lWDsSBn6n924HXmESMkqAHtXdLI
x5jlVXSM84WwDIcY1okfGubAN6krBaRB69mb23SefIeHwoffN2cvnXpvW/uHJnxp
Ua8qv+fmWRVx97MpKVVSQRzBNo4m4o5cYkYDdqVLu93ktq9mBfGV0HKgCrRrAyoq
Kf0Qf0a3D8n/dN81071tT2bL7RiVOvs3onb4+mK0etBmb25joOyR8J1Cl2L0ySQP
q3bd+cKs8jTCuPEGc15qeGoMW6PitHiNQwPNjh2W2deSW1iZb39/RzMVc6HFoQoP
k0UuFaqQ6tbZPugV8JThZWTmC0JN2H1NcBU3xcca2y2SbBxMzKN7imusla1HRoc0
Hx4dMLJYZHlC9bmnPelnovf9qLG6mKohNt4ewNbNv5nc1JtWPr1PAT0qGoD+6IvD
kSARVE6UUuCdEZzzBUNMOIDlt1qDNkuW2WULxbDQZr6KCE+yYkS59bAqvBk6ldm2
ndkfa3BBLKMThWZsgTfA
=b/yJ
-----END PGP SIGNATURE-----

--rWTGJt96jR0TCFDW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
