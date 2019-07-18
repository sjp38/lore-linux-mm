Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A6E7C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C333E21019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:12:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C333E21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FB676B0005; Thu, 18 Jul 2019 02:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ABAB6B0007; Thu, 18 Jul 2019 02:12:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4747F8E0001; Thu, 18 Jul 2019 02:12:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECD2C6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:12:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so19322478edv.16
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:12:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZtzqC59otavtaxw96gW5yTACLZk2RItC3OAm3JpIFEQ=;
        b=rqTnL+T/PHo4segXklHM0z4Vx5LMIX7422sDsvLZ1TklvxGYZySKQqngninCmT0WIz
         ajPZpUaSSkLjKaXix7alnsVYfqbPWIqxRCeKXNdybCmDDOEzebYCgvFIo2o/O2Xn94YA
         RkntmXcQkLM4SdbobRkvx3hcNzXjLqDdhD8CDIpLty2h+DBCdrV+XJOELNe6LpQxOF4h
         ELwzH3rCIPEWC0bGzkb3QpMIcMhk1TSPcXOC7izIgxCvNm57JgVLGEB2glflJdpOWW3r
         cdSa4x6zVZUN+HIJNxt3t1KkwBn3BJlOehS1dyDnOtCG4nUgQSbTsZDBh4J+n/N1moL8
         Yl0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXdaps4lXjRVdpzCOSTBTxM+dtq8VC1wb2Yj1bK19sw3WaLhyvz
	l8fJfh5WKYlRSWOnfOrmCngiR1TJHb3HKU03E09bfa1XOcMfyEwgxS4Qb/hLl3IUnzGH8yt0aMi
	8U8xdbm0YliAElKO7Cmq/xAssHU2Aq5xutYAhJP0KjkYO1Wswl6KA5gVA+aBuaZJfvg==
X-Received: by 2002:a50:b6c7:: with SMTP id f7mr37987374ede.275.1563430357543;
        Wed, 17 Jul 2019 23:12:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyY6sutabsJAOElW50waPrJYxJMRgZhAS70KPp8YSp+InJ0iP6U1KfVSXeWJWJZU8o5uNGP
X-Received: by 2002:a50:b6c7:: with SMTP id f7mr37987338ede.275.1563430356881;
        Wed, 17 Jul 2019 23:12:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563430356; cv=none;
        d=google.com; s=arc-20160816;
        b=xVYot9P4jfh9ikWlt7xJVdVWwwD04eAMcEUoZlazR0eTjth3/IrCpeR0pZ0eYZoguq
         EcHPMy0oR4DF7q585EuAd7yrYIEjtqlYHHsbPYSH/MbLRdPmHbOaKYm+MooWgv6Jszdx
         AfGHtjgMx7xNhO9J+puAhmHxDlESNnXHtJneSFmmAqrWEzZcTH2twm+pEatSyP7kOr56
         04TnAkhIgJwRFkvp0Yo3eX8UrCOE0XGwsr31IDQMmJkL06g44bJeoFa0MIzbg3k/et6K
         nzp+kIqp4rsEWZlNynjH/vNhMGwaRRBPXQ3M1iinsoxLzcUYfmxAx+e6y200iudcUb2D
         AU+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=ZtzqC59otavtaxw96gW5yTACLZk2RItC3OAm3JpIFEQ=;
        b=MV0HeUsp5Mt8CXRIzzukzZm3xUNigQVsxfN+HLMcleesKtUFE0zHMiJyKo6QSztJq4
         +oM8zNkx+vo9mhth8W6/wzANwV5RqeT6QH/qJ8iz7qZZ0wOB0RWsF5w3qOi/FU014nko
         WFEenb+/oWzrcOa9hxgMNX4DJMCyTfsfnNuhE0MbPPAPeGj3AJaYgAD2ffiTdu1WIDhC
         RkwE3UK8S1JD6IeU7h67pA2mbiwJwgSxcmNmgbeAp3w9FjDtDyviCBtWjIloD4vCcE9+
         vWjc/ZHqEsyR7echW/ysL84xMzSjwh+3CQPGnE2cgK1BUSmYQiedswMbC+jE/rQXeq4G
         aGPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m26si222750eda.249.2019.07.17.23.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 23:12:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DC940AFEC;
	Thu, 18 Jul 2019 06:12:35 +0000 (UTC)
Message-ID: <1563430353.3077.1.camel@suse.de>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in
 ZONE_MOVABLE
From: Oscar Salvador <osalvador@suse.de>
To: Leonardo Bras <leonardo@linux.ibm.com>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki"
 <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike
 Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>, Pavel
 Tatashin <pasha.tatashin@oracle.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Pasha Tatashin
 <Pavel.Tatashin@microsoft.com>, Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>
Date: Thu, 18 Jul 2019 08:12:33 +0200
In-Reply-To: <20190718024133.3873-1-leonardo@linux.ibm.com>
References: <20190718024133.3873-1-leonardo@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-17 at 23:41 -0300, Leonardo Bras wrote:
> Adds an option on kernel config to make hot-added memory online in
> ZONE_MOVABLE by default.
> 
> This would be great in systems with MEMORY_HOTPLUG_DEFAULT_ONLINE=y
> by
> allowing to choose which zone it will be auto-onlined

We do already have "movable_node" boot option, which exactly has that
effect.
Any hotplugged range will be placed in ZONE_MOVABLE.

Why do we need yet another option to achieve the same? Was not that
enough for your case?

> 
> Signed-off-by: Leonardo Bras <leonardo@linux.ibm.com>
> ---
>  drivers/base/memory.c |  3 +++
>  mm/Kconfig            | 14 ++++++++++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f180427e48f4..378b585785c1 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -670,6 +670,9 @@ static int init_memory_block(struct memory_block
> **memory,
>  	mem->state = state;
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
> +#ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
> +	mem->online_type = MMOP_ONLINE_MOVABLE;
> +#endif
>  
>  	ret = register_memory(mem);
>  
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..74e793720f43 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -180,6 +180,20 @@ config MEMORY_HOTREMOVE
>  	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>  	depends on MIGRATION
>  
> +config MEMORY_HOTPLUG_MOVABLE
> +	bool "Enhance the likelihood of hot-remove"
> +	depends on MEMORY_HOTREMOVE
> +	help
> +	  This option sets the hot-added memory zone to MOVABLE
> which
> +	  drastically reduces the chance of a hot-remove to fail due
> to
> +	  unmovable memory segments. Kernel memory can't be
> allocated in
> +	  this zone.
> +
> +	  Say Y here if you want to have better chance to hot-remove 
> memory
> +	  that have been previously hot-added.
> +	  Say N here if you want to make all hot-added memory
> available to
> +	  kernel space.
> +
>  # Heavily threaded applications may benefit from splitting the mm-
> wide
>  # page_table_lock, so that faults on different parts of the user
> address
>  # space can be handled with less contention: split it at this
> NR_CPUS.
-- 
Oscar Salvador
SUSE L3

