Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA926B000D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 19:22:52 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q19so4288712qta.17
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:22:52 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id i66si826695qkd.103.2018.03.21.16.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 16:22:51 -0700 (PDT)
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit v2
References: <20180320020038.3360-5-jglisse@redhat.com>
 <20180321181614.9968-1-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <a9ba54c5-a2d9-49f6-16ad-46b79525b93c@nvidia.com>
Date: Wed, 21 Mar 2018 16:22:49 -0700
MIME-Version: 1.0
In-Reply-To: <20180321181614.9968-1-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/21/2018 11:16 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> This code was lost in translation at one point. This properly call
> mmu_notifier_unregister_no_release() once last user is gone. This
> fix the zombie mm_struct as without this patch we do not drop the
> refcount we have on it.
>=20
> Changed since v1:
>   - close race window between a last mirror unregistering and a new
>     mirror registering, which could have lead to use after free()
>     kind of bug
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/hmm.c | 35 +++++++++++++++++++++++++++++++++--
>  1 file changed, 33 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6088fa6ed137..f75aa8df6e97 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -222,13 +222,24 @@ int hmm_mirror_register(struct hmm_mirror *mirror, =
struct mm_struct *mm)
>  	if (!mm || !mirror || !mirror->ops)
>  		return -EINVAL;
> =20
> +again:
>  	mirror->hmm =3D hmm_register(mm);
>  	if (!mirror->hmm)
>  		return -ENOMEM;
> =20
>  	down_write(&mirror->hmm->mirrors_sem);
> -	list_add(&mirror->list, &mirror->hmm->mirrors);
> -	up_write(&mirror->hmm->mirrors_sem);
> +	if (mirror->hmm->mm =3D=3D NULL) {
> +		/*
> +		 * A racing hmm_mirror_unregister() is about to destroy the hmm
> +		 * struct. Try again to allocate a new one.
> +		 */
> +		up_write(&mirror->hmm->mirrors_sem);
> +		mirror->hmm =3D NULL;

This is being set outside of locks, so now there is another race with
another hmm_mirror_register...

I'll take a moment and draft up what I have in mind here, which is a more
symmetrical locking scheme for these routines.

thanks,
--=20
John Hubbard
NVIDIA
