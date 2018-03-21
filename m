Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 844F16B000C
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 00:24:44 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r5so2354453qkb.22
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 21:24:44 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id l188si4037298qkb.1.2018.03.20.21.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 21:24:43 -0700 (PDT)
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-5-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <55b8cf9f-2a81-19f3-ff4f-70d5a411baaa@nvidia.com>
Date: Tue, 20 Mar 2018 21:24:41 -0700
MIME-Version: 1.0
In-Reply-To: <20180320020038.3360-5-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> This code was lost in translation at one point. This properly call
> mmu_notifier_unregister_no_release() once last user is gone. This
> fix the zombie mm_struct as without this patch we do not drop the
> refcount we have on it.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/hmm.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6088fa6ed137..667944630dc9 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -244,10 +244,29 @@ EXPORT_SYMBOL(hmm_mirror_register);
>  void hmm_mirror_unregister(struct hmm_mirror *mirror)
>  {
>  	struct hmm *hmm =3D mirror->hmm;
> +	struct mm_struct *mm =3D NULL;
> +	bool unregister =3D false;
> =20
>  	down_write(&hmm->mirrors_sem);
>  	list_del_init(&mirror->list);
> +	unregister =3D list_empty(&hmm->mirrors);

Hi Jerome,

This first minor point may be irrelevant, depending on how you fix=20
the other problem below, but: tiny naming idea: rename unregister=20
to either "should_unregister", or "mirror_snapshot_empty"...the=20
latter helps show that this is stale information, once the lock is=20
dropped.=20

>  	up_write(&hmm->mirrors_sem);
> +
> +	if (!unregister)
> +		return;

Whee, here I am, lock-free, in the middle of a race condition
window. :)  Right here, someone (hmm_mirror_register) could be adding
another mirror.

It's not immediately clear to me what the best solution is.
I'd be happier if we didn't have to drop one lock and take
another like this, but if we do, then maybe rechecking that
the list hasn't changed...safely, somehow, is a way forward here.


> +
> +	spin_lock(&hmm->mm->page_table_lock);
> +	if (hmm->mm->hmm =3D=3D hmm) {
> +		mm =3D hmm->mm;
> +		mm->hmm =3D NULL;
> +	}
> +	spin_unlock(&hmm->mm->page_table_lock);
> +
> +	if (mm =3D=3D NULL)
> +		return;
> +
> +	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
> +	kfree(hmm);
>  }
>  EXPORT_SYMBOL(hmm_mirror_unregister);
> =20

thanks,
--=20
John Hubbard
NVIDIA
=20
