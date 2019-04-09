Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 593CDC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22F6020880
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22F6020880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4A726B000E; Tue,  9 Apr 2019 09:16:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF92B6B0010; Tue,  9 Apr 2019 09:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C1F16B0266; Tue,  9 Apr 2019 09:16:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50A8B6B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:16:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t14so3775061edw.15
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:16:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qi+ikgZAN30/YlclTZpddC0Rk+pF/rEYM2D9HVAVJ5Q=;
        b=aDlGWnh0XSl6e6/BdJYtbt5hd/hIrR4mxni4h3PK3JMMUBc5u7P0wLkoddu6uTitvM
         /Pq4M7u9ZAKNCvLNByofco0sdF4ImugBmQUm9uLzHLoF7GA0AdxjhJwo6HtCIFfvAbla
         rXBcqfXxjv4jpb41452PGjDndlKjyoWDEVUC8KsRJsEP8cAcwL+EUQnuk6JHG/Lac2DU
         dmX78KfwtXV7SEAVa5X+4RprBFBnwPEPZsOy6oOpb+xvuo8OX9jEtIOSDrCy9NwdAnCV
         NA9LHLfx2CufprCIPo9/t7OcHW1M19WAPx6ITb3itiRfo4YAnspnX8r3PxxRudLfoBzX
         6GOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXnUkg9SeODDeIlrEU5a7B/tUisjouwfbhHDlVoe/8sB9CKbDzo
	BHmYaJoWIdzmUubChZRMbym7m92H2BoemCZkzgFSlBfcKcpIZ6TfKeKH4Si6DHSxQwZraPfKg5J
	Kfpvh8kLAikWns7Dctm+0nlG72PJhyu8QaUhm2QVns0d8N9uvVccIk3ecnVSvJ9QFsQ==
X-Received: by 2002:a17:906:5e0d:: with SMTP id n13mr19986693eju.37.1554815805866;
        Tue, 09 Apr 2019 06:16:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgV2Wr1kgbQ7Bct+rJtHEEPM38inJpfjzCLrdN0AFmFSP0GdSDYwYpHWhztdhzZKbrAJWa
X-Received: by 2002:a17:906:5e0d:: with SMTP id n13mr19986658eju.37.1554815805182;
        Tue, 09 Apr 2019 06:16:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554815805; cv=none;
        d=google.com; s=arc-20160816;
        b=rrsFE2IgxIjkBeVk8TYtRBk9CCYmEeXhalFzwuJlweQusyXpOFSl+b3vajTO6NpVDE
         GP+JZYkAdvtOYq0/eFRuHgI2uqaEZ3+FF7hHjaCZgm+UnAj7rT2xAK0hL8NfunDdxSzO
         nuS04W7umd6PoMNlsHsPAIxQa+OkP1hO93P+awMuYhOi898d1VUCQJWCVwmpalYp2E+n
         52zKr6Tt0vOEAd8M3q/IEGiHAiHpEsGoG4Nm5E9felH3XQeW75kSKueV7xeOg31zE2Fn
         hXWBiUWbb7ezXR5JwUW4On4ZVO5hXMmn7MdojNIGDb1Fn62/UOFx/4IFSVr1pX1htG7j
         d5Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qi+ikgZAN30/YlclTZpddC0Rk+pF/rEYM2D9HVAVJ5Q=;
        b=tKXnf8cjacow56W/d2b2iEkuWrnwZVeFBPCdFXPGh+3FFOH6UXv2OtRx4PnuycYPnN
         w7yeJfD20ImzuZfKn/zbD4WTFzP2IwJW4UWQRiTT7ntdK232xZIkqhXr4JQs+0fetjgm
         BY2lGL3HTpXVlyCFn0NKlJ4Moi1BiuMV5ujy1yhkmgO3g7nY/ypNAiwp5ODG8IQSLTxx
         LwShwwaujF7vcERbHjUOUfkvNRshy0Gbr+HrpNn62mo9CJkHOmNG8BUE+5NfNUq9LDAd
         LRkkQ4IbYcTFuBAeklNTweGZJIjBo8dTCxmefj6QvX7zkO8Gtlxm3yH51jsVZgfOxTWy
         2rfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bq13si1410365ejb.7.2019.04.09.06.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 06:16:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 82974AF7B;
	Tue,  9 Apr 2019 13:16:44 +0000 (UTC)
Subject: Re: [PATCH] mm/vmstat: fix /proc/vmstat format for
 CONFIG_DEBUG_TLBFLUSH=y CONFIG_SMP=n
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Jann Horn <jannh@google.com>
References: <155481488468.467.4295519102880913454.stgit@buzz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a606145d-b2e6-a55d-5e62-52492309e7dc@suse.cz>
Date: Tue, 9 Apr 2019 15:16:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155481488468.467.4295519102880913454.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/9/19 3:01 PM, Konstantin Khlebnikov wrote:
> Commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
> depends on skipping vmstat entries with empty name introduced in commit
> 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
> but reverted in commit b29940c1abd7 ("mm: rename and change semantics of
> nr_indirectly_reclaimable_bytes").

Oops, good catch.

> So, skipping no longer works and /proc/vmstat has misformatted lines " 0".
> This patch simply shows debug counters "nr_tlb_remote_*" for UP.

Right, that's the the best solution IMHO.

> Fixes: 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmstat.c |    5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 36b56f858f0f..a7d493366a65 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1274,13 +1274,8 @@ const char * const vmstat_text[] = {
>  #endif
>  #endif /* CONFIG_MEMORY_BALLOON */
>  #ifdef CONFIG_DEBUG_TLBFLUSH
> -#ifdef CONFIG_SMP
>  	"nr_tlb_remote_flush",
>  	"nr_tlb_remote_flush_received",
> -#else
> -	"", /* nr_tlb_remote_flush */
> -	"", /* nr_tlb_remote_flush_received */
> -#endif /* CONFIG_SMP */
>  	"nr_tlb_local_flush_all",
>  	"nr_tlb_local_flush_one",
>  #endif /* CONFIG_DEBUG_TLBFLUSH */
> 

