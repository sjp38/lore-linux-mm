Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB056B0313
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 02:18:56 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 83so10862974pgb.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 23:18:56 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0082.outbound.protection.outlook.com. [104.47.34.82])
        by mx.google.com with ESMTPS id l9si3861335pgf.637.2017.08.29.23.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 23:18:54 -0700 (PDT)
Subject: Re: [PATCH 04/13] drm/amdgpu: update to new mmu_notifier semantic
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-5-jglisse@redhat.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <2bdbe5bd-ab1f-831b-5f0e-c2381b0cd14f@amd.com>
Date: Wed, 30 Aug 2017 08:18:37 +0200
MIME-Version: 1.0
In-Reply-To: <20170829235447.10050-5-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: amd-gfx@lists.freedesktop.org, Felix Kuehling <Felix.Kuehling@amd.com>, Alex Deucher <alexander.deucher@amd.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Am 30.08.2017 um 01:54 schrieb JA(C)rA'me Glisse:
> Call to mmu_notifier_invalidate_page() are replaced by call to
> mmu_notifier_invalidate_range() and thus call are bracketed by
> call to mmu_notifier_invalidate_range_start()/end()
>
> Remove now useless invalidate_page callback.
>
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>

Reviewed-by: Christian KA?nig <christian.koenig@amd.com>

The general approach is Acked-by: Christian KA?nig 
<christian.koenig@amd.com>.

It's something very welcome since I was one of the people (together with 
the Intel guys) which failed to recognize what this callback really does.

Regards,
Christian.

> Cc: amd-gfx@lists.freedesktop.org
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Christian KA?nig <christian.koenig@amd.com>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c | 31 -------------------------------
>   1 file changed, 31 deletions(-)
>
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> index 6558a3ed57a7..e1cde6b80027 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> @@ -147,36 +147,6 @@ static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
>   }
>   
>   /**
> - * amdgpu_mn_invalidate_page - callback to notify about mm change
> - *
> - * @mn: our notifier
> - * @mn: the mm this callback is about
> - * @address: address of invalidate page
> - *
> - * Invalidation of a single page. Blocks for all BOs mapping it
> - * and unmap them by move them into system domain again.
> - */
> -static void amdgpu_mn_invalidate_page(struct mmu_notifier *mn,
> -				      struct mm_struct *mm,
> -				      unsigned long address)
> -{
> -	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
> -	struct interval_tree_node *it;
> -
> -	mutex_lock(&rmn->lock);
> -
> -	it = interval_tree_iter_first(&rmn->objects, address, address);
> -	if (it) {
> -		struct amdgpu_mn_node *node;
> -
> -		node = container_of(it, struct amdgpu_mn_node, it);
> -		amdgpu_mn_invalidate_node(node, address, address);
> -	}
> -
> -	mutex_unlock(&rmn->lock);
> -}
> -
> -/**
>    * amdgpu_mn_invalidate_range_start - callback to notify about mm change
>    *
>    * @mn: our notifier
> @@ -215,7 +185,6 @@ static void amdgpu_mn_invalidate_range_start(struct mmu_notifier *mn,
>   
>   static const struct mmu_notifier_ops amdgpu_mn_ops = {
>   	.release = amdgpu_mn_release,
> -	.invalidate_page = amdgpu_mn_invalidate_page,
>   	.invalidate_range_start = amdgpu_mn_invalidate_range_start,
>   };
>   


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
