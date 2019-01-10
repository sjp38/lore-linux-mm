Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0F28E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 00:52:36 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so9060404qtj.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 21:52:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h35si998580qvh.191.2019.01.09.21.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 21:52:35 -0800 (PST)
Date: Thu, 10 Jan 2019 00:52:32 -0500 (EST)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1861725446.61345592.1547099552878.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190110005117.18282-1-sean.j.christopherson@intel.com>
References: <20190110005117.18282-1-sean.j.christopherson@intel.com>
Subject: Re: [PATCH] mm/mmu_notifier: mm/rmap.c: Fix a mmu_notifier range
 bug in try_to_unmap_one
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, leozinho29 eu <leozinho29_eu@hotmail.com>, Mike Galbraith <efault@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Christian =?utf-8?Q?K=C3=B6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


> The conversion to use a structure for mmu_notifier_invalidate_range_*()
> unintentionally changed the usage in try_to_unmap_one() to init the
> 'struct mmu_notifier_range' with vma->vm_start instead of @address,
> i.e. it invalidates the wrong address range.  Revert to the correct
> address range.
>=20
> Manifests as KVM use-after-free WARNINGs and subsequent "BUG: Bad page
> state in process X" errors when reclaiming from a KVM guest due to KVM
> removing the wrong pages from its own mappings.
>=20
> Reported-by: leozinho29_eu@hotmail.com
> Reported-by: Mike Galbraith <efault@gmx.de>
> Reported-by: Adam Borowski <kilobyte@angband.pl>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Felix Kuehling <felix.kuehling@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for
> invalidate_range_start/end calls v2")
> Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
> ---
>=20
> FWIW, I looked through all other calls to mmu_notifier_range_init() in
> the patch and didn't spot any other unintentional functional changes.
>=20
>  mm/rmap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 68a1a5b869a5..0454ecc29537 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1371,8 +1371,8 @@ static bool try_to_unmap_one(struct page *page, str=
uct
> vm_area_struct *vma,
>  =09 * Note that the page can not be free in this function as call of
>  =09 * try_to_unmap() must hold a reference on the page.
>  =09 */
> -=09mmu_notifier_range_init(&range, vma->vm_mm, vma->vm_start,
> -=09=09=09=09min(vma->vm_end, vma->vm_start +
> +=09mmu_notifier_range_init(&range, vma->vm_mm, address,
> +=09=09=09=09min(vma->vm_end, address +
>  =09=09=09=09    (PAGE_SIZE << compound_order(page))));
>  =09if (PageHuge(page)) {
>  =09=09/*
> --

I was suspecting this patch for some other issue. But could not spot this a=
fter=20
in depth analyzing the changed "invalidate_range_start/end calls".=20

Its indeed a good catch.=20

Reviewed-by: Pankaj gupta <pagupta@redhat.com>

> 2.19.2
>=20
>=20
