Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68D4F6B0009
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 02:58:27 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e17so4939515qtm.13
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 23:58:27 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 14si3475653qts.117.2018.03.21.23.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 23:58:26 -0700 (PDT)
Subject: Re: [PATCH 03/15] mm/hmm: HMM should have a callback before MM is
 destroyed v3
References: <20180320020038.3360-4-jglisse@redhat.com>
 <20180322012848.6936-1-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0fd1e592-83db-99d6-4e69-dab65e20621f@nvidia.com>
Date: Wed, 21 Mar 2018 23:58:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180322012848.6936-1-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/21/2018 06:28 PM, jglisse@redhat.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
>=20
> The hmm_mirror_register() function registers a callback for when
> the CPU pagetable is modified. Normally, the device driver will
> call hmm_mirror_unregister() when the process using the device is
> finished. However, if the process exits uncleanly, the struct_mm
> can be destroyed with no warning to the device driver.
>=20
> Changed since v1:
>   - dropped VM_BUG_ON()
>   - cc stable
> Changed since v2:
>   - drop stable
>   - Split list removale and call to driver release callback. This
>     allow the release callback to wait on any pending fault handler
>     without deadlock.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 10 ++++++++++
>  mm/hmm.c            | 29 ++++++++++++++++++++++++++++-
>  2 files changed, 38 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 36dd21fe5caf..fa7b51f65905 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -218,6 +218,16 @@ enum hmm_update_type {
>   * @update: callback to update range on a device
>   */
>  struct hmm_mirror_ops {
> +	/* release() - release hmm_mirror
> +	 *
> +	 * @mirror: pointer to struct hmm_mirror
> +	 *
> +	 * This is called when the mm_struct is being released.
> +	 * The callback should make sure no references to the mirror occur
> +	 * after the callback returns.
> +	 */
> +	void (*release)(struct hmm_mirror *mirror);
> +
>  	/* sync_cpu_device_pagetables() - synchronize page tables
>  	 *
>  	 * @mirror: pointer to struct hmm_mirror
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 320545b98ff5..34c16297f65e 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -160,6 +160,32 @@ static void hmm_invalidate_range(struct hmm *hmm,
>  	up_read(&hmm->mirrors_sem);
>  }
> =20
> +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	struct hmm_mirror *mirror;
> +	struct hmm *hmm =3D mm->hmm;
> +
> +	down_write(&hmm->mirrors_sem);
> +	mirror =3D list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
> +					  list);
> +	while (mirror) {
> +		list_del_init(&mirror->list);
> +		if (mirror->ops->release) {
> +			/*
> +			 * Drop mirrors_sem so callback can wait on any pending
> +			 * work that might itself trigger mmu_notifier callback
> +			 * and thus would deadlock with us.
> +			 */
> +			up_write(&hmm->mirrors_sem);
> +			mirror->ops->release(mirror);
> +			down_write(&hmm->mirrors_sem);
> +		}
> +		mirror =3D list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
> +						  list);
> +	}
> +	up_write(&hmm->mirrors_sem);
> +}
> +

Hi Jerome,

This looks good (and the list handling is way better than my horrible=20
copy-the-list idea)!

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

>  static void hmm_invalidate_range_start(struct mmu_notifier *mn,
>  				       struct mm_struct *mm,
>  				       unsigned long start,
> @@ -185,6 +211,7 @@ static void hmm_invalidate_range_end(struct mmu_notif=
ier *mn,
>  }
> =20
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops =3D {
> +	.release		=3D hmm_release,
>  	.invalidate_range_start	=3D hmm_invalidate_range_start,
>  	.invalidate_range_end	=3D hmm_invalidate_range_end,
>  };
> @@ -230,7 +257,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
>  	struct hmm *hmm =3D mirror->hmm;
> =20
>  	down_write(&hmm->mirrors_sem);
> -	list_del(&mirror->list);
> +	list_del_init(&mirror->list);
>  	up_write(&hmm->mirrors_sem);
>  }
>  EXPORT_SYMBOL(hmm_mirror_unregister);
>=20
