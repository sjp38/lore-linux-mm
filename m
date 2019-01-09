Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 496FAC43612
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:17:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03E69206BB
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:17:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03E69206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD3DD8E009F; Wed,  9 Jan 2019 11:17:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A81F58E0038; Wed,  9 Jan 2019 11:17:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9993C8E009F; Wed,  9 Jan 2019 11:17:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56AF18E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:17:13 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id i124so4440125pgc.2
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:17:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=H3eJDd1yJeVfDVTg6pjbdfuW01Mh++zUqKlTTppHX0g=;
        b=nV/cdS/JJyv+ahZAskIa60koX3OlehpFGZZFke+xtTHLC1DK/vyKge9HNb08g1A6ot
         V30k7FonCVJLmct8XgADWaARvA3ot4hfG+lhHt39wvK5xLRYElh5Z5vT3jMgX1yZLGYW
         WZun4/B9giwWycQw0l9zpdyFuYTfSvCeA/Rv2RUt8u395tzW6fCnj/GWb2dLa9rRzF/o
         jc3Hr7igGA5Wu1Kt881HRIs5zf0QGwou0vIHsljb+wsU5CjmunLUXBE4OQN1d8LEeznn
         8w07z1TVAUn90iB7D3+yVoGNUcEYj1YycTD4N9+emSrD2ISS1i9QNLuG5p8c0gQEPMWs
         Xr8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdDVD93dEhX9q/mvnwXdBgZNGijagbiP8+fw+BcoNQTJ6p1IBJz
	uBs3+F73BcxQ6vXSivxaq+wj01eXEukqXtWWbuLkF22mX4waL9SW8jPw6dFd5GKF7EkU931NUeb
	8+RXjU6m6Mh9QEd86cLSlsbtlG8+JwG08QuIRCNYt00Fir/K0K23v7WoQeSs6A3APag==
X-Received: by 2002:a63:5f89:: with SMTP id t131mr6065659pgb.26.1547050632995;
        Wed, 09 Jan 2019 08:17:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5rPnFoEDIl1yX2bakt/CNshkdjiSQHQjUzNHPx+JQ9422nC5IJ+Ey3Q3r70S/68NL1Fkdf
X-Received: by 2002:a63:5f89:: with SMTP id t131mr6065612pgb.26.1547050632085;
        Wed, 09 Jan 2019 08:17:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547050632; cv=none;
        d=google.com; s=arc-20160816;
        b=PiqG27rOkCa/4ak9DS0IJviqmIjbKlagU2q+0F3TZhhqRRoNYtUFZP4Eq2mvvl9egg
         pZP31epc8b3qCxG+by29AFtA0lQFlclAD6QpknhiTypW+9T6Y0h9PwsRfgjMJwwzjv1e
         kQeB3ztIdGoICVXhFc6tUogqZepSUSuZv8pVFYzUq1NkeEKncL8Cby4lj4XMB/56/Mt9
         u53vxI67Af2+ePj+09tGLJjONz4C1zlM9k/JEzrwzIy01rzVTgOE0aNrDbkbQeFc4vdr
         mseqiSbJy95Sj0zcN6+nHKMTcJ5r/RT1NwZQzYsKo4zf1oBWuj2CmqLcG2pQs1jVLlE+
         UpYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=H3eJDd1yJeVfDVTg6pjbdfuW01Mh++zUqKlTTppHX0g=;
        b=FZqsYOMrSlxH869/83bsPottkagW3ww7pwZi9vYQ/t2h9mdMrSGldMM5fxwhroM1bR
         3gXj8w521kw2AcXnhpemV3R9tdyp/hrYFP0It5eyzBo/5NhJZnycwJAQVCFfhdXaOEyw
         5izT8Z7pqFnqJjxZ1hfafqlJTknS+X622O0wXSG0Xi4iG466cmHyBs9AENEMWEvjXFMs
         RcxCN60gM+sqPStofbpquGLuHGgzRvJSNns2QcbM0EKqvaIO4ILlH7U2g1wV8aSLNvID
         HQUxEmc7/+wnt+fEX9G7g9kBFqvbF++jOjYihFWRkyrvSS99Jdj2PHqXaIiJblkpC53c
         7sPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w67si20181058pgb.45.2019.01.09.08.17.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:17:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Jan 2019 08:17:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,458,1539673200"; 
   d="scan'208";a="105258001"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007.jf.intel.com with ESMTP; 09 Jan 2019 08:17:11 -0800
