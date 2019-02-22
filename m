Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6C5AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:02:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A20C20657
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:02:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="W3LlUkkt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A20C20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2086F8E0132; Fri, 22 Feb 2019 14:02:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DE338E0123; Fri, 22 Feb 2019 14:02:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A7978E0132; Fri, 22 Feb 2019 14:02:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id CADFF8E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:02:16 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id b8so1899004ywb.17
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:02:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mgXPsxbD97SKOiCEJPoI9+FWfJCL6GeisjAj6M00qm0=;
        b=aPZavou4F0aK7K/ASmeLeZxhiOgQ8+inCwpKYSP/uhWeQDoO9XFHyQC8F8DkLL6Pay
         VzKzbbUl/+zHiZmjKZ7QIVPFJ7ISWOJbEZcDi2HNzyoiWvyXPfBFyrvQsCAjg/QX6GyH
         JeEsNmADUmYbkRp/M0S0XHJPNvhV8Pg25A60ChglGBamqPO/Mw5wPFwr+bCdipLkCR+e
         7SycZ1kwcU9LIQN4ScSd2JrYPcD+wq2YPsZXbaKwqYFKISYFkatwvQ6WDRm8CI+fhlxV
         v6VHJC/z6fjEnLK4wXAuokZXA2RqX1AlblzJTxLiKbbucyoIJjzgUNG//66Hxo4HGKkw
         jdIQ==
X-Gm-Message-State: AHQUAubU0AaHdmw68+cz5dZgDWI2TPHRodLoUKCEgjl04vqM68bePZ0G
	CT+jNZ1E9uEp8HEmq+wlrb23mlHg7UdnYoy1UFHorPrWacw1GmIfN0aHPKmX05m7YI5PBP28mrZ
	JDYWDvMEv5Yf8u1PVFAe9GfxZ64h7jqACXc/CTa1Zm9Ix+5zgSZrUIexOQCz4jaNy6Q==
X-Received: by 2002:a25:1546:: with SMTP id 67mr4562628ybv.425.1550862136476;
        Fri, 22 Feb 2019 11:02:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYJgGK1seLtvyiq9kAgc5hrjBuzPoZzVwTeD9o4u4HzxQefP1U8GeQW/EQFGkYBlwTh4nJk
X-Received: by 2002:a25:1546:: with SMTP id 67mr4562544ybv.425.1550862135423;
        Fri, 22 Feb 2019 11:02:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550862135; cv=none;
        d=google.com; s=arc-20160816;
        b=0eefrSK93ZitTWqxVGbUCT0iKYLMYcXRcIKG/yZ+rngjYUAdIrP7eyts96nGAaiLiy
         O79hP+nMagelJzc6fdvE9lc/6pSV3mKx1tAAr2pJhm0wyZaRlbsB5vh3HNPlM512I11C
         ru6CNaRc8AanF0+AAe4cNpbZ+I4LDKY7hhIy87bXarb2YlyuXmqYOkpRIIkp46evxjJF
         VdQn+2u4L0U3pxh8NcjSqswEQanh2uVhKjoWgSFVmYQIAAptl50+V0FVv4YB3WdUBDYg
         wRGk2F8gE1H1MRLcjXl0BUECJg6gmRQxPZxU1eLscBvocZXBw2+7lhmWaSjTFJq5lGLq
         ghBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mgXPsxbD97SKOiCEJPoI9+FWfJCL6GeisjAj6M00qm0=;
        b=CC32Ucpiee98YUpLg/JsYYCf2alTRqUEi9TDiyEicP8zR+Aqp/GZK/4+SvKUgAFlgJ
         J+uNKkXsxFODiFNe817qGnxkFayTOHR9i0qRm7u56D/k02dgRAnMyXN0rNrB2KZGpWhV
         qgUGNdYDqc3aEbMP3BBhPDQhRSxAUPxc+wdBIlX7R1NCXWUnvuXDG8V3OoSHU8pDMx1X
         L/4kM7ATcbHrWx+zw+RYKJuiv4Ss9Qoa8nzPO+6nLjT+Tvlxic49RDaATMHKFAgqsF4/
         qNEZAMrgtUFtXBgDp0ChCLunSOnPG90h4INLgQ6GqaA07/WIn334EHb5p9vIjeOzys/b
         nFbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=W3LlUkkt;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id c4si1293772ybb.355.2019.02.22.11.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 11:02:15 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=W3LlUkkt;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7047340000>; Fri, 22 Feb 2019 11:02:12 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 11:02:14 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 22 Feb 2019 11:02:14 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 19:02:13 +0000
Subject: Re: [PATCH v5 2/9] mm/mmu_notifier: convert user range->blockable to
 helper function
To: <jglisse@redhat.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-kernel@vger.kernel.org>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, Andrea
 Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler
	<zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini
	<pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>,
	<kvm@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-rdma@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <20190219200430.11130-3-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <f09609c2-79f0-4b15-9eaa-23982c039e1a@nvidia.com>
