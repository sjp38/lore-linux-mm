Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B77AA6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 16:42:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z67so139847159pgb.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 13:42:36 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g1si26107130pgc.92.2017.01.17.13.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 13:42:35 -0800 (PST)
Date: Tue, 17 Jan 2017 13:42:35 -0800
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots
 allocation
Message-ID: <20170117214234.GA14383@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
 <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
In-Reply-To: <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim C Chen <tim.c.chen@intel.com>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 17, 2017 at 10:55:47AM +0800, Huang, Ying wrote:
> Hi, Andrew,
>=20
> This update patch is to fix the preemption warning raised by Michal
> Hocko.  raw_cpu_ptr() is used to replace this_cpu_ptr() and comments are
> added for why it is used.
>=20

Andrew & Michal,

Here's a fix that's a follow on patch instead of an updated patch
as Michal has suggested.  I've updated the comments a bit to make it
clearer.

Thanks.

Tim

--->8---
Date: Tue, 17 Jan 2017 12:57:00 -0800
Subject: [PATCH] mm/swap: Use raw_cpu_ptr over this_cpu_ptr for swap slots
 access
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.inte=
l.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org=
, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Ki=
m <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <a=
arcange@redhat.com>, Kirill A . Shutemov <kirill.shutemov@linux.intel.com>,=
 Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg=
=2Eorg>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-i=
nc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <c=
orbet@lwn.net>

=46rom: "Huang, Ying" <ying.huang@intel.com>

The usage of this_cpu_ptr in get_swap_page causes a bug warning
as it is used in pre-emptible code.

[   57.812314] BUG: using smp_processor_id() in preemptible [00000000] code=
: kswapd0/527
[   57.814360] caller is debug_smp_processor_id+0x17/0x19
[   57.815237] CPU: 1 PID: 527 Comm: kswapd0 Tainted: G        W 4.9.0-mmot=
m-00135-g4e9a9895ebef #1042
[   57.816019] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.10.1-1 04/01/2014
[   57.816019]  ffffc900001939c0 ffffffff81329c60 0000000000000001 ffffffff=
81a0ce06
[   57.816019]  ffffc900001939f0 ffffffff81343c2a 00000000000137a0 ffffea00=
00dfd2a0
[   57.816019]  ffff88003c49a700 ffffc90000193b10 ffffc90000193a00 ffffffff=
81343c53
[   57.816019] Call Trace:
[   57.816019]  [<ffffffff81329c60>] dump_stack+0x68/0x92
[   57.816019]  [<ffffffff81343c2a>] check_preemption_disabled+0xce/0xe0
[   57.816019]  [<ffffffff81343c53>] debug_smp_processor_id+0x17/0x19
[   57.816019]  [<ffffffff8115f06f>] get_swap_page+0x19/0x183
[   57.816019]  [<ffffffff8114e01d>] shmem_writepage+0xce/0x38c
[   57.816019]  [<ffffffff81148916>] shrink_page_list+0x81f/0xdbf
[   57.816019]  [<ffffffff81149652>] shrink_inactive_list+0x2ab/0x594
[   57.816019]  [<ffffffff8114a22f>] shrink_node_memcg+0x4c7/0x673
[   57.816019]  [<ffffffff8114a49f>] shrink_node+0xc4/0x282
[   57.816019]  [<ffffffff8114a49f>] ? shrink_node+0xc4/0x282
[   57.816019]  [<ffffffff8114b8cb>] kswapd+0x656/0x834

Logic wise, We do allow pre-emption as per cpu ptr cache->slots is
protected by the mutex cache->alloc_lock.  We switch the
inappropriately used this_cpu_ptr to raw_cpu_ptr for per cpu ptr
access of cache->slots.

Reported-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/swap_slots.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 8cf941e..9b5bc86 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -303,7 +303,16 @@ swp_entry_t get_swap_page(void)
 	swp_entry_t entry, *pentry;
 	struct swap_slots_cache *cache;
=20
-	cache =3D this_cpu_ptr(&swp_slots);
+	/*
+	 * Preemption is allowed here, because we may sleep
+	 * in refill_swap_slots_cache().  But it is safe, because
+	 * accesses to the per-CPU data structure are protected by the
+	 * mutex cache->alloc_lock.
+	 *
+	 * The alloc path here does not touch cache->slots_ret
+	 * so cache->free_lock is not taken.
+	 */
+	cache =3D raw_cpu_ptr(&swp_slots);
=20
 	entry.val =3D 0;
 	if (check_cache_active()) {
--=20
2.5.5


--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYfo/KAAoJEKJntYqi1rhJMU8QAKlUQOzi7jp8od1tdH/7A+Qh
R6quSzU3d4sUUlX4o1eA4FCeFFqTKrAJozAury1869ZBwnoswR1J0Jq9sBZQCxrP
bvf4XAHC0oa4faUFgWYuEMx0N6Sh3j1EQBKAdupveffV9NUA2MQf7choNPi9bWKF
fWIwOThmO7CPQ/3XmpP2kdvzYIfqqpMVvGdpfGlL1qMd8W8HH36d5y1leo7GtmET
Fs/n5FQTFYOEXyrz1fnNcpCvOjpWcMDMNJtj0yenPLyUCJJxLVgyNkOBXMfbxCA9
WTSWXA0KhX/qK4sr4bIX7bVsfOgQdVWkzF09nnLCG7XA6laV4H+EXQgExAr3feso
LJ3mI7ieQfzrDTuV/q21MqNQMs7UvDitjk4yhhmQW4bsYv5tZRbSLad9BRXYQI0t
HpkGoBpWaoB1OvNyzBo8nUK276XCRLIMkvMYK9YxdupEwupQvngu5CxBCBYUoUdZ
u0uq+pwlZl83Mfu/YV+7OAbq83MnFK2PqzL9tpi4+vqtAZoybTrwBexhTilYGl6C
B76nGQhaN8jX20j7ECPIh/afcXHo51LAi4ifW6YQhTnVKFVVc2+TFvAD5a3D+CRD
A0R9klL+PXRDIAX39g7vlEAg3wsA8iNHu871zFYju295DbHzdz/ktMIFkcixOTZf
8Xi0QOCixeujF2w/82mN
=CuaE
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
