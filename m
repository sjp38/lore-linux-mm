Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCB1BC43612
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 17:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85DC620656
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 17:34:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85DC620656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EA6B8E0008; Tue, 15 Jan 2019 12:34:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19A458E0002; Tue, 15 Jan 2019 12:34:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B1248E0008; Tue, 15 Jan 2019 12:34:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC1108E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:34:39 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so2019298pls.21
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:34:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0c7evrTAwq9ca1jWD7AsAP7FXRUT/laZLINdYKwSZyk=;
        b=K4yT4si5550WZXrl9BUt+absfZ+454qX1PLzJQQlnCgXhuMjgrpnz9h96NaF8Wvdu3
         Zexrdu6IxfSWvNPsCEtNzaVtTmW8d8Lv+ALHVB1WHSyq+9EUFU6hpYDCvgiW9ZAi2bgm
         K6kgGbZdpKPuHb+v+RAVDIlD4v33qBEQdUwoTLHxOxSv+7qz4fg/W1tkqTzOBf8nB8ao
         6j5oWJS877iplMrnFo9Rxvk/WvrKW1D4asd2QGrfClYy9d0Wua0HJ5hnkX2eHxpV4qWJ
         /5WMyJWlm8nYtXUQy8lLyiyMYRyQEHkSmoIwwUtPTWqYSBANoBtu0Wp0RGz49tCJaxPz
         g1yA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdvw4Oc1DBhs6WB1F6brvvqtVJ8I5zhPb5wyGQ7/86YdNubSLq6
	De2CJcf/dkryjx2hovG/Z9f1gg0OnDpbBsonEWaJAGjIoHp0wr3CokTqy7YsnTln3IPNZgN0bgd
	Gveif6HSdgkq39EcutCllHKcPmg1boGnyX83EMEoen0fTvXqiZiqLAWeUSuYUWYftXg==
X-Received: by 2002:a63:6ac5:: with SMTP id f188mr4808172pgc.165.1547573679352;
        Tue, 15 Jan 2019 09:34:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6tRtMtk9laBISeZv2QQ7DrpYncremjdLXWElbn+h8VPhMnGDYWVrtVMgA4yCz2nRmCXYRB
X-Received: by 2002:a63:6ac5:: with SMTP id f188mr4808106pgc.165.1547573678433;
        Tue, 15 Jan 2019 09:34:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547573678; cv=none;
        d=google.com; s=arc-20160816;
        b=QC504gJbCDV56l4TSfaKUD1vCtC/L/cwNJ54Rd73FpCgoyGSTV1Cwd15mXhEIKIwG1
         bD52+voo/5dmEh96tDuhsBFMNPZWnilyIXcDV70oymq0Y3WVgeHxerD5y4WKuOPdC9d8
         GLdjFGJqYbUItftSxj1PLun+JNBVMVFrkXWe8uCdF2dCc/NZtAgmEua3nQ/9uD1y8j63
         qAwzTLl1VcaNu3P78H2GZ5dSf2+p/K6n2oCCMKxMauDLXBjE5tGQpi6ZxZFrZT7r2B18
         hV4n08KIz5kQf2ry8KVE5tLoB/JH8hVWFnSttaawbfFl8Het1VRklCjJeur36U99Nuys
         ooDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=0c7evrTAwq9ca1jWD7AsAP7FXRUT/laZLINdYKwSZyk=;
        b=SxxxkWVUZJyyotrO6HoZbtx6oq/e8qdH0YDQrqrbjfo/wufjKHWNWDxSQfLYJB8YVC
         GZwNCO7Fnr8AtFePYwQntIiy24hPv4Jef6wPICeXRtUhssVYZuEKAZB3FZRJRJ3O8m7e
         3sxpNeop1MPs9O5rrBjLeZm/KTW/AXkp5x+yO3ZjcUV0Pgre8gZcmLFKZFi628TiRm+2
         W4UGAHhn41Y8P42BxpT3lvhp9HClpaFWGXkIFUmMMRxZOuib/ju7hJD/AtKASW7JY9Db
         E7UZiHZ5IlPVc0wUhgeVXxiaMcKtfWJYZKAIbBthW1GC6p8qcPZITqxrYHfzCpOp0zEL
         DtNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u184si3652568pgd.262.2019.01.15.09.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 09:34:38 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Jan 2019 09:34:37 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,481,1539673200"; 
   d="scan'208";a="127980887"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 15 Jan 2019 09:34:37 -0800
