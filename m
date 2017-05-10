Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF8E83204
	for <linux-mm@kvack.org>; Tue,  9 May 2017 22:47:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d11so15009185pgn.9
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:47:13 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id w126si1674716pgb.395.2017.05.09.19.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 19:47:12 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u187so2230429pgb.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:47:12 -0700 (PDT)
Date: Wed, 10 May 2017 10:47:10 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] oom: improve oom disable handling
Message-ID: <20170510024710.GB8480@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170404134705.6361-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="cmJC7u66zC7hs+87"
Content-Disposition: inline
In-Reply-To: <20170404134705.6361-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--cmJC7u66zC7hs+87
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi, Michal

If the subject is "improve the log message on oom disable handling" would be
more accurate to me.

The original subject sounds the patch will adjust the code path, while it
doesn't.

On Tue, Apr 04, 2017 at 03:47:05PM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>Tetsuo has reported that sysrq triggered OOM killer will print a
>misleading information when no tasks are selected:
>
>[  713.805315] sysrq: SysRq : Manual OOM execution
>[  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacr=
ifice child
>[  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1=
760kB, file-rss:0kB, shmem-rss:0kB
>[  714.004805] sysrq: SysRq : Manual OOM execution
>[  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 =
or sacrifice child
>[  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, ano=
n-rss:120kB, file-rss:0kB, shmem-rss:0kB
>[  714.189310] sysrq: SysRq : Manual OOM execution
>[  714.193425] sysrq: OOM request ignored because killer is disabled
>[  714.381313] sysrq: SysRq : Manual OOM execution
>[  714.385158] sysrq: OOM request ignored because killer is disabled
>[  714.573320] sysrq: SysRq : Manual OOM execution
>[  714.576988] sysrq: OOM request ignored because killer is disabled
>
>The real reason is that there are no eligible tasks for the OOM killer
>to select but since 7c5f64f84483bd13 ("mm: oom: deduplicate victim
>selection code for memcg and global oom") the semantic of out_of_memory
>has changed without updating moom_callback.
>
>This patch updates moom_callback to tell that no task was eligible
>which is the case for both oom killer disabled and no eligible tasks.
>In order to help distinguish first case from the second add printk to
>both oom_killer_{enable,disable}. This information is useful on its own
>because it might help debugging potential memory allocation failures.
>
>Fixes: 7c5f64f84483bd13 ("mm: oom: deduplicate victim selection code for m=
emcg and global oom")
>Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
> drivers/tty/sysrq.c | 2 +-
> mm/oom_kill.c       | 2 ++
> 2 files changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
>index 71136742e606..a91f58dc2cb6 100644
>--- a/drivers/tty/sysrq.c
>+++ b/drivers/tty/sysrq.c
>@@ -370,7 +370,7 @@ static void moom_callback(struct work_struct *ignored)
>=20
> 	mutex_lock(&oom_lock);
> 	if (!out_of_memory(&oc))
>-		pr_info("OOM request ignored because killer is disabled\n");
>+		pr_info("OOM request ignored. No task eligible\n");
> 	mutex_unlock(&oom_lock);
> }
>=20
>diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>index 51c091849dcb..ad2b112cdf3e 100644
>--- a/mm/oom_kill.c
>+++ b/mm/oom_kill.c
>@@ -682,6 +682,7 @@ void exit_oom_victim(void)
> void oom_killer_enable(void)
> {
> 	oom_killer_disabled =3D false;
>+	pr_info("OOM killer enabled.\n");
> }
>=20
> /**
>@@ -718,6 +719,7 @@ bool oom_killer_disable(signed long timeout)
> 		oom_killer_enable();
> 		return false;
> 	}
>+	pr_info("OOM killer disabled.\n");
>=20
> 	return true;
> }
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--cmJC7u66zC7hs+87
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZEn8uAAoJEKcLNpZP5cTdFccP/1l8EofM1xxfV6X6Y2CzO1DH
6uPwpUminrC5tOqctHnwFLfAqo9KtwCWGoKoAwOIw7URGUPYua7Z59CkK4T+d9AO
r0C4qJuFv0WS8fFaELowVhzI1Usaj6jl1gcuP2iomO9hY4bTvsS0EQyCtqVubm3b
LdoRo/yGWt7M5wPwHM/6y4GeQcINzyLSX0kGsF0tVm+Lc9v1EZTPGDEKF11r9T7O
Klo91re7p9p+eK+4R/1rpBb/mge4vME1/I8qZqO2KvKlWyzb76qlZrWtHMhI9jMe
IScyqK0F/a7cHjnd/5Lxh10wTKWR+2BkpeyILh1+ywJptu9SqTECMBOGRKs3j0Wz
fNo5KhaMI8VBsRwSspDm1PF2G2HNmEXME78sF34RrRufgEUfGillvzVHa5VQkK0x
yq6ohc1qB7pFNFX8O6o0t1AtXAMFUV93lgR6EDbINtq7sZlrwkuuQU0OYnm+A2le
7cpvMZu+msdyZN7pwvSOuQvyt1auSiC6wIVEMxuMOnf2Yzi2ApeAhrqyMBE9n7S5
PDQncF+BsCmGD/xQn4Dy2vwbji/B96LNCebhq4LZzRb5zYddqQN0ujMhEnNAEe7L
Aoj44GXzqFMVEAxrgfngcyalqugscWdJDrCOEmIkh9wb8qdYIUrh6zhYNRr3EkQg
48/UmxAaEVmzqYMgTEOA
=/Z5U
-----END PGP SIGNATURE-----

--cmJC7u66zC7hs+87--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
