Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94DFDC31E40
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 08:28:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4768F2084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 08:28:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="boxOmV2A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4768F2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD5A26B000A; Thu, 15 Aug 2019 04:28:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B87166B000C; Thu, 15 Aug 2019 04:28:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A75326B000D; Thu, 15 Aug 2019 04:28:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0077.hostedemail.com [216.40.44.77])
	by kanga.kvack.org (Postfix) with ESMTP id 877B06B000A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 04:28:31 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2C65C181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:28:31 +0000 (UTC)
X-FDA: 75823985622.16.base32_67629a1393d27
X-HE-Tag: base32_67629a1393d27
X-Filterd-Recvd-Size: 13795
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com [209.85.221.66])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:28:30 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id g17so1518066wrr.5
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 01:28:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=reply-to:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=2n57inVfSie2OKAeFsC4Tdlnlo7oR3PchxqlwbFyHws=;
        b=boxOmV2AXJMNv7ExG5zcaNwxY8gLHePrB+8HL/cmSKDM3jIErtI774h9HjnDRzm8Tx
         Wq9PWfYT0Sh5Po0fBclwEP4xbBfvwCFnk9C/SG/rshZcYo9N1euWPNu2UGL7EWCo3+MP
         O2rnBrRJ7qLQnlMsBq3iYl5Gx16rioJyY8NHWzFHk6PJR3Mao4BkmwMKCPfIMe58HB2/
         YomndBe6Ptr1r/DdLANhMMeLvEc+gN/2G78qBq1yiqedrcEA+VyitQg3m/MavBlIoO5/
         kdqkjsndmpbzsFCRWVN8vW/8XkaogWEHGqhOo5gXtwC44YcIRAqSJ/YLJRfC4UpsUc3l
         MU5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:reply-to:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=2n57inVfSie2OKAeFsC4Tdlnlo7oR3PchxqlwbFyHws=;
        b=fDZfblDqeQpdCthbBATUJUN1ZtPuiYp6Jo7meXCMpB6IHDM2yuqHOASZ2jajoUlbyA
         FjGP5v3rQj+7ubSBy3kE+TvT+C9kYuVjmmCdZwUeHLKYoV0TISnPryMkWEQK2HTUlmTF
         Dj+S2El7ifuqtcOAOEkzNXWktDckdlmPUlZKb1mQb8PVB+OsvyJwpeo3pbvEbzcfSryh
         JpGT3E4QWLNJr9WS2jkZLjZLFK9xznA4KXR0/i2snoJkIW9HH3IujMit51Xmf+Hrku4i
         M84JMOZFO7uBl8eeCMRXJC1gm7Oq3q5bmJHqyILiZ2nowByBO2OTR9hJAdWnlgmx+jdv
         VS0w==
X-Gm-Message-State: APjAAAV0IX+WuemGayEFEoWVrvC+ZUzOD/IoJkEktiZwRcnEGguC5mXG
	6CN4bwWKT+GNCOaK1W+AjDo=
X-Google-Smtp-Source: APXvYqwfqKb8EbCeeUml+x+2Tj1Kf6iL08f84CLc1WiMnwcV+bykZNDjSVZQ4BJrVYueAZkugq/uJg==
X-Received: by 2002:a05:6000:cb:: with SMTP id q11mr1965676wrx.50.1565857709125;
        Thu, 15 Aug 2019 01:28:29 -0700 (PDT)
Received: from ?IPv6:2a02:908:1252:fb60:be8a:bd56:1f94:86e7? ([2a02:908:1252:fb60:be8a:bd56:1f94:86e7])
        by smtp.gmail.com with ESMTPSA id w5sm711796wmm.43.2019.08.15.01.28.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 01:28:28 -0700 (PDT)
Reply-To: christian.koenig@amd.com
Subject: Re: [PATCH v3 hmm 08/11] drm/radeon: use mmu_notifier_get/put for
 struct radeon_mn
To: Jason Gunthorpe <jgg@ziepe.ca>, linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 "David (ChunMing) Zhou" <David1.Zhou@amd.com>,
 Ralph Campbell <rcampbell@nvidia.com>, Dimitri Sivanich <sivanich@sgi.com>,
 Gavin Shan <shangw@linux.vnet.ibm.com>, Andrea Righi
 <andrea@betterlinux.com>, linux-rdma@vger.kernel.org,
 John Hubbard <jhubbard@nvidia.com>, "Kuehling, Felix"
 <Felix.Kuehling@amd.com>, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, =?UTF-8?Q?Christian_K=c3=b6nig?=
 <christian.koenig@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, iommu@lists.linux-foundation.org,
 amd-gfx@lists.freedesktop.org, Jason Gunthorpe <jgg@mellanox.com>,
 Alex Deucher <alexander.deucher@amd.com>, intel-gfx@lists.freedesktop.org,
 Christoph Hellwig <hch@lst.de>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-9-jgg@ziepe.ca>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <2baff2e5-b923-c39b-98e5-b3e7f77bd6d3@gmail.com>
