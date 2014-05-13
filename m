Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4486B0038
	for <linux-mm@kvack.org>; Tue, 13 May 2014 06:59:00 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so185519wgg.0
        for <linux-mm@kvack.org>; Tue, 13 May 2014 03:58:59 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ey10si3668998wib.76.2014.05.13.03.58.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 03:58:59 -0700 (PDT)
Date: Tue, 13 May 2014 12:58:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 04/19] mm: page_alloc: Use jump labels to avoid checking
 number_of_cpusets
Message-ID: <20140513105851.GA30445@twins.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4c4BJozgj/kzMVO6"
Content-Disposition: inline
In-Reply-To: <1399974350-11089-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>


--4c4BJozgj/kzMVO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 13, 2014 at 10:45:35AM +0100, Mel Gorman wrote:
> +#ifdef HAVE_JUMP_LABEL
> +extern struct static_key cpusets_enabled_key;
> +static inline bool cpusets_enabled(void)
> +{
> +	return static_key_false(&cpusets_enabled_key);
> +}
> +
> +/* jump label reference count + the top-level cpuset */
> +#define number_of_cpusets (static_key_count(&cpusets_enabled_key) + 1)
> +
> +static inline void cpuset_inc(void)
> +{
> +	static_key_slow_inc(&cpusets_enabled_key);
> +}
> +
> +static inline void cpuset_dec(void)
> +{
> +	static_key_slow_dec(&cpusets_enabled_key);
> +}
> +
> +static inline void cpuset_init_count(void) { }
> +
> +#else
>  extern int number_of_cpusets;	/* How many cpusets are defined in system?=
 */
> =20
> +static inline bool cpusets_enabled(void)
> +{
> +	return number_of_cpusets > 1;
> +}
> +
> +static inline void cpuset_inc(void)
> +{
> +	number_of_cpusets++;
> +}
> +
> +static inline void cpuset_dec(void)
> +{
> +	number_of_cpusets--;
> +}
> +
> +static inline void cpuset_init_count(void)
> +{
> +	number_of_cpusets =3D 1;
> +}
> +#endif /* HAVE_JUMP_LABEL */

I'm still puzzled by the whole #else branch here, why not
unconditionally use the jump-label one? Without HAVE_JUMP_LABEL we'll
revert to a simple atomic_t counter, which should be perfectly fine, no?

--4c4BJozgj/kzMVO6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTcfrrAAoJEHZH4aRLwOS6XoAP/jmtiAj7/XQEYREzCkOSstsD
SayN+T3PUPpyB+BIjPU/n5RrY2Xp7O4dKJKIEmW4oACYmvT4l1jQP17J08Sm8wPn
YdRYg/28pFiTPTpbhrdLlqlWumyb9Ef7a9M37otQ7NOCVboNhN5AKoZjEpH5Tf5/
ISVny4MDhJ1pYe4dl9SIR7iRrznIO6hS3YaVBPp1cfYI2L30/Hz/UNuhFMEgKgXC
a0qau1SycwmsuS+xwaLw6KM+wseKtkPknQ3uwf4ClJzZRAdyXaukOR8LU7+ZLknV
fFQ4JncnOwaSHMNrnmQkhOIhPIuQwMmyZvSzRSX9gKh++G9SD16QWAfiu8u25Hna
8kHDYQxkG/5z0BlzHojQ2qETGVks+8thgY6niq7GuNEfEwNTrr/QIi3se+XZOfSJ
SPdPkQgIHil2PQt/NYKLAxVjaR961tondV6Ye8les+xB/pdX61x1mnculG3TTrVe
NPVsHebK16C1LZQBtVIvpEO+XVTufWgrGbKdCXYaHNiVY8gOF12kJQ+4Gnjf4XyF
+koylH+2o13CEeiS85Uc21vA9JJNGWnxe4b0VPX93Ifu88lp//1sKvIrHmY2wweL
PpInagsXwYpMlVhFBbkfse74ch7cwes+LH1KOGcguCsjHboIgl14JSXdRietO//V
TAHAD/fy/Jre5SVnMhRg
=L/qV
-----END PGP SIGNATURE-----

--4c4BJozgj/kzMVO6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
