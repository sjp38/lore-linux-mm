Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 8650D6B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 17:00:52 -0500 (EST)
MIME-Version: 1.0
Message-ID: <0621544c-dbb7-44ff-bfd0-ee623439bd9d@default>
Date: Thu, 28 Feb 2013 14:00:36 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
In-Reply-To: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, sjenning@linux.vnet.ibm.com, Nitin Gupta <nitingupta910@gmail.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

> From: Dan Magenheimer
> Subject: zsmalloc limitations and related topics
>=20
> WORKLOAD ANALYSIS
>   :
> 1) The average page compressed by almost a factor of six
>    (mean zsize =3D=3D 694, stddev =3D=3D 474)
> 2) Almost eleven percent of the pages were zero pages.  A
>    zero page compresses to 28 bytes.
> 3) On average, 77% of the bytes (3156) in the pages-to-be-
>    compressed contained a byte-value of zero.
> 4) Despite the above, mean density of zsmalloc was measured at
>    3.2 zpages/pageframe, presumably losing nearly half of
>    available space to fragmentation.
>=20
> I have no clue if these measurements are representative
> of a wide range of workloads over the lifetime of a booted
> machine, but I am suspicious that they are not.  For example,
> the lzo1x compression algorithm claims to compress data by
> about a factor of two.

I realized that with a small hack in zswap, I could simulate the
effect on zsmalloc of a workload with very different zsize
distribution, one with a much higher mean, by simply doubling
(and tripling) the zsize passed to zs_malloc.  The results:

Unchanged: mean=3D694 stddev=3D474 -> mean density =3D 3.2
Doubled:   mean=3D1340 stddev=3D842 -> mean density =3D 1.9
Tripled:   mean=3D1636 stddev=3D1031 -> mean density =3D 1.6

Note that even tripled, the mean of the simulated
distribution is still much lower than PAGE_SIZE/2,
which is roughly the published expected compression for
lzo1x.  So one would still expect a mean density greater
than two but, apparently, one-third of available space is
lost to fragmentation.

Without a "representative" workload, I still have no clue
as to whether this simulated distribution is relevant,
but it is interesting to note that, for a workload with
lower mean compressibility, zsmalloc's reputation as
"high density" may be undeserved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
