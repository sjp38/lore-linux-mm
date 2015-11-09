Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADDE6B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 16:12:08 -0500 (EST)
Received: by wmww144 with SMTP id w144so49911434wmw.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 13:12:07 -0800 (PST)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTP id 132si840054wmp.39.2015.11.09.13.12.06
        for <linux-mm@kvack.org>;
        Mon, 09 Nov 2015 13:12:06 -0800 (PST)
Date: Mon, 9 Nov 2015 22:12:09 +0100
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH] ptrace: use fsuid, fsgid, effective creds for fs access
 checks
Message-ID: <20151109211209.GA3236@pc.thejh.net>
References: <1446984516-1784-1-git-send-email-jann@thejh.net>
 <20151109125554.43e6a711e59d1b8bf99cdeb1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <20151109125554.43e6a711e59d1b8bf99cdeb1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Joe Perches <joe@perches.com>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, security@kernel.org, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@google.com>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 09, 2015 at 12:55:54PM -0800, Andrew Morton wrote:
> On Sun,  8 Nov 2015 13:08:36 +0100 Jann Horn <jann@thejh.net> wrote:
>=20
> > By checking the effective credentials instead of the real UID /
> > permitted capabilities, ensure that the calling process actually
> > intended to use its credentials.
> >=20
> > To ensure that all ptrace checks use the correct caller
> > credentials (e.g. in case out-of-tree code or newly added code
> > omits the PTRACE_MODE_*CREDS flag), use two new flags and
> > require one of them to be set.
> >=20
> > The problem was that when a privileged task had temporarily dropped
> > its privileges, e.g. by calling setreuid(0, user_uid), with the
> > intent to perform following syscalls with the credentials of
> > a user, it still passed ptrace access checks that the user would
> > not be able to pass.
> >=20
> > While an attacker should not be able to convince the privileged
> > task to perform a ptrace() syscall, this is a problem because the
> > ptrace access check is reused for things in procfs.
> >=20
> > In particular, the following somewhat interesting procfs entries
> > only rely on ptrace access checks:
> >=20
> >  /proc/$pid/stat - uses the check for determining whether pointers
> >      should be visible, useful for bypassing ASLR
> >  /proc/$pid/maps - also useful for bypassing ASLR
> >  /proc/$pid/cwd - useful for gaining access to restricted
> >      directories that contain files with lax permissions, e.g. in
> >      this scenario:
> >      lrwxrwxrwx root root /proc/13020/cwd -> /root/foobar
> >      drwx------ root root /root
> >      drwxr-xr-x root root /root/foobar
> >      -rw-r--r-- root root /root/foobar/secret
> >=20
> > Therefore, on a system where a root-owned mode 6755 binary
> > changes its effective credentials as described and then dumps a
> > user-specified file, this could be used by an attacker to reveal
> > the memory layout of root's processes or reveal the contents of
> > files he is not allowed to access (through /proc/$pid/cwd).
>=20
> I'll await reviewer input on this one.  Meanwhile, a bunch of
> minor(ish) things...
>=20
> > --- a/fs/proc/array.c
> > +++ b/fs/proc/array.c
> > @@ -395,7 +395,8 @@ static int do_task_stat(struct seq_file *m, struct =
pid_namespace *ns,
> > =20
> >  	state =3D *get_task_state(task);
> >  	vsize =3D eip =3D esp =3D 0;
> > -	permitted =3D ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_=
NOAUDIT);
> > +	permitted =3D ptrace_may_access(task,
> > +		PTRACE_MODE_READ | PTRACE_MODE_NOAUDIT | PTRACE_MODE_FSCREDS);
>=20
> There's lots of ugliness in the patch to do with fitting code into 80 col=
s.

I agree.


> Can we do
>=20
> #define PTRACE_foo (PTRACE_MODE_READ|PTRACE_MODE_FSCREDS)
>=20
> to avoid all that?

Hm. All combinations of the PTRACE_MODE_*CREDS flags with
PTRACE_MODE_{READ,ATTACH} plus optionally PTRACE_MODE_NOAUDIT
make sense, I think. So your suggestion would be to create
four new #defines
PTRACE_MODE_{READ,ATTACH}_{FSCREDS,REALCREDS} and then let
callers OR in the PTRACE_MODE_NOAUDIT flag if needed?


