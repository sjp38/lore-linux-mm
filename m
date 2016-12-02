Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEDD96B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 03:19:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so1648354wms.7
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 00:19:49 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id j133si1989065wma.86.2016.12.02.00.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 00:19:48 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id g23so9294937wme.1
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 00:19:48 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.1 \(3251\))
Subject: Re: [PATCH] mm: use vmalloc fallback path for certain memcg
 allocations
From: Alexey Lyashkov <umka@cloudlinux.com>
In-Reply-To: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
Date: Fri, 2 Dec 2016 11:19:45 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <8EB96A3D-F5B3-4358-A1A9-049866875C12@cloudlinux.com>
References: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anatoly Stepanov <astepanov@cloudlinux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com, panda@cloudlinux.com, vmeshkov@cloudlinux.com


> 1 =D0=B4=D0=B5=D0=BA. 2016 =D0=B3., =D0=B2 4:16, Anatoly Stepanov =
<astepanov@cloudlinux.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0=
):
>=20
> As memcg array size can be up to:
> sizeof(struct memcg_cache_array) + kmemcg_id * sizeof(void *);
>=20
> where kmemcg_id can be up to MEMCG_CACHES_MAX_SIZE.
>=20
> When a memcg instance count is large enough it can lead
> to high order allocations up to order 7.
>=20
> The same story with memcg_lrus allocations.
> So let's work this around by utilizing vmalloc fallback path.
>=20
> Signed-off-by: Anatoly Stepanov <astepanov@cloudlinux.com>
> ---
> include/linux/memcontrol.h | 16 ++++++++++++++++
> mm/list_lru.c              | 14 +++++++-------
> mm/slab_common.c           | 21 ++++++++++++++-------
> 3 files changed, 37 insertions(+), 14 deletions(-)
>=20
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 61d20c1..a281622 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -29,6 +29,9 @@
> #include <linux/mmzone.h>
> #include <linux/writeback.h>
> #include <linux/page-flags.h>
> +#include <linux/vmalloc.h>
> +#include <linux/slab.h>
> +#include <linux/mm.h>
>=20
> struct mem_cgroup;
> struct page;
> @@ -878,4 +881,17 @@ static inline void =
memcg_kmem_update_page_stat(struct page *page,
> }
> #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
>=20
> +static inline void memcg_free(const void *ptr)
> +{
> +	is_vmalloc_addr(ptr) ? vfree(ptr) : kfree(ptr);
> +}
please to use a kvfree() instead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
