Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2214E6B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:03:30 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so25743231pfb.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:03:30 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p84si881366pfj.259.2017.01.18.10.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 10:03:29 -0800 (PST)
Date: Wed, 18 Jan 2017 10:03:27 -0800
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots
 allocation
Message-ID: <20170118180327.GA24225@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
 <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
 <20170117214234.GA14383@linux.intel.com>
 <20170118124555.GQ7015@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
In-Reply-To: <20170118124555.GQ7015@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim C Chen <tim.c.chen@intel.com>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 18, 2017 at 01:45:55PM +0100, Michal Hocko wrote:
> On Tue 17-01-17 13:42:35, Tim Chen wrote:
> [...]
> > Logic wise, We do allow pre-emption as per cpu ptr cache->slots is
> > protected by the mutex cache->alloc_lock.  We switch the
> > inappropriately used this_cpu_ptr to raw_cpu_ptr for per cpu ptr
> > access of cache->slots.
>=20
> OK, that looks better. I would still appreciate something like the
> following folded in
> diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
> index fb907346c5c6..0afe748453a7 100644
> --- a/include/linux/swap_slots.h
> +++ b/include/linux/swap_slots.h
> @@ -11,6 +11,7 @@
> =20
>  struct swap_slots_cache {
>  	bool		lock_initialized;
> +	/* protects slots, nr, cur */
>  	struct mutex	alloc_lock;
>  	swp_entry_t	*slots;
>  	int		nr;
>=20

I've included here a patch for the comments.

Thanks.

Tim

--->8---
=46rom: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 18 Jan 2017 09:52:28 -0800
Subject: [PATCH] mm/swap: Add comments on locks in swap_slots.h
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

Explains what each lock protects in swap_slots_cache structure.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/swap_slots.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
index fb90734..6ef92d1 100644
--- a/include/linux/swap_slots.h
+++ b/include/linux/swap_slots.h
@@ -11,11 +11,11 @@
=20
 struct swap_slots_cache {
 	bool		lock_initialized;
-	struct mutex	alloc_lock;
+	struct mutex	alloc_lock; /* protects slots, nr, cur */
 	swp_entry_t	*slots;
 	int		nr;
 	int		cur;
-	spinlock_t	free_lock;
+	spinlock_t	free_lock;  /* protects slots_ret, n_ret */
 	swp_entry_t	*slots_ret;
 	int		n_ret;
 };
--=20
2.5.5


--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYf63vAAoJEKJntYqi1rhJQLwP/3nDcvTNHaXfSKtEHov97cWP
+x4DJCRSonAsFA1hwefE82aPCtBrytRAo5s0ngDu3c6w8sZLNV+o/8LaUOfzLohQ
LQKVQ1GI+NDbOhBimu/OX0egt908O7sL4+4L12T0/k32NSmSb96GEaUyXNQ0UNVa
bRBi7xY0pjQP2AdF4TaT88qHspZ0CdF/2Ji5AturlZz6Hl691Q+k911HCycvmEow
Er5Ncdirtu8TbJb8G9chkSf+vtvF587CwySnrwR+Qwp42nc7K+LJY8Q+yRzX1jpe
tbVK3F/9gK5HTEkN93K73CaFBPBbAzKWZ548EFSxf/kCcaDUY4CGHj3pKZaUuvcb
GwjmHhmieYpdtSOq3evetsYr15RE672aW9Oc3QvGRRwYi7b3k++k0YKQ2Np7N6k/
kBFcXzpt22v/rOlyJ5laZTjUtE7xNUqAWbAARhnweEOPVlsrNJCMz1EqQ2H0PRMo
Ypoq2vFBBsW5w+6aasUkLLQ1JDC17/SB3cjVgp9pJIbBTfA7PFhTqM9UNhpU+54E
fv66BOzguBHv7eDHpPGjRYMO3bxqoHw5iT9Q2teJH/lkUZHtTaS2GxhsfZpWJgSv
jdVjHQbHy777ZYeQBvugzhV98thkEHt1b2hB42uvc160VOT5DIwwkE+c9Fh3r7R9
h9XdhOJjSCLqfe+LHJVv
=8aK7
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
