Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A77BC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:43:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15CCF2070B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:43:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15CCF2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A36EE8E0005; Mon, 29 Jul 2019 19:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E7C58E0002; Mon, 29 Jul 2019 19:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AFA88E0005; Mon, 29 Jul 2019 19:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6650F8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:43:21 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x1so56829309qts.9
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=itEspQP2DFCiFXb/y7yCiyva/NoBGHdfqbU1X37w1qk=;
        b=UsiyK0aFUZQCtFZNhC/jM6CCEhsTbYidVTXejCLm0f2N/BzqnJda77pQxAQNJq58PB
         ABWLnfF09gbfSPa2GlaOGGfEp5jhINb7UXuTsTpziFqCVAYZW+0cvXkLbUtL0F3JDWTE
         fzMak1YVM3ylNrRQHT4ki6uS8GuOezt6BoewUVSjR5CHgcg7f4dap3DI6lJm6PflCQ/s
         Hr6D29W9m7CanXkUCGb1uxBnEEQNXwEp+mS6EFJsA0zbResk5tSfYKEJ+rp/bViKbM56
         78RhP1wLhe2yt/PlmTiBOVuV3fHIfGAkYPHBjBWtoYnimlZIQYtNSPoGQ44FSImx5qlg
         6a5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUierSK6m/PJB3DDnFVHQKor3RjgVINjf0WZEgKi1nyDEGEfcCk
	5zY2/mLjJxEBhg42Ma0jinxQX7rYl5x34W/baDKfMcmJM6NFlRCknh9HCHloIjqgIOYCaCUpA6J
	EGfFVF7RvmiKhnvsL17oZVN4pYcIvROn7+4yI0KFVliBdEK4pnGjKcjYGf8D2LCfcTA==
X-Received: by 2002:a0c:93a3:: with SMTP id f32mr80797970qvf.14.1564443801168;
        Mon, 29 Jul 2019 16:43:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy58nW1kfJ7h1bmo2IAgRoisYFbW1nTm2kQtVgeOuyCYBcsdIYg3KwL/aYvucnHc8FFhJD2
X-Received: by 2002:a0c:93a3:: with SMTP id f32mr80797937qvf.14.1564443800455;
        Mon, 29 Jul 2019 16:43:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564443800; cv=none;
        d=google.com; s=arc-20160816;
        b=PZq4QkSTu6l4czxNp5vxqucXDJ4SgpOrw2PnB+DoniOu8Px/wRcuVZCmZacA1RHThl
         QDnLTW8sFmYDwQ+x2aFFJtfAfuuvdlTCCS75uktQAhS6AWjXQRdyOkJD4wxaI2wcdnW8
         jZoKuMvVFFi2cdN4QZxPV2Gq9R4AaVIx/ao18FY3WWOx9gZWbgtmvPW9J03L7obeJNzy
         /8oUxX8l5dU1iAM4yB0lEX7g7alcbx+mUrUTAF8mvF3C7w+lMn+lUgsT7zmD+zKD7RBM
         Bn/ufQYUPIXeeGpvqsnadu/0Q1lqk1yzmxyHpnFgx9fema/BL65wKrbX87rQwd/3YMQG
         ucAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=itEspQP2DFCiFXb/y7yCiyva/NoBGHdfqbU1X37w1qk=;
        b=iNv5GK/8fmMn6o/tr3PPG03ZsF/akyeMBM9LQxzzq3EAAAnZY/3iJ1gc5KTQij1tcG
         gim0QJy+u4zrJsob8MgLREanv/CU+yFq+c4Nj80OuLMtNLXqVdN3dgQ5cY+8z9O9YhYo
         l8z8GH+v7eDlBgEZqeCiZVIT9MWcIvdXwbpZyD6/TFlrHplTlcOCLEN7QYbqhTm9B7LR
         +W4FkauzU8NPKDg7bl3jYFwLOXutQ8IkYvG6aNm3wgmS0YZgiOBNXYkkYpedvxKUtwsj
         6BtcPiU9yyUsRVqjDBqRkelhbjwwuV46J17ELXcfQe+ChNzULftaEA827HvJvPPAjNQA
         J9Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si34771587qkd.373.2019.07.29.16.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 953C7BDF9;
	Mon, 29 Jul 2019 23:43:19 +0000 (UTC)
