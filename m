Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC6DDC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:02:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620D521951
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:02:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620D521951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDD5F8E0072; Thu, 25 Jul 2019 09:02:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8F228E0059; Thu, 25 Jul 2019 09:02:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C570C8E0072; Thu, 25 Jul 2019 09:02:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 77F188E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:02:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so32081779edr.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:02:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=xm1uc7em0G8JejwS/Yo1wbMLfKh/weg38a2HA9WQH/M=;
        b=tyU1Bhkk+pfDjMf0J3W+mn58gguu/ZnS0uO5TwOMbGYkCuUGx5lWQivhedYn7yRvWI
         r3JuopWSB9WbkT+gEmOHr+2QKCVy3bFnDqOQ+gZpqdyyzJbflWRW19kfTdC44oLVWd+J
         Nv1TpF8HwTmXEaMkQRPmQx9mcZ0/phdiaw9AL5MhrBf7OMVz1WkjL3MDdkSF8WgNZ0l/
         U/b63clINOQWcrHdAVwJd2UU0UX/Kjbzxq00WPt012G0AoQSdGxqwO8F1UUKpCXdYWQc
         vaYyJNaIFi7mIIYNLT3a6UhfiTq1KYExFEzHsYXK0yNxDsgpw99Xyk2gAeRPRJIoWWQ+
         uHVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXItiHr2nkJCGLzy83Vrll9k03h1M2ip2vihvxHVn6VQopdvwSO
	BeXlvnXsqIrGID1GahzEo8LV4oGndw+3DqUYP4GyIAYVxBXExLQA/9pyUUE1cppSjHPqGmhFm6N
	uEv3up+Wb1iL1VXen8ruZvin9417XL6be4gnhoIcDqhjCQ29c0cWg1PuNFOwTvrSWEA==
X-Received: by 2002:a17:906:2555:: with SMTP id j21mr68715318ejb.231.1564059778019;
        Thu, 25 Jul 2019 06:02:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyzJcJircady/Z9q13w53SpQH3V6zLEwo4FUId5+hNSuheGrLlbBE7f8AZhdBD2+cBHZI4
X-Received: by 2002:a17:906:2555:: with SMTP id j21mr68715237ejb.231.1564059777171;
        Thu, 25 Jul 2019 06:02:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564059777; cv=none;
        d=google.com; s=arc-20160816;
        b=gp5gf9jlaU9ARpAysPzc+aEtSxrfSF0p8G59vf+vkEm87ODQNETT1ZM8PWSmEJ80Z2
         dULyAV/Hsn1iUFIud/eGUn6CJwMbZF9a5Gc0ewkJobVqRsbiCveIsRdvcVpLkxl32nd9
         MRlbRxS5eEjr6ECy8YxXEqDyesJvUIVzP+swVlnHohiInLzJlNMX8BhQc+H+RYzF0NtF
         Evbrfu/rcIejDUwi0TJjgtELORb8bXLfLufoQz4gbz2WyMANZYID31meDNtxmk8r0sof
         lip/PYToC0R9RscOWpPCHyLWPL7mX/3hBCamKRpfX8sJ7Fs5elyJSsp575Yv7UPmq9XJ
         VNWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=xm1uc7em0G8JejwS/Yo1wbMLfKh/weg38a2HA9WQH/M=;
        b=i8JTRSOZ7bSv68S34CMQqsX/0sS8qpzsY0DAStIAmdnRRBEFXBD+k3J0X6R1EfZE6w
         v38x/vjNHPicdOrdLQbfnNid8Ok8bdeAlv4tZDq/qLk5BKGBUZClyd0tDdFcKEcMUsGz
         HjO6bPrwagn+cWZzXMHWYU92qVWQrP9S0oMSth80rR38ujQccLqnwgAVpa23OSuR4jCX
         I02K7P+h2ujr1U0O0BQkBIdtbgEwZj9Z4Be4XF2XK27f3IuIlipeoBXlRmJUk4H3DNyF
         /qTRcF5OTd2mxGmzgnIutzUETT09pnGnB6197qFwJysjWUqafIIV709wR5Hvwj/PeB2t
         9vLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dc24si8854396ejb.220.2019.07.25.06.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 06:02:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92D18AF38;
	Thu, 25 Jul 2019 13:02:56 +0000 (UTC)
