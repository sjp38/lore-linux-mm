Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2404EC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6AFB20679
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:30:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6AFB20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FB058E0006; Mon, 29 Jul 2019 19:30:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AC408E0002; Mon, 29 Jul 2019 19:30:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 474298E0006; Mon, 29 Jul 2019 19:30:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 248B78E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:30:53 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o11so48074232qtq.10
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:30:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5ZWG0QDCxJvv65+JuyyOckXL85oTlI7dOVIPd95tIFw=;
        b=BO4PQk1jCMxusk0e3iidDXDgw/64Duy58NlTLJFjA58BO/R98KrfKK7L/ks4tNdk2B
         xrztPWUM7NeE5kIju8qJcsbTtFKYtlkU15WsJAMAHbFnCCo+BeumnvxWwRrvI1yt8KWR
         WfyRI3U7VA1Y+65WVYb4nEcbLc3aHyZrr2t0BtydhF4XIis55b9cW4/HQBsL9Y9nlzML
         rNzgr92n+7rqnPoyoRP1lHMBJEonuuOizBxQYVpZ5vbnnZLKZ0w0vXuK3TGJMKUrnfNz
         cbvM9GLs3Mhy98TDslyX9DZ+v/sY4itcEKy3ip9XG1uATCPJ4NC75v3XCYX6fHViT4P1
         el0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWV+1HCdGe4lzw1tY9gQ8gSDWXcVQ4J86+bNIMYgZi+uFZmpxZP
	tKe728sTUZ4VDnRBkWhjKJB070odDulAw3R3Azk5NFq/CuJk8NMmdgMyyTW7/2vehGNLxnrBK5x
	YjuxFfq6fPJP6etx7/66cyPb3wkk2oxxi8XDqEO3Ptg2brtqk/YHY8xa8mxGmqfuaYg==
X-Received: by 2002:a05:620a:125b:: with SMTP id a27mr54300843qkl.112.1564443052852;
        Mon, 29 Jul 2019 16:30:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza2as58wG9LFbHbBY4uBMFnbZD22surnhOZzyZPET3qQcNQrrbRF3kQz4hynGy7rr0KyM0
X-Received: by 2002:a05:620a:125b:: with SMTP id a27mr54300807qkl.112.1564443052254;
        Mon, 29 Jul 2019 16:30:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564443052; cv=none;
        d=google.com; s=arc-20160816;
        b=v9GzoxQvJMRa/fd61F+owmEkp+cEAD1K5tFTiyellmp2O4mSlhpWUJmkC0pQm4Lcju
         qUQ0zcDxCPWkUkQ7T6fASDB7hzUbsaYW0KBZePyQhp3i8hWNRt89PmW9CPMZKy77rwCs
         5c5tiZtNS+/ajmF5Iypcn60XK4rjNHpBy8oxoC0woAk9KYXF0CknPr0GVBvAnMtkap8m
         hYgeFMTUUOwcXHGMdkHTtPjyMqx77DYv1QIxaFjFRb7wiZYdbVRC0ciXhit0r8j2byGj
         Jk6UH1LAq9irQuuxuNZD1vGiamRz4qwV03z9DP9kvxAnaQrLyC04X9FWyBew3Y57Eu6C
         oGfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5ZWG0QDCxJvv65+JuyyOckXL85oTlI7dOVIPd95tIFw=;
        b=XLe5Zk2WKjg0J2HzzDl7NPRbAC/+iZ7a78Vm1x5aShA3qdw8FoMz7Tx3b3pjW4N4Fa
         qCONJ0Kn65IV387MYB8pE4N051nKSRHULZyWbq6nvyGNA8iTmSdTBgg7fO+Ku6X8dkhs
         n9LHrLlm4phD55BT0joZ2BDUoiKZ8GaXl/CiUqBazgDxO443ih9Ic7YKQ/IvWwp0G/AC
         05oSycIY1dbc+2UDmxIOtIhNCLxlAzFhQ3T4iMvyDDoKHjua0xkEVidZPqG/0tT1wBja
         NtwFSzvu7Y0Gx97zSqjGImh3nA98M8+TLI7logVv/ysH9GaOTeeYIVr75yfjTrbElLjt
         0Z5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si33437550qtn.402.2019.07.29.16.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:30:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 72E2E5AFF8;
	Mon, 29 Jul 2019 23:30:51 +0000 (UTC)
Received: from redhat.com (ovpn-112-31.rdu2.redhat.com [10.10.112.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 58E1C19C58;
	Mon, 29 Jul 2019 23:30:48 +0000 (UTC)
Date: Mon, 29 Jul 2019 19:30:44 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 9/9] mm: remove the MIGRATE_PFN_WRITE flag
Message-ID: <20190729233044.GA7171@redhat.com>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-10-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190729142843.22320-10-hch@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 29 Jul 2019 23:30:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 05:28:43PM +0300, Christoph Hellwig wrote:
> The MIGRATE_PFN_WRITE is only used locally in migrate_vma_collect_pmd,
> where it can be replaced with a simple boolean local variable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

NAK that flag is useful, for instance a anonymous vma might have
some of its page read only even if the vma has write permission.

It seems that the code in nouveau is wrong (probably lost that
in various rebase/rework) as this flag should be use to decide
wether to map the device memory with write permission or not.

I am traveling right now, i will investigate what happened to
nouveau code.

Cheers,
Jérôme

> ---
>  include/linux/migrate.h | 1 -
>  mm/migrate.c            | 9 +++++----
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 8b46cfdb1a0e..ba74ef5a7702 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -165,7 +165,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  #define MIGRATE_PFN_VALID	(1UL << 0)
>  #define MIGRATE_PFN_MIGRATE	(1UL << 1)
>  #define MIGRATE_PFN_LOCKED	(1UL << 2)
> -#define MIGRATE_PFN_WRITE	(1UL << 3)
>  #define MIGRATE_PFN_SHIFT	6
>  
>  static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 74735256e260..724f92dcc31b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2212,6 +2212,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  		unsigned long mpfn, pfn;
>  		struct page *page;
>  		swp_entry_t entry;
> +		bool writable = false;
>  		pte_t pte;
>  
>  		pte = *ptep;
> @@ -2240,7 +2241,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  			mpfn = migrate_pfn(page_to_pfn(page)) |
>  					MIGRATE_PFN_MIGRATE;
>  			if (is_write_device_private_entry(entry))
> -				mpfn |= MIGRATE_PFN_WRITE;
> +				writable = true;
>  		} else {
>  			if (is_zero_pfn(pfn)) {
>  				mpfn = MIGRATE_PFN_MIGRATE;
> @@ -2250,7 +2251,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  			}
>  			page = vm_normal_page(migrate->vma, addr, pte);
>  			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
> -			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
> +			if (pte_write(pte))
> +				writable = true;
>  		}
>  
>  		/* FIXME support THP */
> @@ -2284,8 +2286,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  			ptep_get_and_clear(mm, addr, ptep);
>  
>  			/* Setup special migration page table entry */
> -			entry = make_migration_entry(page, mpfn &
> -						     MIGRATE_PFN_WRITE);
> +			entry = make_migration_entry(page, writable);
>  			swp_pte = swp_entry_to_pte(entry);
>  			if (pte_soft_dirty(pte))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> -- 
> 2.20.1
> 

