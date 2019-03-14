Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05B5DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:56:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD8422087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:56:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD8422087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AF8B8E0003; Thu, 14 Mar 2019 03:56:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65C448E0001; Thu, 14 Mar 2019 03:56:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54C0D8E0003; Thu, 14 Mar 2019 03:56:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 106848E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:56:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k32so1980783edc.23
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 00:56:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Jdbax4vhtG3OIYkaURC5WeJtLNE4Vk5DMl8pknYTtdY=;
        b=r+Xu3D7lCUNf3uI7S1CZIN/VGEDgXBnnBvqUCQxkrwLCmYRb1jmf8knMG0WnrUDeRh
         2AsE0/oQYpWMB3P9qAYIinC3rw3LMH08DY7AuvmdZK7OATz/cUuwW6nNxJtZ1ToA6Dnh
         gDb5XDpx8/U4j/2shlFTeZ+reKdWFXxH4IMFWgb/rtb92bcs8WZeBDo86Lq9j2CGhz49
         2SsZ3lNa1s9WBoijpQbVaqKbP/6exPzwcyGsPYt8Tak2TAUWxhyRsHhEXp9QMCsEQ6BT
         pMrk4orILh/11KWrLk4stnNN6u7cD/0KYKUGd0Q51lko7uC3XCRbRhA+Q4OlQGqHPuUG
         cZPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUNkm/bOKBs0rTM/l/Snpt+Wnk1hrQEQptSkoPtfAtFoRl1HNuB
	XbFGuLDGzqMg1+kW0R7j/mwBJXO2AIENcxOGwDsTn/PDVl1DxFcy3cog1TFsMd2yLWBH674yv2w
	rsvU64x8CImET7lGdesY+/p0B+gnqik80g7Vyn8FhgB36EyhZTWnxdatQ1af+49rrnw==
X-Received: by 2002:aa7:db19:: with SMTP id t25mr10278065eds.177.1552550189645;
        Thu, 14 Mar 2019 00:56:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVSUgbB3/VYNC++pyIsb+M2bO8099UCLqRa/WtHjioL0tXuKsV+657p16sUgFBxWj74S12
X-Received: by 2002:aa7:db19:: with SMTP id t25mr10278036eds.177.1552550188874;
        Thu, 14 Mar 2019 00:56:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552550188; cv=none;
        d=google.com; s=arc-20160816;
        b=ZqJtW9ZKahXnX2EfQMXrn7DjYUVsEsn1Ww4TFiBqTyhnjyE39mwQKOisc61B/IlIJi
         4JPdXX1R2rrwMiCmGOgYYhqI+0WBbe32Jiy4wKiQnRtCwXCmn59ZbnVHSusjO447TDUg
         bGkG4XUPeITRO1UFFG4SiBoVquBfd0038TFttsJqfgkZwhoP2jHLd5kar9asYtKsYAe5
         juJhhbpM/px6j8ZqwF9nWahPHldt78Dn9N6a60h6ulTiijcRYCtYcyVJbVZ24SqbCSVe
         cJxxuNajZH9YIioQTjHJYAQDQea3z1oRQ29XpqMp62XeVUQ83DFo8OzxFuAnWXmYqXid
         y7+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Jdbax4vhtG3OIYkaURC5WeJtLNE4Vk5DMl8pknYTtdY=;
        b=YwvmpfLVF2pBT8VUR8nlOFKNapM/GklGSdsCy7vOpfIAGJ55Zu+ILfHQGYLVMQPjSC
         LlYn6r6XTg7l2M2H+qtZ73f8npplX/oGXNe+hbu9Bbmm5FYT/1TVFu8MzKIjEVdRLDKw
         ufRyWqNZUP48CJqv3e3ypa3Q+20eZVoBxMs8wWq+7NY9VHR13HQRSiRuvUBebE5LA7Zl
         BBUbobeFPGqqbyujFqtDEtlCeL5UnNqfcPRXhAqzGCOGGdBvO7Tx2cfHsReXnNTv9FWN
         1vNYc8Un//B7WtxWTqFZV17EZVsYcqlzx5wjuatiBZ7cRsCjDvmZUTJtrvqrfqCfUDcq
         l3wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id p6si1656163edx.294.2019.03.14.00.56.28
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 00:56:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 96CDD456F; Thu, 14 Mar 2019 08:56:28 +0100 (CET)
Date: Thu, 14 Mar 2019 08:56:28 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, anshuman.khandual@arm.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix notification in offline error path
Message-ID: <20190314075628.kb6j4de3thm6gezq@d104.suse.de>
References: <20190313210939.49628-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313210939.49628-1-cai@lca.pw>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 05:09:39PM -0400, Qian Cai wrote:
> Fixes: 7960509329c2 ("mm, memory_hotplug: print reason for the offlining failure")
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 8ffe844766da..1559c1605072 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1703,12 +1703,12 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  
>  failed_removal_isolated:
>  	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> +	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  failed_removal:
>  	pr_debug("memory offlining [mem %#010llx-%#010llx] failed due to %s\n",
>  		 (unsigned long long) start_pfn << PAGE_SHIFT,
>  		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1,
>  		 reason);
> -	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  	/* pushback to free area */
>  	mem_hotplug_done();
>  	return ret;
> -- 
> 2.17.2 (Apple Git-113)
> 

-- 
Oscar Salvador
SUSE L3

