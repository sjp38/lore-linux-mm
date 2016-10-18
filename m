Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2096B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:05:11 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x23so13777576lfi.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:05:11 -0700 (PDT)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTPS id j6si195224lfd.196.2016.10.18.08.05.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 08:05:09 -0700 (PDT)
Date: Tue, 18 Oct 2016 17:05:07 +0200
From: Jann Horn <jann@thejh.net>
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
 ptrace_may_access
Message-ID: <20161018150507.GP14666@pc.thejh.net>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
 <20161018135031.GB13117@dhcp22.suse.cz>
 <8737jt903u.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDdTYOCAbkFo0FQC"
Content-Disposition: inline
In-Reply-To: <8737jt903u.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org


--dDdTYOCAbkFo0FQC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 18, 2016 at 09:56:53AM -0500, Eric W. Biederman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
>=20
> > On Mon 17-10-16 11:39:49, Eric W. Biederman wrote:
> >>=20
> >> During exec dumpable is cleared if the file that is being executed is
> >> not readable by the user executing the file.  A bug in
> >> ptrace_may_access allows reading the file if the executable happens to
> >> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
> >> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
> >>=20
> >> This problem is fixed with only necessary userspace breakage by adding
> >> a user namespace owner to mm_struct, captured at the time of exec,
> >> so it is clear in which user namespace CAP_SYS_PTRACE must be present
> >> in to be able to safely give read permission to the executable.
> >>=20
> >> The function ptrace_may_access is modified to verify that the ptracer
> >> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
> >> This ensures that if the task changes it's cred into a subordinate
> >> user namespace it does not become ptraceable.
> >
> > I haven't studied your patch too deeply but one thing that immediately=
=20
> > raised a red flag was that mm might be shared between processes (aka
> > thread groups). What prevents those two to sit in different user
> > namespaces?
> >
> > I am primarily asking because this generated a lot of headache for the
> > memcg handling as those processes might sit in different cgroups while
> > there is only one correct memcg for them which can disagree with the
> > cgroup associated with one of the processes.
>=20
> That is a legitimate concern, but I do not see any of those kinds of
> issues here.
>=20
> Part of the memcg pain comes from the fact that control groups are
> process centric, and part of the pain comes from the fact that it is
> possible to change control groups.  What I am doing is making the mm
> owned by a user namespace (at creation time), and I am not allowing
> changes to that ownership. The credentials of the tasks that use that mm
> may be in the same user namespace or descendent user namespaces.
>=20
> The core goal is to enforce the unreadability of an mm when an
> non-readable file is executed.  This is a time of mm creation property.
> The enforcement of which fits very well with the security/permission
> checking role of the user namespace.

How is that going to work? I thought the core goal was better security for
entering containers.

If I want to dump a non-readable file, afaik, I can just make a new user
namespace, then run the file in there and dump its memory.
I guess you could fix that by entirely prohibiting the execution of a
non-readable file whose owner UID is not mapped. (Adding more dumping
restrictions wouldn't help much because you could still e.g. supply a
malicious dynamic linker if you control the mount namespace.)

--dDdTYOCAbkFo0FQC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYBjojAAoJED4KNFJOeCOo5RUQAJ3hm7OdxQ4XSgeWafVqL83n
olVxqERueawMqp8C2zHpcRHYQdsHf4ldtco3ZpvvIRXZWAkPo0dCDrT7CnOV4hSA
Ee+pWkgytoQ4Gtly57Jx9xuxjrqBUHll1Mo3Bn/FEGr3k+qxgIYf8+UaCgoH6IUv
TScPCMYaXH7lbf3xuMaxW+EebOezw/ITXKvDXc3uzzzTkg0rvgknjGTicvRR1lQS
hQ+3+6+JD9NR4hyfCAZqspBewJwmfgwAzmhCIfvrVtHZq/R/dtyw+vYDGthgY40R
saTtHlpm/iFU8ERcmGEY+tjdDw9fPNGHn5vH+KDbzNk1+39vEije6QJm2okjW1ow
QrT84C3ItODmU7Tah0XXDZPcSNsfpp0oXob26b1VwbIutkl/Pw6bi7WrqYYmUhq/
1XaAiJWoVzlrJlSf7+JTiC4gEjLmYH38KptfOL4UY1/1kIoifeqTSXAsjtk+0BIi
XbIzUgGjRz/qIDfEfMr4/oWXYTfM9WZlYeecdo/lLAa5hyyCgXtrseVk7AIFq5jX
CcTSwo0kCmFncGTjfkiQfcOy4utEJhJduXX8VjnrjQXXsUhFQxinb50lQej52wSg
d8Lz785km03c6myj7fcN4i0KSmnSYwyFhAJirkozN+9WDyqU/K330El6nYG7a4WX
2+sclXsEjiZ3fgWcuv0U
=DXaI
-----END PGP SIGNATURE-----

--dDdTYOCAbkFo0FQC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