Subject: Re: [PATCH] mm: compaction: Avoid 100% CPU usage during compaction
 when a task is killed
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: howaboutsynergy@protonmail.com, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
References: <20190718085708.GE24383@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <68fef6b3-bae8-2479-0e6e-ce13607369af@suse.cz>
Date: Thu, 25 Jul 2019 15:02:55 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190718085708.GE24383@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/18/19 10:57 AM, Mel Gorman wrote:
> "howaboutsynergy" reported via kernel buzilla number 204165 that
> compact_zone_order was consuming 100% CPU during a stress test for
> prolonged periods of time. Specifically the following command, which
> should exit in 10 seconds, was taking an excessive time to finish while
> the CPU was pegged at 100%.
> 
>   stress -m 220 --vm-bytes 1000000000 --timeout 10
> 
> Tracing indicated a pattern as follows
> 
>           stress-3923  [007]   519.106208: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106212: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106216: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106219: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106223: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106227: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106231: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106235: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106238: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
>           stress-3923  [007]   519.106242: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
> 
> Note that compaction is entered in rapid succession while scanning and
> isolating nothing. The problem is that when a task that is compacting
> receives a fatal signal, it retries indefinitely instead of exiting while
> making no progress as a fatal signal is pending.
> 
> It's not easy to trigger this condition although enabling zswap helps on
> the basis that the timing is altered. A very small window has to be hit
> for the problem to occur (signal delivered while compacting and isolating
> a PFN for migration that is not aligned to SWAP_CLUSTER_MAX).
> 
> This was reproduced locally -- 16G single socket system, 8G swap, 30% zswap
> configured, vm-bytes 22000000000 using Colin Kings stress-ng implementation
> from github running in a loop until the problem hits). Tracing recorded the
> problem occurring almost 200K times in a short window. With this patch, the
> problem hit 4 times but the task existed normally instead of consuming CPU.
> 
> This problem has existed for some time but it was made worse by
> cf66f0700c8f ("mm, compaction: do not consider a need to reschedule as
> contention"). Before that commit, if the same condition was hit then
> locks would be quickly contended and compaction would exit that way.
> 
> I haven't included a Reported-and-tested-by as the reporters real name
> is unknown but this was caught and repaired due to their testing and
> tracing.  If they want a tag added then hopefully they'll say so before
> this gets merged.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=204165
> Fixes: cf66f0700c8f ("mm, compaction: do not consider a need to reschedule as contention")
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> CC: stable@vger.kernel.org # v5.1+

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..952dc2fb24e5 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -842,13 +842,15 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  
>  		/*
>  		 * Periodically drop the lock (if held) regardless of its
> -		 * contention, to give chance to IRQs. Abort async compaction
> -		 * if contended.
> +		 * contention, to give chance to IRQs. Abort completely if
> +		 * a fatal signal is pending.
>  		 */
>  		if (!(low_pfn % SWAP_CLUSTER_MAX)
>  		    && compact_unlock_should_abort(&pgdat->lru_lock,
> -					    flags, &locked, cc))
> -			break;
> +					    flags, &locked, cc)) {
> +			low_pfn = 0;
> +			goto fatal_pending;
> +		}
>  
>  		if (!pfn_valid_within(low_pfn))
>  			goto isolate_fail;
> @@ -1060,6 +1062,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
>  						nr_scanned, nr_isolated);
>  
> +fatal_pending:
>  	cc->total_migrate_scanned += nr_scanned;
>  	if (nr_isolated)
>  		count_compact_events(COMPACTISOLATED, nr_isolated);
> 