Date: Fri, 22 Feb 2019 11:02:13 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-3-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550862132; bh=mgXPsxbD97SKOiCEJPoI9+FWfJCL6GeisjAj6M00qm0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=W3LlUkkteKWx9+h4NQ3O/0ej9NwaeVOiKvzT2mAVetN5vWFGIi3xOWKpZC1BZDp5S
	 FsXECXdJtBJUbA+/UVzfJarGz+SAcV+EvfcH5PuXzUGoM8cqCpYacBxahHiza2bIRO
	 bqU5tDpPEYPzYZrTjhs2n7HZvr8f3MOkvoP4MsSg0DRFQAXrHRvcgZctZj1JObHdM3
	 JI1lDn38TXDjF9nZDgC6rQOqQOdjAPcMO5UriAgVU+GMvYpQ5MG29cUu8+moMKzh4L
	 iqe68ZtucYFIZjkrjPmImNHQN9hrZdUj2ae509I4OV7fcPbFxlcD2EPrgXCSEt0E27
	 hSPlWWLHB4T/Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Use the mmu_notifier_range_blockable() helper function instead of
> directly dereferencing the range->blockable field. This is done to
> make it easier to change the mmu_notifier range field.
>=20
> This patch is the outcome of the following coccinelle patch:
>=20
> %<-------------------------------------------------------------------
> @@
> identifier I1, FN;
> @@
> FN(..., struct mmu_notifier_range *I1, ...) {
> <...
> -I1->blockable
> +mmu_notifier_range_blockable(I1)
> ...>
> }
> ------------------------------------------------------------------->%
>=20
> spatch --in-place --sp-file blockable.spatch --dir .
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 8 ++++----
>   drivers/gpu/drm/i915/i915_gem_userptr.c | 2 +-
>   drivers/gpu/drm/radeon/radeon_mn.c      | 4 ++--
>   drivers/infiniband/core/umem_odp.c      | 5 +++--
>   drivers/xen/gntdev.c                    | 6 +++---
>   mm/hmm.c                                | 6 +++---
>   mm/mmu_notifier.c                       | 2 +-
>   virt/kvm/kvm_main.c                     | 3 ++-
>   8 files changed, 19 insertions(+), 17 deletions(-)
>=20
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd=
/amdgpu/amdgpu_mn.c
> index 3e6823fdd939..58ed401c5996 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> @@ -256,14 +256,14 @@ static int amdgpu_mn_invalidate_range_start_gfx(str=
uct mmu_notifier *mn,
>   	/* TODO we should be able to split locking for interval tree and
>   	 * amdgpu_mn_invalidate_node
>   	 */
> -	if (amdgpu_mn_read_lock(amn, range->blockable))
> +	if (amdgpu_mn_read_lock(amn, mmu_notifier_range_blockable(range)))
>   		return -EAGAIN;
>  =20
>   	it =3D interval_tree_iter_first(&amn->objects, range->start, end);
>   	while (it) {
>   		struct amdgpu_mn_node *node;
>  =20
> -		if (!range->blockable) {
> +		if (!mmu_notifier_range_blockable(range)) {
>   			amdgpu_mn_read_unlock(amn);
>   			return -EAGAIN;
>   		}
> @@ -299,7 +299,7 @@ static int amdgpu_mn_invalidate_range_start_hsa(struc=
t mmu_notifier *mn,
>   	/* notification is exclusive, but interval is inclusive */
>   	end =3D range->end - 1;
>  =20
> -	if (amdgpu_mn_read_lock(amn, range->blockable))
> +	if (amdgpu_mn_read_lock(amn, mmu_notifier_range_blockable(range)))
>   		return -EAGAIN;
>  =20
>   	it =3D interval_tree_iter_first(&amn->objects, range->start, end);
> @@ -307,7 +307,7 @@ static int amdgpu_mn_invalidate_range_start_hsa(struc=
t mmu_notifier *mn,
>   		struct amdgpu_mn_node *node;
>   		struct amdgpu_bo *bo;
>  =20
> -		if (!range->blockable) {
> +		if (!mmu_notifier_range_blockable(range)) {
>   			amdgpu_mn_read_unlock(amn);
>   			return -EAGAIN;
>   		}
> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i9=
15/i915_gem_userptr.c
> index 1d3f9a31ad61..777b3f8727e7 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -122,7 +122,7 @@ userptr_mn_invalidate_range_start(struct mmu_notifier=
 *_mn,
>   	while (it) {
>   		struct drm_i915_gem_object *obj;
>  =20
> -		if (!range->blockable) {
> +		if (!mmu_notifier_range_blockable(range)) {
>   			ret =3D -EAGAIN;
>   			break;
>   		}
> diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/=
radeon_mn.c
> index b3019505065a..c9bd1278f573 100644
> --- a/drivers/gpu/drm/radeon/radeon_mn.c
> +++ b/drivers/gpu/drm/radeon/radeon_mn.c
> @@ -133,7 +133,7 @@ static int radeon_mn_invalidate_range_start(struct mm=
u_notifier *mn,
>   	/* TODO we should be able to split locking for interval tree and
>   	 * the tear down.
>   	 */
> -	if (range->blockable)
> +	if (mmu_notifier_range_blockable(range))
>   		mutex_lock(&rmn->lock);
>   	else if (!mutex_trylock(&rmn->lock))
>   		return -EAGAIN;
> @@ -144,7 +144,7 @@ static int radeon_mn_invalidate_range_start(struct mm=
u_notifier *mn,
>   		struct radeon_bo *bo;
>   		long r;
>  =20
> -		if (!range->blockable) {
> +		if (!mmu_notifier_range_blockable(range)) {
>   			ret =3D -EAGAIN;
>   			goto out_unlock;
>   		}
> diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core=
/umem_odp.c
> index 012044f16d1c..3a3f1538d295 100644
> --- a/drivers/infiniband/core/umem_odp.c
> +++ b/drivers/infiniband/core/umem_odp.c
> @@ -151,7 +151,7 @@ static int ib_umem_notifier_invalidate_range_start(st=
ruct mmu_notifier *mn,
>   	struct ib_ucontext_per_mm *per_mm =3D
>   		container_of(mn, struct ib_ucontext_per_mm, mn);
>  =20
> -	if (range->blockable)
> +	if (mmu_notifier_range_blockable(range))
>   		down_read(&per_mm->umem_rwsem);
>   	else if (!down_read_trylock(&per_mm->umem_rwsem))
>   		return -EAGAIN;
> @@ -169,7 +169,8 @@ static int ib_umem_notifier_invalidate_range_start(st=
ruct mmu_notifier *mn,
>   	return rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
>   					     range->end,
>   					     invalidate_range_start_trampoline,
> -					     range->blockable, NULL);
> +					     mmu_notifier_range_blockable(range),
> +					     NULL);
>   }
>  =20
>   static int invalidate_range_end_trampoline(struct ib_umem_odp *item, u6=
4 start,
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 5efc5eee9544..9da8f7192f46 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -526,20 +526,20 @@ static int mn_invl_range_start(struct mmu_notifier =
*mn,
>   	struct gntdev_grant_map *map;
>   	int ret =3D 0;
>  =20
> -	if (range->blockable)
> +	if (mmu_notifier_range_blockable(range))
>   		mutex_lock(&priv->lock);
>   	else if (!mutex_trylock(&priv->lock))
>   		return -EAGAIN;
>  =20
>   	list_for_each_entry(map, &priv->maps, next) {
>   		ret =3D unmap_if_in_range(map, range->start, range->end,
> -					range->blockable);
> +					mmu_notifier_range_blockable(range));
>   		if (ret)
>   			goto out_unlock;
>   	}
>   	list_for_each_entry(map, &priv->freeable_maps, next) {
>   		ret =3D unmap_if_in_range(map, range->start, range->end,
> -					range->blockable);
> +					mmu_notifier_range_blockable(range));
>   		if (ret)
>   			goto out_unlock;
>   	}
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 3c9781037918..a03b5083d880 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -205,9 +205,9 @@ static int hmm_invalidate_range_start(struct mmu_noti=
fier *mn,
>   	update.start =3D nrange->start;
>   	update.end =3D nrange->end;
>   	update.event =3D HMM_UPDATE_INVALIDATE;
> -	update.blockable =3D nrange->blockable;
> +	update.blockable =3D mmu_notifier_range_blockable(nrange);
>  =20
> -	if (nrange->blockable)
> +	if (mmu_notifier_range_blockable(nrange))
>   		mutex_lock(&hmm->lock);
>   	else if (!mutex_trylock(&hmm->lock)) {
>   		ret =3D -EAGAIN;
> @@ -222,7 +222,7 @@ static int hmm_invalidate_range_start(struct mmu_noti=
fier *mn,
>   	}
>   	mutex_unlock(&hmm->lock);
>  =20
> -	if (nrange->blockable)
> +	if (mmu_notifier_range_blockable(nrange))
>   		down_read(&hmm->mirrors_sem);
>   	else if (!down_read_trylock(&hmm->mirrors_sem)) {
>   		ret =3D -EAGAIN;
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 9c884abc7850..abd88c466eb2 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -180,7 +180,7 @@ int __mmu_notifier_invalidate_range_start(struct mmu_=
notifier_range *range)
>   			if (_ret) {
>   				pr_info("%pS callback failed with %d in %sblockable context.\n",
>   					mn->ops->invalidate_range_start, _ret,
> -					!range->blockable ? "non-" : "");
> +					!mmu_notifier_range_blockable(range) ? "non-" : "");
>   				ret =3D _ret;
>   			}
>   		}
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 38df17b7760e..629760c0fb95 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -386,7 +386,8 @@ static int kvm_mmu_notifier_invalidate_range_start(st=
ruct mmu_notifier *mn,
>   	spin_unlock(&kvm->mmu_lock);
>  =20
>   	ret =3D kvm_arch_mmu_notifier_invalidate_range(kvm, range->start,
> -					range->end, range->blockable);
> +					range->end,
> +					mmu_notifier_range_blockable(range));
>  =20
>   	srcu_read_unlock(&kvm->srcu, idx);
>  =20
>=20

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

