Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70E69C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 21:10:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39CE22080F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 21:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39CE22080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBD448E00B6; Thu, 21 Feb 2019 16:10:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C44E68E00B5; Thu, 21 Feb 2019 16:10:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE7FD8E00B6; Thu, 21 Feb 2019 16:10:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6058E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:10:45 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so40706qte.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:10:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Uk+2LgbR3oQ4TgjqRGvyIJ/4hEn7sOcfxSCQu8z1vSY=;
        b=lt1zpsJvrxbMSEoFpPJhUcuRCfpHT+xZdayNbZHu74NxR61dzYF492vTf84NpoOePv
         Y4sHIOkUX3R4tKpxq6+muhvZ7xmx9BT/rWH8v/z/VX3d6IoujugBUo7KBQvXg21A9WWP
         IFTUChCHvSMcLqQlYU70CYPqacIrF2aFbGOgKdm41hMGcMvlze4sEsDggZg+uJaRF/on
         mfp/RzB6yuYAjG4s44yXJ0r7F+Y2Plbwc4+C2gaPEEg6AwZnVkhXGDRXEEZXnuYRugdG
         wNp2dXs0UFDwTCqgHhuHwQd/RSx2sjvOxt1ZmZKFKwjpSGnQ5z26/7NI9t84c4u3Fi93
         RpjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZfx7F2iYh/QnCgqAJb4GBmsmC5N4obnioBpxwcp2/dIlUpdCR9
	HN8P8lkOIsocxZI37RAcfoBLuHWk1dOeMEZCODgHoAu58opD1FrnTMQissVPRoa28oBVJsB4VYm
	PI62UGiOhTq8WEEVObgbTzqykABoup0tH5ktswXbm1GC/UI3jzryxI4JahFCdmdMsjg==
X-Received: by 2002:a37:62c5:: with SMTP id w188mr450531qkb.294.1550783445272;
        Thu, 21 Feb 2019 13:10:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZmHIe+r/gUAh7XX5apdjmKk605hurrUkPRWU+d95x8SUavm9F8bQvkbpa51U+Hz+go2xR7
X-Received: by 2002:a37:62c5:: with SMTP id w188mr450491qkb.294.1550783444537;
        Thu, 21 Feb 2019 13:10:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550783444; cv=none;
        d=google.com; s=arc-20160816;
        b=gK9zbbYqqO20k8U1EeCJ5QC31X4fko3ivJ586T61j2+OweckK32tVlmCsom167e1v6
         8ahD3wRpCdtdzemUWnzWJ3FZ5Woh4nwtLr6Z4vSzkIa7i+EQ/kSYrNrtApRDFsOTiiC3
         FyV0bT2a86S66CvDxKWQVnNv+ex8gSCCdD5lwsDpMjpDr+3p1+XapyUaisGMOrxem/i4
         jpERN6Tfg0EHG1bI0xWQo8tI3XjAgU6O6/RW4C2OPfAiaIu7Ys6fh7ldMYpDsjC/Jf7p
         9S6WGdzkDtvW1trQV7KBxe8Rn9uHBfaG2V1b6t/vL89i0N5fxf0uDtgpccbHFpWIrI0e
         o16A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Uk+2LgbR3oQ4TgjqRGvyIJ/4hEn7sOcfxSCQu8z1vSY=;
        b=E+LUG8O+gZCZi+0nrQQ8WfXdayQfyytMYCNdTOFNSi/Qaoxv+KitAig/qQ5F8VH6YF
         7oLI6SNEWNBxwcPIA7i7S2I4CtxRe4Aa/v0OUJ12R/ljtNpGjraKya1zMj6NkXHpKkKb
         vTXZwBGe4nODXf6YjhLbrF5MWjFnEH8qm2wr2IlgseSYCogSJ9VwVgPc6xzRC+Jvt3qH
         hRdYvPdsbQpsmQPtbfwu1Onpu2fvlKzJkoGvYMsSX4ScU8En/rpZnHh/wg/qLn8wXgPh
         0mRUofXpNuPUG+4uBIIqG105qHUpgk6MfOW2E3YAhpRlyeswSGJuhPlu+InH2c/zeAoY
         YjXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y55si15154596qvh.26.2019.02.21.13.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 13:10:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9FA3681129;
	Thu, 21 Feb 2019 21:10:41 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 26A625D706;
	Thu, 21 Feb 2019 21:10:40 +0000 (UTC)
Date: Thu, 21 Feb 2019 16:10:38 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange
 two lists of pages.
Message-ID: <20190221211038.GC5201@redhat.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190215220856.29749-2-zi.yan@sent.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 21 Feb 2019 21:10:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 02:08:26PM -0800, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
> 
> In stead of using two migrate_pages(), a single exchange_pages() would
> be sufficient and without allocating new pages.

So i believe it would be better to arrange the code differently instead
of having one function that special case combination, define function for
each one ie:
    exchange_anon_to_share()
    exchange_anon_to_anon()
    exchange_share_to_share()

Then you could define function to test if a page is in correct states:
    can_exchange_anon_page() // return true if page can be exchange
    can_exchange_share_page()

In fact both of this function can be factor out as common helpers with the
existing migrate code within migrate.c This way we would have one place
only where we need to handle all the special casing, test and exceptions.

Other than that i could not spot anything obviously wrong but i did not
spent enough time to check everything. Re-architecturing the code like
i propose above would make this a lot easier to review i believe.

Cheers,
Jérôme

> 
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> ---
>  include/linux/ksm.h |   5 +
>  mm/Makefile         |   1 +
>  mm/exchange.c       | 846 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/internal.h       |   6 +
>  mm/ksm.c            |  35 ++
>  mm/migrate.c        |   4 +-
>  6 files changed, 895 insertions(+), 2 deletions(-)
>  create mode 100644 mm/exchange.c

[...]

> +	from_page_count = page_count(from_page);
> +	from_map_count = page_mapcount(from_page);
> +	to_page_count = page_count(to_page);
> +	to_map_count = page_mapcount(to_page);
> +	from_flags = from_page->flags;
> +	to_flags = to_page->flags;
> +	from_mapping = from_page->mapping;
> +	to_mapping = to_page->mapping;
> +	from_index = from_page->index;
> +	to_index = to_page->index;

Those are not use anywhere ...

