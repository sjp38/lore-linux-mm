Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EBA9C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:33:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A06C217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:33:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A06C217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0DFA8E0004; Tue, 26 Feb 2019 07:32:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C988B8E0001; Tue, 26 Feb 2019 07:32:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B111B8E0004; Tue, 26 Feb 2019 07:32:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 525C88E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:32:59 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so1533778edd.6
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:32:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=588nElYSXqPXWLYWZm8r72xqcno0qJkzGRzNwm9lTDs=;
        b=AA7tA+cLSGuEhKc/rJF+zALw43jveOTNGXWr1BLf2OMPKdwsiJe/qK0MAH86y75rmk
         8cgzp/goYX59sHU+YLjqY0brYK3Beqx3IVKWjEugqNcvmXrgnqjTCWavUDf0Xs4e2xDd
         GorybX2+OUwhJ5eJvZXmDYc58tcAS1j6iEE0i03GD02rNQCdfhGvZe1XfwVW5+igYFJG
         gl5D9j3RXvC9lItH0vDuL0WOGqbJpiIA6QGUGnUSGlnWku4l40f08nNUGxmxBz/it5WT
         S1AiNG/TVeiS3ipsUlyXqetn0KDICcVV+9HV+wYwMYGHDa1bKftYHz5AXknUqmXq2jv9
         RvTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuY017zyrRIp2HMGzcDj2mSkVp0vGAuOGUw1JkPt1YzDdbnqU5jP
	Q1KqwfOXswRa6q3dNW2QvaHvcckoHTtEoDHFcLLvTK7Xim7iwNiU+k4RUvcj9T8oaS6DZVA2vR/
	5/NliAsbOmohRMaX6K25OpGq5GESzjz9pIJhrCPLe9s8HZNFu5kDt2MfIshbi9axzaQ==
X-Received: by 2002:a50:a2a6:: with SMTP id 35mr19073868edm.51.1551184378865;
        Tue, 26 Feb 2019 04:32:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbDQ5Ov3yYtYXE7ggWLnl3keDQ2pcP59YHj5Z7tZVSae5kPRevh88rD6rUsBYnTMY4Hdqco
X-Received: by 2002:a50:a2a6:: with SMTP id 35mr19073805edm.51.1551184377878;
        Tue, 26 Feb 2019 04:32:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551184377; cv=none;
        d=google.com; s=arc-20160816;
        b=vqkxR0DcU1nbIAMTIBSWhm9yJUEdLW4OFf3Z9AjfXexxtSnHS9XV6BRm1S/llOTf6Y
         7JuyI3pVItYs6huNINfdqTcJ/7+9gVUOUG4wDFCTusNSA550c1j8KCyk162u7MDTZSzy
         vec9zSvajmyutpJsw+GboyGFZhpwJLnjBBbBsgxGngfPHhPhHVF51+DN/C1XnonwRtrF
         hdflDrnix6353vpYJAMXTj8sEd74f9jFU7WF1LX3PuEGjFXrSH9pwPKpTnfB58vR4AyL
         L9bM9wY955zRvawXWp4oF3BvjtaO6tA3o4UndgLMZcsgFL8Jwv+LCKr3uzlXDfBl3s3T
         OUZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=588nElYSXqPXWLYWZm8r72xqcno0qJkzGRzNwm9lTDs=;
        b=o6GE3dIMkjBSll6IH1i+cGnTbVZHknAUlUQDJOM70bqB0kbeejtVZzY8ZKSHUgcid5
         0W6mHah3zWVz7xNXRML/e4wGjh3Bw5TVvd9YlzwnxoKQhNpPY+7xU7Yf/5TDYPX0xDMr
         dIYYp6IFRwWtt901K/hh31Yz7FHPqqouN82bPQchcieoEHIHEANo79Mqa65WDrmOlXC+
         gmpeyShedQAo37WNvsECVrnpEYooXFW4BYtWvX84cZp9xWMRuGllf3KmIND3F8kmojs0
         awew6lIyAIXoYBs72c/DsP+RsE+00SpATU0VaiO53mAy/FBIeXcdSH5xvEUztCI46vB+
         1CIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m13si3295033ejr.109.2019.02.26.04.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:32:57 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4780FB11A;
	Tue, 26 Feb 2019 12:32:57 +0000 (UTC)
Subject: Re: [PATCH] mm: compaction: remove unnecessary CONFIG_COMPACTION
To: Yafang Shao <laoar.shao@gmail.com>, akpm@linux-foundation.org,
 mhocko@suse.com
Cc: linux-mm@kvack.org, shaoyafang@didiglobal.com
References: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <8622dd4e-6341-1ea2-0e26-ed7f6b2aaec4@suse.cz>
Date: Tue, 26 Feb 2019 13:32:56 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/26/19 7:19 AM, Yafang Shao wrote:
> The file trace/events/compaction.h is included only when
> CONFIG_COMPACTION is defined, so it is unnecessary to use
> CONFIG_COMPACTION again in this file.

Are you sure? What about CONFIG_CMA?

#if defined CONFIG_COMPACTION || defined CONFIG_CMA

#define CREATE_TRACE_POINTS
#include <trace/events/compaction.h>


> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  include/trace/events/compaction.h | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index 6074eff..06fb680 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -132,7 +132,6 @@
>  		__entry->sync ? "sync" : "async")
>  );
>  
> -#ifdef CONFIG_COMPACTION
>  TRACE_EVENT(mm_compaction_end,
>  	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
>  		unsigned long free_pfn, unsigned long zone_end, bool sync,
> @@ -166,7 +165,6 @@
>  		__entry->sync ? "sync" : "async",
>  		__print_symbolic(__entry->status, COMPACTION_STATUS))
>  );
> -#endif
>  
>  TRACE_EVENT(mm_compaction_try_to_compact_pages,
>  
> @@ -195,7 +193,6 @@
>  		__entry->prio)
>  );
>  
> -#ifdef CONFIG_COMPACTION
>  DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
>  
>  	TP_PROTO(struct zone *zone,
> @@ -296,7 +293,6 @@
>  
>  	TP_ARGS(zone, order)
>  );
> -#endif
>  
>  TRACE_EVENT(mm_compaction_kcompactd_sleep,
>  
> 

