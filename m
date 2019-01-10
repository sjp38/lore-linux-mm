Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93D148E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:12:36 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id q62so6199887pgq.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:12:36 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c10si28105749pla.173.2019.01.10.04.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 04:12:35 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm: memcontrol: use struct_size() in kmalloc()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190104183726.GA6374@embeddedor>
Date: Thu, 10 Jan 2019 05:12:17 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <8B12C965-1406-4464-96FF-B9C04187DD7D@oracle.com>
References: <20190104183726.GA6374@embeddedor>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Jan 4, 2019, at 11:37 AM, Gustavo A. R. Silva =
<gustavo@embeddedor.com> wrote:
>=20
> One of the more common cases of allocation size calculations is =
finding
> the size of a structure that has a zero-sized array at the end, along
> with memory for some number of elements for that array. For example:
>=20
> struct foo {
>    int stuff;
>    void *entry[];
> };
>=20
> instance =3D kmalloc(sizeof(struct foo) + sizeof(void *) * count, =
GFP_KERNEL);
>=20
> Instead of leaving these open-coded and prone to type mistakes, we can
> now use the new struct_size() helper:
>=20
> instance =3D kmalloc(struct_size(instance, entry, count), GFP_KERNEL);
>=20
> This code was detected with the help of Coccinelle.
>=20
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
> mm/memcontrol.c | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index af7f18b32389..ad256cf7da47 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3626,8 +3626,7 @@ static int =
__mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
> 	size =3D thresholds->primary ? thresholds->primary->size + 1 : =
1;
>=20
> 	/* Allocate memory for new array of thresholds */
> -	new =3D kmalloc(sizeof(*new) + size * sizeof(struct =
mem_cgroup_threshold),
> -			GFP_KERNEL);
> +	new =3D kmalloc(struct_size(new, entries, size), GFP_KERNEL);
> 	if (!new) {
> 		ret =3D -ENOMEM;
> 		goto unlock;
> --=20
> 2.20.1
>=20

Reviewed-by: William Kucharski <william.kucharski@oracle.com>=
