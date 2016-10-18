Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3FE6B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:57:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i187so12269845lfe.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:57:44 -0700 (PDT)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTPS id fc4si5082556wjd.5.2016.10.18.06.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 06:57:43 -0700 (PDT)
Date: Tue, 18 Oct 2016 15:57:41 +0200
From: Jann Horn <jann@thejh.net>
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
 ptrace_may_access
Message-ID: <20161018135741.GO14666@pc.thejh.net>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
 <20161018135031.GB13117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n0t7pLec3q0yZKtb"
Content-Disposition: inline
In-Reply-To: <20161018135031.GB13117@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org


--n0t7pLec3q0yZKtb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 18, 2016 at 03:50:32PM +0200, Michal Hocko wrote:
> On Mon 17-10-16 11:39:49, Eric W. Biederman wrote:
> >=20
> > During exec dumpable is cleared if the file that is being executed is
> > not readable by the user executing the file.  A bug in
> > ptrace_may_access allows reading the file if the executable happens to
> > enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
> > unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
> >=20
> > This problem is fixed with only necessary userspace breakage by adding
> > a user namespace owner to mm_struct, captured at the time of exec,
> > so it is clear in which user namespace CAP_SYS_PTRACE must be present
> > in to be able to safely give read permission to the executable.
> >=20
> > The function ptrace_may_access is modified to verify that the ptracer
> > has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
> > This ensures that if the task changes it's cred into a subordinate
> > user namespace it does not become ptraceable.
>=20
> I haven't studied your patch too deeply but one thing that immediately=20
> raised a red flag was that mm might be shared between processes (aka
> thread groups).

You're conflating things. Threads always share memory, but sharing memory
doesn't imply being part of the same thread group.

> What prevents those two to sit in different user
> namespaces?

For thread groups: You can't change user namespace in a thread group
with more than one task.

For shared mm: Yeah, I think that could happen - but it doesn't matter.
The patch just needs the mm to determine the namespace in which the mm
was created, and that's always the same for tasks that share mm.

--n0t7pLec3q0yZKtb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYBipVAAoJED4KNFJOeCOoFR8P/1qBdlSDl1nPfVM5mIQAA2I5
5moy4YtaFZV/UC+uNGxmJiTAW+esWnOA2L+W1KqCtbR/e+mD3lW322iCIXJPYieS
bZocjcJ3OOSM01Yrzj05OaoCcoAL6Zbz1AgcrYmtHJSbMptZG1YqSLdjrSUfppHU
MFAhX7nLe2kOtA4OjIGYpVuDOaDn6vF7lKnPHVDvUC5Z1JR0oJ9bRVTUzrUdIbpL
sGh5Ba52zAqimVjVfLEKW0QIVkrZQd1IXmXvu+c/swm/tWecA0vLaNjTMaz5Mf9J
WUBeM+ihIyH8Jm1I2CD6y/eKBnyB6pF7Z5EyrKLBjmdg6qoLXkQjQKn0hWujGt4m
eLuuKjiKpLO5aFhX4dVqcKzLLiSB0GMdIIGR+zQrHudRy5++twmJVo/rgBvpGnwJ
jq0Z8mJtnpE2yR1rSKVfx39Xn63nByEOQ3ivVi3a9P9xgpLpYfdj8UsK0Sc+kh+v
VCubq3KvdOvlJoL9C3sNuYnEMZVJP0q24CF15ybYz4Tdghs4XX8ujaYREbS8mtke
4WEBhu7wbh2/5R0gw/r5szjyHow4iJY1+dXpYswdQEYZ4qtJ7L2yb9iByrLB/LFh
I4mgRDVae3phBtorxsJ2er5AXGPvz9JyoEK3qayWEwXNRe2JrXEaQKrLaUShSeJ3
5AW2YqgFrnTP1SX6FIJm
=BDcU
-----END PGP SIGNATURE-----

--n0t7pLec3q0yZKtb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
