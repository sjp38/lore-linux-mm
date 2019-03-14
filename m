Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F4F6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F5C22184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:30:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F5C22184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFBB88E0003; Thu, 14 Mar 2019 04:30:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAB518E0001; Thu, 14 Mar 2019 04:30:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9ADF8E0003; Thu, 14 Mar 2019 04:30:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75F748E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:30:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t4so1922397eds.1
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:30:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FJBXiu24THUCeR7dgdwrm4o+o3aw5Az5+ZxavG0s5XQ=;
        b=iMeR5aM2wUG/cnQ2CtCf7XvSDzVVv3P1LX77ZeAgz95wlk+A+3GpFLCOh4hW98W5xR
         Hitsh9r0tBXzmlHnonUQhVSLZjg2kodnt1AYkBSbOkTVZDnq1utRw2z6P6OZWZZtkTOc
         Ljfj4wZvEwp0up6WixCvTy4NjmnfTJ19Eh8U31ZVw75fNxZthaI1u65J3Fm7cxUKdzjc
         Iz9A7upLf1WlDCrH+Y9VK+cDbl/4qOXw66YiJtypDyzjAYHuPej4MQifjbqazXeiXA40
         phNmgcp0aMJyZn2cQZF90AjGxaI0yCm7xfUBygBEvSTW/TIevNb97fC0gSAWk6V/5iCK
         4toQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUeMS3RhB/0bmKTM8JpMGAOCd4wNbs2nOsEyiBEIjqvnu9InQ+e
	tzTlpbCIp7W+aOXP5l1RJKAcT1KlnSwnWhOmXE/RzM6yJdyvFdw4+kSfSk08DtvSS2hDx8huE5/
	SbU2nDmp1tVrvLBS2/ut94/0Z0FgMTO6qQ92fNdI1u5uqWOdg5xIkh6U28zCvOFhuTA==
X-Received: by 2002:aa7:c153:: with SMTP id r19mr10604010edp.139.1552552244057;
        Thu, 14 Mar 2019 01:30:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKJuGnb/x9NW+xEPGQieiehPtlzhgdPYpCpCKN9nWmnOPC3jscBF2Ot15PQJyspWW5rFGO
X-Received: by 2002:aa7:c153:: with SMTP id r19mr10603969edp.139.1552552243306;
        Thu, 14 Mar 2019 01:30:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552552243; cv=none;
        d=google.com; s=arc-20160816;
        b=zwXotwQC2co6S89uVVARKVYYWNb9agIaUpAyiu19/JoEwIz9nGHvl18gj8rSA5cado
         hrBQ+qObzggWatM/3xyeQgZ5XHuUNlzErBRNGHRV3OfdR8zgDxhrsFoPoeBiM+YaAgRI
         xKuMo/3EQKlfFnCER/APb6ytulCoT+kPYZ/HKbnA7mH366VgkgEHz/U350BHQUhPLrSB
         rFnhJPSlAyRvUcI8/SeKU5fiE6iX1ax49Xi4JPjAotHeS/H/yAq8EMj1mu77YLNDr48E
         4yDlPIo3Otv7fv+ZN7UgQtvTdZHaAJCwZW6kBBTKyJY9Oc4fXJdOIQJRZiP1xGuBVzf9
         LwXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FJBXiu24THUCeR7dgdwrm4o+o3aw5Az5+ZxavG0s5XQ=;
        b=hulldDzK4vjU6HEHpmj99JAw9KfFFro5XsKTvXA85ZomtSwTwy04QHsPHP6OQhL2lI
         bsBXNkaKtP38axr/xq7cEME7jR1Smd+zDK6mEdzb7TVN/nAf9bu10EvN+vOwbXClcb12
         JWTjcm6qfC+yOuuNi0HwCgMyAJyGpuqavFgIhKt2rGetMyaRKHUkmUFLvNrMBrZSgt/G
         8lb/oshjix6D887BLSwXIU3DCyQbSbgvfUH7XddU8ZbJw4pCknga4SMRkIwKrE4U2F8c
         bTNajNwLs/rFO9xPAPRmJk69N1og6PXQtKuxEaEyzJkeBZQIJzc3KUV098qof/V0qxNt
         AbkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si398550ede.331.2019.03.14.01.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 01:30:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D52EEAD4E;
	Thu, 14 Mar 2019 08:30:42 +0000 (UTC)
Subject: Re: [PATCH] mm: compaction: show gfp flag names in
 try_to_compact_pages tracepoint
To: Yafang Shao <laoar.shao@gmail.com>, mhocko@suse.com, jrdr.linux@gmail.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, shaoyafang@didiglobal.com
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <75d7cff9-add2-20f4-ae3e-2d99048c6614@suse.cz>
Date: Thu, 14 Mar 2019 09:30:42 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000036, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/2/19 5:38 AM, Yafang Shao wrote:
> show the gfp flag names instead of the gfp_mask could make the trace
> more convenient.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/trace/events/compaction.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index 6074eff..e66afb818 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -189,9 +189,9 @@
>  		__entry->prio = prio;
>  	),
>  
> -	TP_printk("order=%d gfp_mask=0x%x priority=%d",
> +	TP_printk("order=%d gfp_mask=%s priority=%d",
>  		__entry->order,
> -		__entry->gfp_mask,
> +		show_gfp_flags(__entry->gfp_mask),
>  		__entry->prio)
>  );
>  
> 

