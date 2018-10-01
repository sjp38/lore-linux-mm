Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 1 Oct 2018 22:13:10 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181001201309.GA9835@amd>
References: <20180927194601.207765-1-wonderfly@google.com>
 <20181001152324.72a20bea@gandalf.local.home>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20181001152324.72a20bea@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Daniel Wang <wonderfly@google.com>, stable@vger.kernel.org, pmladek@suse.com, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, xiyou.wangcong@gmail.com, pfeiner@google.com
List-ID: <linux-mm.kvack.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-10-01 15:23:24, Steven Rostedt wrote:
> On Thu, 27 Sep 2018 12:46:01 -0700
> Daniel Wang <wonderfly@google.com> wrote:
>=20
> > Prior to this change, the combination of `softlockup_panic=3D1` and
> > `softlockup_all_cpu_stacktrace=3D1` may result in a deadlock when the r=
eboot path
> > is trying to grab the console lock that is held by the stack trace prin=
ting
> > path. What seems to be happening is that while there are multiple CPUs,=
 only one
> > of them is tasked to print the back trace of all CPUs. On a machine wit=
h many
> > CPUs and a slow serial console (on Google Compute Engine for example), =
the stack
> > trace printing routine hits a timeout and the reboot path kicks in. The=
 latter
> > then tries to print something else, but can't get the lock because it's=
 still
> > held by earlier printing path. This is easily reproducible on a VM with=
 16+
> > vCPUs on Google Compute Engine - which is a very common scenario.
> >=20
> > A quick repro is available at
> > https://github.com/wonderfly/printk-deadlock-repro. The system hangs 3 =
seconds
> > into executing repro.sh. Both deadlock analysis and repro are credits t=
o Peter
> > Feiner.
> >=20
> > Note that I have read previous discussions on backporting this to stabl=
e [1].
> > The argument for objecting the backport was that this is a non-trivial =
fix and
> > is supported to prevent hypothetical soft lockups. What we are hitting =
is a real
> > deadlock, in production, however. Hence this request.
> >=20
> > [1] https://lore.kernel.org/lkml/20180409081535.dq7p5bfnpvd3xk3t@pathwa=
y.suse.cz/T/#u
> >=20
> > Serial console logs leading up to the deadlock. As can be seen the stac=
k trace
> > was incomplete because the printing path hit a timeout.
>=20
> I'm fine with having this backported.

Dunno. Is the patch perhaps a bit too complex? This is not exactly
trivial bugfix.

pavel@duo:/data/l/clean-cg$ git show dbdda842fe96f | diffstat
 printk.c |  108
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-

I see that it is pretty critical to Daniel, but maybe kernel with
console locking redone should no longer be called 4.4?
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAluyf9UACgkQMOfwapXb+vIctACePrQsLeBiFBo/2uPqXXACActz
jsQAoJ24Q+l/v+gk5q+VGhyCWhwLu+if
=TaX0
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
