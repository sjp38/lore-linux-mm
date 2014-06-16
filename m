Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B87856B0036
	for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:02:04 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so3910138pad.41
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 19:02:04 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id ta6si11977076pab.54.2014.06.15.19.02.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jun 2014 19:02:03 -0700 (PDT)
Date: Mon, 16 Jun 2014 12:01:52 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the akpm-current tree
Message-ID: <20140616120152.752ec516@canb.auug.org.au>
In-Reply-To: <1402672324-io6h33kn@n-horiguchi@ah.jp.nec.com>
References: <20140613150550.7b2e2c4c@canb.auug.org.au>
	<1402672324-io6h33kn@n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/zZth.15U7q6c4+IBs2hWzHW"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--Sig_/zZth.15U7q6c4+IBs2hWzHW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Naoya,

On Fri, 13 Jun 2014 11:12:06 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.c=
om> wrote:
>
> On Fri, Jun 13, 2014 at 03:05:50PM +1000, Stephen Rothwell wrote:
> >=20
> > After merging the akpm-current tree, today's linux-next build (powerpc =
ppc64_defconfig)
> > failed like this:
> >=20
> > fs/proc/task_mmu.c: In function 'smaps_pmd':
> > include/linux/compiler.h:363:38: error: call to '__compiletime_assert_5=
05' declared with attribute error: BUILD_BUG failed
> >   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> >                                       ^
> > include/linux/compiler.h:346:4: note: in definition of macro '__compile=
time_assert'
> >     prefix ## suffix();    \
> >     ^
> > include/linux/compiler.h:363:2: note: in expansion of macro '_compileti=
me_assert'
> >   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> >   ^
> > include/linux/bug.h:50:37: note: in expansion of macro 'compiletime_ass=
ert'
> >  #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
> >                                      ^
> > include/linux/bug.h:84:21: note: in expansion of macro 'BUILD_BUG_ON_MS=
G'
> >  #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
> >                      ^
> > include/linux/huge_mm.h:167:27: note: in expansion of macro 'BUILD_BUG'
> >  #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
> >                            ^
> > fs/proc/task_mmu.c:505:39: note: in expansion of macro 'HPAGE_PMD_SIZE'
> >   smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
> >                                        ^
> >=20
> > Caused by commit b0e08c526179 ("mm/pagewalk: move pmd_trans_huge_lock()
> > from callbacks to common code").
> >=20
> > The reference to HPAGE_PMD_SIZE (which contains a BUILD_BUG() when
> > CONFIG_TRANSPARENT_HUGEPAGE is not defined) used to be protected by a
> > call to pmd_trans_huge_lock() (a static inline function that was
> > contact 0 when CONFIG_TRANSPARENT_HUGEPAGE is not defined) so gcc did
> > not see the reference and the BUG_ON.  That protection has been
> > removed ...
> >=20
> > I have reverted that commit and commit 2dc554765dd1
> > ("mm-pagewalk-move-pmd_trans_huge_lock-from-callbacks-to-common-code-ch=
eckpatch-fixes")
> > that depend on it for today.
>=20
> Sorry about that, this build failure happens because I moved the
> pmd_trans_huge_lock() into the common pagewalk code,
> clearly this makes mm_walk->pmd_entry handle only transparent hugepage,
> so the additional patch below explicitly declare it with #ifdef
> CONFIG_TRANSPARENT_HUGEPAGE.
>=20
> I'll merge this in the next version of my series, but this will help
> linux-next for a quick solution.
>=20
> Thanks,
> Naoya Horiguchi
> ---
> From da0850cd03baa3d50c8e353976b5b9edbfbd4413 Mon Sep 17 00:00:00 2001
> Date: Fri, 13 Jun 2014 10:33:26 -0400
> Subject: [PATCH] fix build error of v3.15-mmotm-2014-06-12-16-38
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

I added that to the akpm-current tree in linux-next today and the build
failures went away.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au


--Sig_/zZth.15U7q6c4+IBs2hWzHW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTnlAVAAoJEMDTa8Ir7ZwVgp0P/1wf84gPCsAYfq+GPjEKff3D
onSccGzVUP3dp2ll1eRoIAKvK1wOpDhdqeX3csOFXdjfmoWo3/M2krVnnf7RU5QN
1OBs26iIRMsjp+X3CMBktT66jwSEiUvuWs7eg7hN/utJHoTXdx5psjgsUGSfco8T
RbkQkLbdfHxDzeoakfVn8ykkLqAkEROb4xcTRCezSZeuupUHg4W8aaNu+F+RMeTp
j/R33lUylSUw1EuEbzeAGB9l0m8cGLakENrLRLln8CJLzTTwtdt5/l4jip9ddDeP
pOvSWNdME304AOlzfLmX6CKIuF2KEco5EilbP72oH2MWsuwJh1nCK1xVUUOPFzzP
8dIy8AntnL518e4Q1o95ma9sh1jyzD+osqQhwlxEFf8AY7K9htSg3eP72vjGk502
dO05M/2CWfU49RjsNytdU/bIdOKlUQ1ubzl4YI1RELOzUkcZQMVUidmStu7auMhB
e79Z4md/6PgXCureChkgQVOJicwwNh3tD6UQ7XggbsQpBAiHxU96/ky/HsPPJ9ne
423qX1Vr6s/4rRprjLoFJXM9f+s0Uud9xErTIyLbHtgw8l3Y5c/ty2Xm9dYC88qI
5yo3trUA2NtSM+jFFlp+MWXkxnUL4n5bo2FkT7PdhWwJvVS9uyyAdlZiMWSRrMLD
vSYjVh2csernoZcXc9/L
=WIZ5
-----END PGP SIGNATURE-----

--Sig_/zZth.15U7q6c4+IBs2hWzHW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
