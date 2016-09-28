Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1484B28024C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:33:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so55539748wmg.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 16:33:01 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id d5si11339395wjm.249.2016.09.28.16.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 16:32:59 -0700 (PDT)
Date: Thu, 29 Sep 2016 01:32:56 +0200
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH v2 2/3] mm: add LSM hook for writes to readonly memory
Message-ID: <20160928233256.GB2040@pc.thejh.net>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
 <1475103281-7989-3-git-send-email-jann@thejh.net>
 <CALCETrUc8VVyPKuGrS7PxBRHCsVhXbXaiEOmwjgHrzTRiXPT9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="98e8jtXdkpgskNou"
Content-Disposition: inline
In-Reply-To: <CALCETrUc8VVyPKuGrS7PxBRHCsVhXbXaiEOmwjgHrzTRiXPT9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "security@kernel.org" <security@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, LSM List <linux-security-module@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


--98e8jtXdkpgskNou
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 28, 2016 at 04:22:53PM -0700, Andy Lutomirski wrote:
> On Wed, Sep 28, 2016 at 3:54 PM, Jann Horn <jann@thejh.net> wrote:
> > SELinux attempts to make it possible to whitelist trustworthy sources of
> > code that may be mapped into memory, and Android makes use of this feat=
ure.
> > To prevent an attacker from bypassing this by modifying R+X memory thro=
ugh
> > /proc/$pid/mem or PTRACE_POKETEXT, it is necessary to call a security h=
ook
> > in check_vma_flags().
>=20
> If selinux policy allows PTRACE_POKETEXT, is it really so bad for that
> to result in code execution?

Have a look at __ptrace_may_access():

	/* Don't let security modules deny introspection */
	if (same_thread_group(task, current))
		return 0;

This means thread A can attach to thread B and poke its memory, and SELinux
can't do anything about it.

I guess another perspective on this would be that it's a problem that
interfaces usable for poking user memory are subject to introspection rules
(as opposed to e.g. /proc/self/maps, where it is actually useful).

> > -struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
> > +struct mm_struct *proc_mem_open(struct inode *inode,
> > +                               const struct cred **object_cred,
> > +                               unsigned int mode)
> >  {
>=20
> Why are you passing object_cred all over the place like this?  You
> have an inode, and an inode implies a task.

But the task's mm and objective credentials can change, and only mm_access()
holds the cred_guard_mutex during the mm lookup. Although, if the objective
credentials change because of a setuid execution, being able to poke in the
old mm would be pretty harmless...


> For that matter, would it possibly make sense to use MEMCG's mm->owner
> and get rid of object_cred entirely?

I guess it might.


> I can see this causing issues in
> strange threading cases, e.g. accessing your own /proc/$$/mem vs
> another thread in your process's.

Can you elaborate on that?

--98e8jtXdkpgskNou
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX7FMoAAoJED4KNFJOeCOo+T4P/2eeiOLUZMj4r99vRavxmok+
prpChywoJI/+Rj1gqFdAog1muj7T3t9WxKGdhMqTu5pYRAl0eewJnA4ipOUX6yO7
HTu2xNZTa5R6Wiv2qxOks/0m38ufsywReRf8UxaVJ1MaLuJjfzQkt+zVZFrYf4Be
9Ne98Kf2Cy5MU1JVNGHqUIvEpX27Z27Fvy9iG2x3RfE44KN10iW3nDVGK6DhO8Ev
IJkHCASKbk0hoEatT92AWYv/N4HRaXPEkwO0Upy5PsduYvySFzR3QBkUcDWPiyep
oVtvBXAmY4AOx6y5ktHIAOd1FxXSFGy1typ5P7vWHAi4tsgxKs4npQ2BdaKKQuC2
cJ0rjXJmjIzcG5+08rjS54PPE4CnFZLNnwxtEG/9hwQJrIHzWqfheFX6DQJu72/e
OQDYVGqSmI9AguHx2RGIW4dxODEFPhiCX/YuI4oILIdOBh83bl6/xSkxcdzKuSKJ
bmyFvzoBlIaxr1kEl4jCz+MHLaiLvMb1uwmYC5EUCJuybSGGloqzM9LDunl/PuQw
2tP531tdmVAaHHpFufQKbS/ymZGRhvRRyJf2jLVp7z7fI6nkACjEhhEbUO2H4bjN
pyt814/pTEc0Cz35Wbsj4swLoncb385YGKG0GdrDs+Aygk8UxlhPfyd+L/abtGe2
gucJMd0z4BVT4V4KHa8m
=QaV/
-----END PGP SIGNATURE-----

--98e8jtXdkpgskNou--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