Received: from redhat.com (ovpn-112-31.rdu2.redhat.com [10.10.112.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5F0455D6A0;
	Mon, 29 Jul 2019 23:43:16 +0000 (UTC)
Date: Mon, 29 Jul 2019 19:43:12 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/9] mm: turn migrate_vma upside down
Message-ID: <20190729234312.GB7171@redhat.com>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729142843.22320-2-hch@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 29 Jul 2019 23:43:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 05:28:35PM +0300, Christoph Hellwig wrote:
> There isn't any good reason to pass callbacks to migrate_vma.  Instead
> we can just export the three steps done by this function to drivers and
> let them sequence the operation without callbacks.  This removes a lot
> of boilerplate code as-is, and will allow the drivers to drastically
> improve code flow and error handling further on.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>


I haven't finished review, especialy the nouveau code, i will look
into this once i get back. In the meantime below are few corrections.

> ---
>  Documentation/vm/hmm.rst               |  55 +-----
>  drivers/gpu/drm/nouveau/nouveau_dmem.c | 122 +++++++------
>  include/linux/migrate.h                | 118 ++----------
>  mm/migrate.c                           | 242 +++++++++++--------------
>  4 files changed, 193 insertions(+), 344 deletions(-)
> 

[...]

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 8992741f10aa..dc4e60a496f2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2118,16 +2118,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  #endif /* CONFIG_NUMA */
>  
>  #if defined(CONFIG_MIGRATE_VMA_HELPER)
> -struct migrate_vma {
> -	struct vm_area_struct	*vma;
> -	unsigned long		*dst;
> -	unsigned long		*src;
> -	unsigned long		cpages;
> -	unsigned long		npages;
> -	unsigned long		start;
> -	unsigned long		end;
> -};
> -
>  static int migrate_vma_collect_hole(unsigned long start,
>  				    unsigned long end,
>  				    struct mm_walk *walk)
> @@ -2578,6 +2568,108 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
>  	}
>  }
>  
> +/**
> + * migrate_vma_setup() - prepare to migrate a range of memory
> + * @args: contains the vma, start, and and pfns arrays for the migration
> + *
> + * Returns: negative errno on failures, 0 when 0 or more pages were migrated
> + * without an error.
> + *
> + * Prepare to migrate a range of memory virtual address range by collecting all
> + * the pages backing each virtual address in the range, saving them inside the
> + * src array.  Then lock those pages and unmap them. Once the pages are locked
> + * and unmapped, check whether each page is pinned or not.  Pages that aren't
> + * pinned have the MIGRATE_PFN_MIGRATE flag set (by this function) in the
> + * corresponding src array entry.  Then restores any pages that are pinned, by
> + * remapping and unlocking those pages.
> + *
> + * The caller should then allocate destination memory and copy source memory to
> + * it for all those entries (ie with MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE
> + * flag set).  Once these are allocated and copied, the caller must update each
> + * corresponding entry in the dst array with the pfn value of the destination
> + * page and with the MIGRATE_PFN_VALID and MIGRATE_PFN_LOCKED flags set
> + * (destination pages must have their struct pages locked, via lock_page()).
> + *
> + * Note that the caller does not have to migrate all the pages that are marked
> + * with MIGRATE_PFN_MIGRATE flag in src array unless this is a migration from
> + * device memory to system memory.  If the caller cannot migrate a device page
> + * back to system memory, then it must return VM_FAULT_SIGBUS, which will
> + * might have severe consequences for the userspace process, so it should best

      ^s/might//                                                      ^s/should best/must/

> + * be avoided if possible.
                 ^s/if possible//

Maybe adding something about failing only on unrecoverable device error. The
only reason we allow failure for migration here is because GPU devices can
go into bad state (GPU lockup) and when that happens the GPU memory might be
corrupted (power to GPU memory might be cut by GPU driver to recover the
GPU).

So failing migration back to main memory is only a last resort event.


> + *
> + * For empty entries inside CPU page table (pte_none() or pmd_none() is true) we
> + * do set MIGRATE_PFN_MIGRATE flag inside the corresponding source array thus
> + * allowing the caller to allocate device memory for those unback virtual
> + * address.  For this the caller simply havs to allocate device memory and
                                           ^ haves