Message-ID: <9bc20a9f2f5d6a99afa61ad68d827090553c09fe.camel@linux.intel.com>
Subject: Re: [PATCH v10] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, 
 akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
 osalvador@suse.de,  linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com
Date: Tue, 15 Jan 2019 09:34:37 -0800
In-Reply-To: <1547571068-18902-1-git-send-email-arunks@codeaurora.org>
References: <1547571068-18902-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115173437.Z5mckxC2mDZtjfH1M8V5OlDc7XzezrU_uGPFHw9Ab4A@z>

On Tue, 2019-01-15 at 22:21 +0530, Arun KS wrote:
> When freeing pages are done with higher order, time spent on coalescing
> pages by buddy allocator can be reduced.  With section size of 256MB, hot
> add latency of a single section shows improvement from 50-60 ms to less
> than 1 ms, hence improving the hot add latency by 60 times.  Modify
> external providers of online callback to align with the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
> Changes since v9:
> - Fix condition check in hv_ballon driver.
> 
> Changes since v8:
> - Remove return type change for online_page_callback.
> - Use consistent names for external online_page providers.
> - Fix onlined_pages accounting.
> 
> Changes since v7:
> - Rebased to 5.0-rc1.
> - Fixed onlined_pages accounting.
> - Added comment for return value of online_page_callback.
> - Renamed xen_bring_pgs_online to xen_online_pages.
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
> v9: https://lore.kernel.org/patchwork/patch/1030806/
> v8: https://lore.kernel.org/patchwork/patch/1030332/
> v7: https://lore.kernel.org/patchwork/patch/1028908/
> v6: https://lore.kernel.org/patchwork/patch/1007253/
> v5: https://lore.kernel.org/patchwork/patch/995739/
> v4: https://lore.kernel.org/patchwork/patch/995111/
> v3: https://lore.kernel.org/patchwork/patch/992348/
> v2: https://lore.kernel.org/patchwork/patch/991363/
> v1: https://lore.kernel.org/patchwork/patch/989445/
> RFC: https://lore.kernel.org/patchwork/patch/984754/
> ---
>  drivers/hv/hv_balloon.c        |  4 ++--
>  drivers/xen/balloon.c          | 15 ++++++++++-----
>  include/linux/memory_hotplug.h |  2 +-
>  mm/internal.h                  |  1 +
>  mm/memory_hotplug.c            | 37 +++++++++++++++++++++++++------------
>  mm/page_alloc.c                |  8 ++++----
>  6 files changed, 45 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 5301fef..2ced9a7 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  	}
>  }
>  
> -static void hv_online_page(struct page *pg)
> +static void hv_online_page(struct page *pg, unsigned int order)
>  {
>  	struct hv_hotadd_state *has;
>  	unsigned long flags;
> @@ -780,10 +780,11 @@ static void hv_online_page(struct page *pg)
>  	spin_lock_irqsave(&dm_device.ha_lock, flags);
>  	list_for_each_entry(has, &dm_device.ha_region_list, list) {
>  		/* The page belongs to a different HAS. */
> -		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
> +		if ((pfn < has->start_pfn) ||
> +				(pfn + (1UL << order) >= has->end_pfn))

This check should be ">" has->end_pfn, not ">=".

>  			continue;
>  
> -		hv_page_online_one(has, pg);
> +		hv_bring_pgs_online(has, pfn, (1UL << order));

Also the parenthesis around "1UL << order" are unnecessary.
>  		break;
>  	}
>  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);

The rest of this looks fine to me.

