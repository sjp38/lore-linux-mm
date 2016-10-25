Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50CC06B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 07:33:57 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z82so207866901qkb.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 04:33:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si1823565qtb.60.2016.10.25.04.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 04:33:56 -0700 (PDT)
Date: Tue, 25 Oct 2016 13:33:47 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] slub: avoid false-postive warning
Message-ID: <20161025133347.73b501fc@redhat.com>
In-Reply-To: <20161024155704.3114445-1-arnd@arndb.de>
References: <20161024155704.3114445-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <labbott@fedoraproject.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, brouer@redhat.com, Alexander Duyck <alexander.duyck@gmail.com>


On Mon, 24 Oct 2016 17:56:13 +0200 Arnd Bergmann <arnd@arndb.de> wrote:

> The slub allocator gives us some incorrect warnings when
> CONFIG_PROFILE_ANNOTATED_BRANCHES is set, as the unlikely()
> macro prevents it from seeing that the return code matches
> what it was before:
>=20
> mm/slub.c: In function =E2=80=98kmem_cache_free_bulk=E2=80=99:
> mm/slub.c:262:23: error: =E2=80=98df.s=E2=80=99 may be used uninitialized=
 in this function [-Werror=3Dmaybe-uninitialized]
> mm/slub.c:2943:3: error: =E2=80=98df.cnt=E2=80=99 may be used uninitializ=
ed in this function [-Werror=3Dmaybe-uninitialized]
> mm/slub.c:2933:4470: error: =E2=80=98df.freelist=E2=80=99 may be used uni=
nitialized in this function [-Werror=3Dmaybe-uninitialized]
> mm/slub.c:2943:3: error: =E2=80=98df.tail=E2=80=99 may be used uninitiali=
zed in this function [-Werror=3Dmaybe-uninitialized]
>=20
> I have not been able to come up with a perfect way for dealing with
> this, the three options I see are:
>=20
> - add a bogus initialization, which would increase the runtime overhead
> - replace unlikely() with unlikely_notrace()
> - remove the unlikely() annotation completely
>=20
> I checked the object code for a typical x86 configuration and the
> last two cases produce the same result, so I went for the last
> one, which is the simplest.

If the object code is the same, then I've fine with this solution, as
the performance should then also be the same.

I do have micro-benchmark module there to verify the performance:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/sla=
b_bulk_test01.c

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>


> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/slub.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/slub.c b/mm/slub.c
> index 2b3e740609e9..68b84f93d38d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3076,7 +3076,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, siz=
e_t size, void **p)
>  		struct detached_freelist df;
> =20
>  		size =3D build_detached_freelist(s, size, p, &df);
> -		if (unlikely(!df.page))
> +		if (!df.page)
>  			continue;
> =20
>  		slab_free(df.s, df.page, df.freelist, df.tail, df.cnt,_RET_IP_);



--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