Date: Thu, 15 Aug 2019 10:28:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806231548.25242-9-jgg@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am 07.08.19 um 01:15 schrieb Jason Gunthorpe:
> From: Jason Gunthorpe <jgg@mellanox.com>
>
> radeon is using a device global hash table to track what mmu_notifiers
> have been registered on struct mm. This is better served with the new
> get/put scheme instead.
>
> radeon has a bug where it was not blocking notifier release() until all
> the BO's had been invalidated. This could result in a use after free of
> pages the BOs. This is tied into a second bug where radeon left the
> notifiers running endlessly even once the interval tree became
> empty. This could result in a use after free with module unload.
>
> Both are fixed by changing the lifetime model, the BOs exist in the
> interval tree with their natural lifetimes independent of the mm_struct
> lifetime using the get/put scheme. The release runs synchronously and j=
ust
> does invalidate_start across the entire interval tree to create the
> required DMA fence.
>
> Additions to the interval tree after release are already impossible as
> only current->mm is used during the add.
>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Acked-by: Christian K=C3=B6nig <christian.koenig@amd.com>

But I'm wondering if we shouldn't completely drop radeon userptr support.

It's just to buggy,
Christian.

> ---
>   drivers/gpu/drm/radeon/radeon.h        |   3 -
>   drivers/gpu/drm/radeon/radeon_device.c |   2 -
>   drivers/gpu/drm/radeon/radeon_drv.c    |   2 +
>   drivers/gpu/drm/radeon/radeon_mn.c     | 157 ++++++------------------=
-
>   4 files changed, 38 insertions(+), 126 deletions(-)
>
> AMD team: I wonder if kfd has similar lifetime issues?
>
> diff --git a/drivers/gpu/drm/radeon/radeon.h b/drivers/gpu/drm/radeon/r=
adeon.h
> index 32808e50be12f8..918164f90b114a 100644
> --- a/drivers/gpu/drm/radeon/radeon.h
> +++ b/drivers/gpu/drm/radeon/radeon.h
> @@ -2451,9 +2451,6 @@ struct radeon_device {
>   	/* tracking pinned memory */
>   	u64 vram_pin_size;
>   	u64 gart_pin_size;
> -
> -	struct mutex	mn_lock;
> -	DECLARE_HASHTABLE(mn_hash, 7);
>   };
>  =20
>   bool radeon_is_px(struct drm_device *dev);
> diff --git a/drivers/gpu/drm/radeon/radeon_device.c b/drivers/gpu/drm/r=
adeon/radeon_device.c
> index dceb554e567446..788b1d8a80e660 100644
> --- a/drivers/gpu/drm/radeon/radeon_device.c
> +++ b/drivers/gpu/drm/radeon/radeon_device.c
> @@ -1325,8 +1325,6 @@ int radeon_device_init(struct radeon_device *rdev=
,
>   	init_rwsem(&rdev->pm.mclk_lock);
>   	init_rwsem(&rdev->exclusive_lock);
>   	init_waitqueue_head(&rdev->irq.vblank_queue);
> -	mutex_init(&rdev->mn_lock);
> -	hash_init(rdev->mn_hash);
>   	r =3D radeon_gem_init(rdev);
>   	if (r)
>   		return r;
> diff --git a/drivers/gpu/drm/radeon/radeon_drv.c b/drivers/gpu/drm/rade=
on/radeon_drv.c
> index a6cbe11f79c611..b6535ac91fdb74 100644
> --- a/drivers/gpu/drm/radeon/radeon_drv.c
> +++ b/drivers/gpu/drm/radeon/radeon_drv.c
> @@ -35,6 +35,7 @@
>   #include <linux/module.h>
>   #include <linux/pm_runtime.h>
>   #include <linux/vga_switcheroo.h>
> +#include <linux/mmu_notifier.h>
>  =20
>   #include <drm/drm_crtc_helper.h>
>   #include <drm/drm_drv.h>
> @@ -624,6 +625,7 @@ static void __exit radeon_exit(void)
>   {
>   	pci_unregister_driver(pdriver);
>   	radeon_unregister_atpx_handler();
> +	mmu_notifier_synchronize();
>   }
>  =20
>   module_init(radeon_init);
> diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeo=
n/radeon_mn.c
> index 8c3871ed23a9f0..fc8254273a800b 100644
> --- a/drivers/gpu/drm/radeon/radeon_mn.c
> +++ b/drivers/gpu/drm/radeon/radeon_mn.c
> @@ -37,17 +37,8 @@
>   #include "radeon.h"
>  =20
>   struct radeon_mn {
> -	/* constant after initialisation */
> -	struct radeon_device	*rdev;
> -	struct mm_struct	*mm;
>   	struct mmu_notifier	mn;
>  =20
> -	/* only used on destruction */
> -	struct work_struct	work;
> -
> -	/* protected by rdev->mn_lock */
> -	struct hlist_node	node;
> -
>   	/* objects protected by lock */
>   	struct mutex		lock;
>   	struct rb_root_cached	objects;
> @@ -58,55 +49,6 @@ struct radeon_mn_node {
>   	struct list_head		bos;
>   };
>  =20
> -/**
> - * radeon_mn_destroy - destroy the rmn
> - *
> - * @work: previously sheduled work item
> - *
> - * Lazy destroys the notifier from a work item
> - */
> -static void radeon_mn_destroy(struct work_struct *work)
> -{
> -	struct radeon_mn *rmn =3D container_of(work, struct radeon_mn, work);
> -	struct radeon_device *rdev =3D rmn->rdev;
> -	struct radeon_mn_node *node, *next_node;
> -	struct radeon_bo *bo, *next_bo;
> -
> -	mutex_lock(&rdev->mn_lock);
> -	mutex_lock(&rmn->lock);
> -	hash_del(&rmn->node);
> -	rbtree_postorder_for_each_entry_safe(node, next_node,
> -					     &rmn->objects.rb_root, it.rb) {
> -
> -		interval_tree_remove(&node->it, &rmn->objects);
> -		list_for_each_entry_safe(bo, next_bo, &node->bos, mn_list) {
> -			bo->mn =3D NULL;
> -			list_del_init(&bo->mn_list);
> -		}
> -		kfree(node);
> -	}
> -	mutex_unlock(&rmn->lock);
> -	mutex_unlock(&rdev->mn_lock);
> -	mmu_notifier_unregister(&rmn->mn, rmn->mm);
> -	kfree(rmn);
> -}
> -
> -/**
> - * radeon_mn_release - callback to notify about mm destruction
> - *
> - * @mn: our notifier
> - * @mn: the mm this callback is about
> - *
> - * Shedule a work item to lazy destroy our notifier.
> - */
> -static void radeon_mn_release(struct mmu_notifier *mn,
> -			      struct mm_struct *mm)
> -{
> -	struct radeon_mn *rmn =3D container_of(mn, struct radeon_mn, mn);
> -	INIT_WORK(&rmn->work, radeon_mn_destroy);
> -	schedule_work(&rmn->work);
> -}
> -
>   /**
>    * radeon_mn_invalidate_range_start - callback to notify about mm cha=
nge
>    *
> @@ -183,65 +125,44 @@ static int radeon_mn_invalidate_range_start(struc=
t mmu_notifier *mn,
>   	return ret;
>   }
>  =20
> -static const struct mmu_notifier_ops radeon_mn_ops =3D {
> -	.release =3D radeon_mn_release,
> -	.invalidate_range_start =3D radeon_mn_invalidate_range_start,
> -};
> +static void radeon_mn_release(struct mmu_notifier *mn, struct mm_struc=
t *mm)
> +{
> +	struct mmu_notifier_range range =3D {
> +		.mm =3D mm,
> +		.start =3D 0,
> +		.end =3D ULONG_MAX,
> +		.flags =3D 0,
> +		.event =3D MMU_NOTIFY_UNMAP,
> +	};
> +
> +	radeon_mn_invalidate_range_start(mn, &range);
> +}
>  =20
> -/**
> - * radeon_mn_get - create notifier context
> - *
> - * @rdev: radeon device pointer
> - *
> - * Creates a notifier context for current->mm.
> - */
> -static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
> +static struct mmu_notifier *radeon_mn_alloc_notifier(struct mm_struct =
*mm)
>   {
> -	struct mm_struct *mm =3D current->mm;
>   	struct radeon_mn *rmn;
> -	int r;
> -
> -	if (down_write_killable(&mm->mmap_sem))
> -		return ERR_PTR(-EINTR);
> -
> -	mutex_lock(&rdev->mn_lock);
> -
> -	hash_for_each_possible(rdev->mn_hash, rmn, node, (unsigned long)mm)
> -		if (rmn->mm =3D=3D mm)
> -			goto release_locks;
>  =20
>   	rmn =3D kzalloc(sizeof(*rmn), GFP_KERNEL);
> -	if (!rmn) {
> -		rmn =3D ERR_PTR(-ENOMEM);
> -		goto release_locks;
> -	}
> +	if (!rmn)
> +		return ERR_PTR(-ENOMEM);
>  =20
> -	rmn->rdev =3D rdev;
> -	rmn->mm =3D mm;
> -	rmn->mn.ops =3D &radeon_mn_ops;
>   	mutex_init(&rmn->lock);
>   	rmn->objects =3D RB_ROOT_CACHED;
> -=09
> -	r =3D __mmu_notifier_register(&rmn->mn, mm);
> -	if (r)
> -		goto free_rmn;
> -
> -	hash_add(rdev->mn_hash, &rmn->node, (unsigned long)mm);
> -
> -release_locks:
> -	mutex_unlock(&rdev->mn_lock);
> -	up_write(&mm->mmap_sem);
> -
> -	return rmn;
> -
> -free_rmn:
> -	mutex_unlock(&rdev->mn_lock);
> -	up_write(&mm->mmap_sem);
> -	kfree(rmn);
> +	return &rmn->mn;
> +}
>  =20
> -	return ERR_PTR(r);
> +static void radeon_mn_free_notifier(struct mmu_notifier *mn)
> +{
> +	kfree(container_of(mn, struct radeon_mn, mn));
>   }
>  =20
> +static const struct mmu_notifier_ops radeon_mn_ops =3D {
> +	.release =3D radeon_mn_release,
> +	.invalidate_range_start =3D radeon_mn_invalidate_range_start,
> +	.alloc_notifier =3D radeon_mn_alloc_notifier,
> +	.free_notifier =3D radeon_mn_free_notifier,
> +};
> +
>   /**
>    * radeon_mn_register - register a BO for notifier updates
>    *
> @@ -254,15 +175,16 @@ static struct radeon_mn *radeon_mn_get(struct rad=
eon_device *rdev)
>   int radeon_mn_register(struct radeon_bo *bo, unsigned long addr)
>   {
>   	unsigned long end =3D addr + radeon_bo_size(bo) - 1;
> -	struct radeon_device *rdev =3D bo->rdev;
> +	struct mmu_notifier *mn;
>   	struct radeon_mn *rmn;
>   	struct radeon_mn_node *node =3D NULL;
>   	struct list_head bos;
>   	struct interval_tree_node *it;
>  =20
> -	rmn =3D radeon_mn_get(rdev);
> -	if (IS_ERR(rmn))
> -		return PTR_ERR(rmn);
> +	mn =3D mmu_notifier_get(&radeon_mn_ops, current->mm);
> +	if (IS_ERR(mn))
> +		return PTR_ERR(mn);
> +	rmn =3D container_of(mn, struct radeon_mn, mn);
>  =20
>   	INIT_LIST_HEAD(&bos);
>  =20
> @@ -309,22 +231,13 @@ int radeon_mn_register(struct radeon_bo *bo, unsi=
gned long addr)
>    */
>   void radeon_mn_unregister(struct radeon_bo *bo)
>   {
> -	struct radeon_device *rdev =3D bo->rdev;
> -	struct radeon_mn *rmn;
> +	struct radeon_mn *rmn =3D bo->mn;
>   	struct list_head *head;
>  =20
> -	mutex_lock(&rdev->mn_lock);
> -	rmn =3D bo->mn;
> -	if (rmn =3D=3D NULL) {
> -		mutex_unlock(&rdev->mn_lock);
> -		return;
> -	}
> -
>   	mutex_lock(&rmn->lock);
>   	/* save the next list entry for later */
>   	head =3D bo->mn_list.next;
>  =20
> -	bo->mn =3D NULL;
>   	list_del(&bo->mn_list);
>  =20
>   	if (list_empty(head)) {
> @@ -335,5 +248,7 @@ void radeon_mn_unregister(struct radeon_bo *bo)
>   	}
>  =20
>   	mutex_unlock(&rmn->lock);
> -	mutex_unlock(&rdev->mn_lock);
> +
> +	mmu_notifier_put(&rmn->mn);
> +	bo->mn =3D NULL;
>   }