Message-ID: <54c280dbd0ff8e17a6c465778c98e2dbbbde7918.camel@linux.intel.com>
Subject: Re: [PATCH v8] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, 
 akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
 osalvador@suse.de,  linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com
Date: Wed, 09 Jan 2019 08:17:11 -0800
In-Reply-To: <1547032395-24582-1-git-send-email-arunks@codeaurora.org>
References: <1547032395-24582-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109161711.l_HZmxvIMdwsymCXUPu7uptPQuJLYXD9VWHZKVOwbzw@z>

On Wed, 2019-01-09 at 16:43 +0530, Arun KS wrote:
> When freeing pages are done with higher order, time spent on coalescing
> pages by buddy allocator can be reduced.  With section size of 256MB, hot
> add latency of a single section shows improvement from 50-60 ms to less
> than 1 ms, hence improving the hot add latency by 60 times.  Modify
> external providers of online callback to align with the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> ---
> Changes since v7:
> - Rebased to 5.0-rc1.
> - Fixed onlined_pages accounting.
> - Added comment for return value of online_page_callback.
> - Renamed xen_bring_pgs_online to xen_online_pages.

As far as the renaming you should try to be consistent. If you aren't
going to rename generic_online_page or hv_online_page I wouldn't bother
with renaming xen_online_page. I would stick with the name
xen_online_page since it is a single high order page that you are
freeing.

> 
> Changes since v6:
> - Rebased to 4.20
> - Changelog updated.
> - No improvement seen on arm64, hence removed removal of prefetch.
> 
> Changes since v5:
> - Rebased to 4.20-rc1.
> - Changelog updated.
> 
> Changes since v4:
> - As suggested by Michal Hocko,
> - Simplify logic in online_pages_block() by using get_order().
> - Seperate out removal of prefetch from __free_pages_core().
> 
> Changes since v3:
> - Renamed _free_pages_boot_core -> __free_pages_core.
> - Removed prefetch from __free_pages_core.
> - Removed xen_online_page().
> 
> Changes since v2:
> - Reuse code from __free_pages_boot_core().
> 
> Changes since v1:
> - Removed prefetch().
> 
> Changes since RFC:
> - Rebase.
> - As suggested by Michal Hocko remove pages_per_block.
> - Modifed external providers of online_page_callback.
> 
> v7: https://lore.kernel.org/patchwork/patch/1028908/
> v6: https://lore.kernel.org/patchwork/patch/1007253/
> v5: https://lore.kernel.org/patchwork/patch/995739/
> v4: https://lore.kernel.org/patchwork/patch/995111/
> v3: https://lore.kernel.org/patchwork/patch/992348/
> v2: https://lore.kernel.org/patchwork/patch/991363/
> v1: https://lore.kernel.org/patchwork/patch/989445/
> RFC: https://lore.kernel.org/patchwork/patch/984754/
> ---
>  drivers/hv/hv_balloon.c        |  6 +++--
>  drivers/xen/balloon.c          | 21 +++++++++++------
>  include/linux/memory_hotplug.h |  2 +-
>  mm/internal.h                  |  1 +
>  mm/memory_hotplug.c            | 51 +++++++++++++++++++++++++++++++-----------
>  mm/page_alloc.c                |  8 +++----
>  6 files changed, 62 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 5301fef..211f3fe 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  	}
>  }
>  
> -static void hv_online_page(struct page *pg)
> +static int hv_online_page(struct page *pg, unsigned int order)
>  {
>  	struct hv_hotadd_state *has;
>  	unsigned long flags;
> @@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
>  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
>  			continue;
>  
> -		hv_page_online_one(has, pg);
> +		hv_bring_pgs_online(has, pfn, (1UL << order));
>  		break;
>  	}
>  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
> +
> +	return 0;
>  }
>  

I would hold off on adding return values until you actually have code
that uses them. It will make things easier if somebody has to backport
this to a stable branch and avoid adding complexity until it is needed.

Also the patch description doesn't really explain that it is doing this
so it might be better to break it off into a separate patch so you can
call out exactly why you are adding a return value in the patch
description.

- Alex

