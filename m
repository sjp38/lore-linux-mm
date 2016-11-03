Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 507436B028E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 22:25:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r68so21715351wmd.0
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 19:25:44 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id me20si6362244wjb.81.2016.11.02.19.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 19:25:42 -0700 (PDT)
Date: Thu, 3 Nov 2016 03:25:40 +0100
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH v2 2/3] mm: add LSM hook for writes to readonly memory
Message-ID: <20161103022540.GI8196@pc.thejh.net>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
 <1475103281-7989-3-git-send-email-jann@thejh.net>
 <CALCETrUc8VVyPKuGrS7PxBRHCsVhXbXaiEOmwjgHrzTRiXPT9Q@mail.gmail.com>
 <20160928233256.GB2040@pc.thejh.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYjDATHXTWnytHRU"
Content-Disposition: inline
In-Reply-To: <20160928233256.GB2040@pc.thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "security@kernel.org" <security@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, LSM List <linux-security-module@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


--zYjDATHXTWnytHRU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 29, 2016 at 01:32:56AM +0200, Jann Horn wrote:
> On Wed, Sep 28, 2016 at 04:22:53PM -0700, Andy Lutomirski wrote:
> > On Wed, Sep 28, 2016 at 3:54 PM, Jann Horn <jann@thejh.net> wrote:
> > > -struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mo=
de)
> > > +struct mm_struct *proc_mem_open(struct inode *inode,
> > > +                               const struct cred **object_cred,
> > > +                               unsigned int mode)
> > >  {
> >=20
> > Why are you passing object_cred all over the place like this?  You
> > have an inode, and an inode implies a task.
>=20
> But the task's mm and objective credentials can change, and only mm_acces=
s()
> holds the cred_guard_mutex during the mm lookup. Although, if the objecti=
ve
> credentials change because of a setuid execution, being able to poke in t=
he
> old mm would be pretty harmless...

Actually, no. If you can poke in the pre-execve memory, but are checked
against the (possibly more permissive) objective creds of the post-execve
process, you can affect another process that shares the pre-execve memory
(the case where task B, which calls execve(), was clone()d from task A
with CLONE_VM). So I'm keeping this code the way I wrote it.


> > For that matter, would it possibly make sense to use MEMCG's mm->owner
> > and get rid of object_cred entirely?
>=20
> I guess it might.

Actually, I'd prefer not to do that - I think it would be unnecessarily
unintuitive to check against the objective creds of task A when accessing
task B if task B was clone()d from A with clone(CLONE_VM).

> > I can see this causing issues in
> > strange threading cases, e.g. accessing your own /proc/$$/mem vs
> > another thread in your process's.
>=20
> Can you elaborate on that?


--zYjDATHXTWnytHRU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYGqAkAAoJED4KNFJOeCOoY7sP/jIOhAwjn/13g04bWe7qq+E2
O0217H1FJLltuD0yQ/dCQvsxIWqXi3Fl+mmw77/wsQ78QnYwgO40vtOCC31q/7V8
751CIv/hrJ6Rt8kAHYxb+ThJdvlc8IuoVID1Jkfh0Ya6+MrtGhJD5RWwqHPMFa2t
0wxPZAZokNCdehxjKbFehoewWGYtTQUGOShRw0/UY6YPm1LrZXUVFMaDG+bMPKo9
BzW50I1Ennx+/nZQrRx8skIb1iGgqKuYnIlUBm0gfVzbrWaMDN+ubTqYNPxAQcId
X2Q8dyI6Oo2lTonaonYB4R9aIUVCCeWVU9BTp/5TdDkW6pMSVPYp/YCTNNvbhLNq
A2EcgzaE2ZYpz4FIbMSihdlvUQjJMoONlxpNon26fBHe+DUA60ODvixnIXq2lFp9
jd+P7CJM2QUFf0SZObk/0C0fxC3wPVdZVI6ITFz6DTHO8XljBr5eTWFOagAXgqp/
+hKgL8o6cazm6yoOuYCEx/7jzm1nbHq1QXuZLjwqbQ5UpD/+lfdlXRnicdzVshFg
RgWMReosTqYQoTB4JG+mfiULTD0z/Yoc7Neu0gDKbCTB/p9ZBPQgqtORFLRKbOQV
kui65pfWIjhfpcQRGETsCA5O0h3OR7QS+mGP5zCYJLZPdpIUdezwji4tipqLbPqg
Y8U7dVD1gXxjdu1jVHzX
=xwqe
-----END PGP SIGNATURE-----

--zYjDATHXTWnytHRU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
