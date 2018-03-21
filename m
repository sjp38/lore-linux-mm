Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 397286B0007
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 00:14:37 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f3so2341292qkd.21
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 21:14:37 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id m129si1766337qkc.116.2018.03.20.21.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 21:14:36 -0700 (PDT)
Subject: Re: [PATCH 03/15] mm/hmm: HMM should have a callback before MM is
 destroyed v2
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-4-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d89e417d-c939-4d18-72f5-08b22dc6cff0@nvidia.com>
Date: Tue, 20 Mar 2018 21:14:34 -0700
MIME-Version: 1.0
In-Reply-To: <20180320020038.3360-4-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
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
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: stable@vger.kernel.org
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 10 ++++++++++
>  mm/hmm.c            | 18 +++++++++++++++++-
>  2 files changed, 27 insertions(+), 1 deletion(-)
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
> index 320545b98ff5..6088fa6ed137 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -160,6 +160,21 @@ static void hmm_invalidate_range(struct hmm *hmm,
>  	up_read(&hmm->mirrors_sem);
>  }
> =20
> +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	struct hmm *hmm =3D mm->hmm;
> +	struct hmm_mirror *mirror;
> +	struct hmm_mirror *mirror_next;
> +
> +	down_write(&hmm->mirrors_sem);
> +	list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
> +		list_del_init(&mirror->list);
> +		if (mirror->ops->release)
> +			mirror->ops->release(mirror);

Hi Jerome,

This presents a deadlock problem (details below). As for solution ideas,=20
Mark Hairgrove points out that the MMU notifiers had to solve the
same sort of problem, and part of the solution involves "avoid
holding locks when issuing these callbacks". That's not an entire=20
solution description, of course, but it seems like a good start.

Anyway, for the deadlock problem:

Each of these ->release callbacks potentially has to wait for the=20
hmm_invalidate_range() callbacks to finish. That is not shown in any
code directly, but it's because: when a device driver is processing=20
the above ->release callback, it has to allow any in-progress operations=20
to finish up (as specified clearly in your comment documentation above).=20

Some of those operations will invariably need to do things that result=20
in page invalidations, thus triggering the hmm_invalidate_range() callback.
Then, the hmm_invalidate_range() callback tries to acquire the same=20
hmm->mirrors_sem lock, thus leading to deadlock:

hmm_invalidate_range():
// ...
	down_read(&hmm->mirrors_sem);
	list_for_each_entry(mirror, &hmm->mirrors, list)
		mirror->ops->sync_cpu_device_pagetables(mirror, action,
							start, end);
	up_read(&hmm->mirrors_sem);

thanks,
--
John Hubbard
NVIDIA