> > --- a/include/linux/ptrace.h
> > +++ b/include/linux/ptrace.h
> > @@ -57,7 +57,22 @@ extern void exit_ptrace(struct task_struct *tracer, =
struct list_head *dead);
> >  #define PTRACE_MODE_READ	0x01
> >  #define PTRACE_MODE_ATTACH	0x02
> >  #define PTRACE_MODE_NOAUDIT	0x04
> > -/* Returns true on success, false on denial. */
> > +#define PTRACE_MODE_FSCREDS 0x08
> > +#define PTRACE_MODE_REALCREDS 0x10
> > +/**
> > + * ptrace_may_access - check whether the caller is permitted to access
> > + * a target task.
> > + * @task: target task
> > + * @mode: selects type of access and caller credentials
> > + *
> > + * Returns true on success, false on denial.
> > + *
> > + * One of the flags PTRACE_MODE_FSCREDS and PTRACE_MODE_REALCREDS must
> > + * be set in @mode to specify whether the access was requested through
> > + * a filesystem syscall (should use effective capabilities and fsuid
> > + * of the caller) or through an explicit syscall such as
> > + * process_vm_writev or ptrace (and should use the real credentials).
> > + */
> >  extern bool ptrace_may_access(struct task_struct *task, unsigned int m=
ode);
>=20
> It is unconventional to put the kernedoc in the header - people have
> been trained to look for it in the .c file.

OK, will fix that. I thought it would be appropriate to put it in the
header since that one-line comment was already there.


> > +++ b/kernel/ptrace.c
> > @@ -219,6 +219,13 @@ static int ptrace_has_cap(struct user_namespace *n=
s, unsigned int mode)
> >  static int __ptrace_may_access(struct task_struct *task, unsigned int =
mode)
> >  {
> >  	const struct cred *cred =3D current_cred(), *tcred;
> > +	kuid_t caller_uid;
> > +	kgid_t caller_gid;
> > +
> > +	if (!(mode & PTRACE_MODE_FSCREDS) !=3D !(mode & PTRACE_MODE_REALCREDS=
)) {
>=20
> So setting either one of these and not the other is an error.  How
> come?

Oh. Sorry about that. I only added PTRACE_MODE_REALCREDS in this iteration
of the patch and forgot to re-test afterwards. It is supposed to be the
other way around, so that you need to set exactly one. s/!=3D/=3D=3D/


> > +		WARN(1, "denying ptrace access check without PTRACE_MODE_*CREDS\n");
>=20
> This warning cannot be triggered by malicious userspace, I trust?

Yeah, the ptrace access check flags should come from kernelspace only.
My patch modifies all callers of mm_access / ptrace_may_access so that
exactly one of the new flags is added, and the mode argument is always
a constant.

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWQQwpAAoJED4KNFJOeCOoobYP+wXFDnNql2gfhh60auoDcuty
FcUEyylH19NH7Wht9d5dUEiEZGnvogh36IakfLxmvdTQ0qgLwve7s7Nj3uaG2n4x
9dCmO7YKOm4JD3lkkeMySwDBNz1x6ip24b5wRujUqlDhD4HwO7iescbi0ShgHOHQ
MsFdl5cxzhHmtVpH2ftMcFrBAFngdqJH6BvifXUtlkoILVMbM0/aTNeTRtrnqoQE
8RpslhG5/AKqNdALugXbYpoqnPh5QMc2kC4ivRTNB0Gg8Qh0tYBlDFD3P+cT9EuB
g5j3fZwgTGaQYm+4A0vcSXkvdGUsV/5YT4kG2U0fYKtvQvNSinB8H+wIKLFwcOaD
qckr2J8lKUWpKXf5sdgoAbJOgLngrg6erM4vAO7Zqyg++VdCAtlyoegiDeVFM/t3
c88yI8iT8eD5HJTKXuTo7v7zo+L3mv1lHsEzskBjflf+uWjV5KRdPpeHA62uGdAd
T2PrWtfld6/EqaeIcqS11GRRiuA2bj+LWvUwQFYQk42nkFMjKt+4TvorB9iqD13j
tJJx/wryVpeCEWpyxO/fJwfglkXHSsYLmmoV+RxNjpBszBcyvYl1q9FimSLMccSK
yGVRdnexyUGUkUGU9e7XoYBY+UEfTKcjt8U7S3kN8l0WVMwUbQv89KjtYMxpZwVA
x2xgIHIsjvzL568JWsff
=oPKT
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
