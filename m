Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E47C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 18:24:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C9DD2077C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 18:24:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C9DD2077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E1476B0006; Tue,  9 Apr 2019 14:24:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 669A66B000A; Tue,  9 Apr 2019 14:24:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50B6E6B0266; Tue,  9 Apr 2019 14:24:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF3926B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 14:24:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w27so9236752edb.13
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 11:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=yDRII9QSeEWAXRN8hwlPSBFO/5gnddeHuvhHslccZgA=;
        b=pXqs8Z6UcpZJ9RdEYB5CerV8aFRJvz006WR4QOyWWZojsT9mZ6w57zi5MXbkOR8ivj
         POf3ddWlekfaucLKyTAkaMUWQfgO55Q3MuQBoFNfUEppifoDXWAN/6bmeULt0Qok4pZR
         cY5GkWW7Qvz0fNog97z17hxMq7IdcR0+KRI10LZRUSOOaPwHps7ZewLAIwZFK1vIrZgu
         KWGnuROHPY+6VSiX9pp3LIFu2WH3q3AOotIsP9IJT12Cx1lEazbb7leqY4IRyqn3OXkW
         xqShJIv2giXnKiwup9xdwmQJqm2taXMiST7ufEdLHWJyw/eUZnZgBGPHw2XCVwFNbCoT
         maxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVc7VLpUVeLMadqCtTDTKYS172SN1xrQDqoRuxtmAVYaK9SlR0+
	lfEgJ7rkVBSgM/2z2SoYtfhHsnAHq2PcqpofSIx36LD3us8zN3IbhqLgImCQEtDNBN4EcZbhK6D
	pWwk2uN/1/7UzED6KesYXdyPW8VgyyW2pJHugYxVzgY22GAMtHSZDe5iI71ktvu967g==
X-Received: by 2002:a50:f419:: with SMTP id r25mr24644077edm.250.1554834272420;
        Tue, 09 Apr 2019 11:24:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0J6b2L/wo/EDhMZv6/TK/ph3HiYghAYH6aH+MzdqaPlHhyAzBpbC/s3uYDOmuE26eZJDN
X-Received: by 2002:a50:f419:: with SMTP id r25mr24644027edm.250.1554834271413;
        Tue, 09 Apr 2019 11:24:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554834271; cv=none;
        d=google.com; s=arc-20160816;
        b=jlCedWLHVO/Dy0BEp6fabvGxGeMB4nov+yMESDjV1CI57wO89ugyM6h6QJPx/i4LMW
         zlW9hl5IbVee4FauNyRcQdJUfHfIWE6BCAEg6GYab2NznCi4Mor+v0rNjiM4TjfdD8/g
         BOZ1qet4TXMYrOq5dJxVvzMVDlvSHDMcAItxfwv7bfKJ31kws21f8PuvzGfAwlWUF3ju
         pQ+rZwz/esO4epsptq/lzT4pq5IcigRCq9mL8dnhKTxeUUMuBJyJSvx7rxJlpRJVGbs2
         8N0t7zOynD2c+w/uhf5Q8lhDCo40pTCKFOTaFZ96ACW8CI1OYWwqkEt2ho+svKnnn6ll
         WvNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=yDRII9QSeEWAXRN8hwlPSBFO/5gnddeHuvhHslccZgA=;
        b=PCOnjm4Brol8+eQuMvdKkBpkjtpb691MQwkl9+Fn9y6yDiQc7zy52GvNQ2n3rRIntc
         IZtCLms/lB0TPmSfcXr+fNmfeBPzoNZAHrNZEIeGc3KmEQJ/j7jWJJ8hzwaSE1Db2Jhe
         CHXcK3dkg7mOnpVrY/QaDyTbwCciosDx4J0Ei6S1GqnElw57H6LOTn2sagSCkVNarZqx
         /g8qVsO8Htd+PWDVHlVJX3Wneu0bcaCwUO11q2wlDtQy1VNeDA3hEU/9KHlANzGXF8YV
         dVEseqdLuUmDLkzl1zpOl/WWMnH31YNBJ/k8SK2xd5YT2oNelfoLGtgdoYio4cwRA0/l
         Zfjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k20si368967edq.315.2019.04.09.11.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 11:24:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8C349AE07;
	Tue,  9 Apr 2019 18:24:30 +0000 (UTC)
Subject: Re: [PATCH 4.19.y 1/2] mm: hide incomplete nr_indirectly_reclaimable
 in /proc/zoneinfo
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, stable@vger.kernel.org
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>
References: <155482954165.2823.13770062042177591566.stgit@buzz>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <1accd98d-506d-9dff-c962-6dc17b072c27@suse.cz>
Date: Tue, 9 Apr 2019 20:21:13 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155482954165.2823.13770062042177591566.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/9/19 7:05 PM, Konstantin Khlebnikov wrote:
> From: Roman Gushchin <guro@fb.com>
> 
> [ commit c29f9010a35604047f96a7e9d6cbabfa36d996d1 from 4.14.y ]
> 
> Yongqin reported that /proc/zoneinfo format is broken in 4.14
> due to commit 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable
> in /proc/vmstat")
> 
> Node 0, zone      DMA
>   per-node stats
>       nr_inactive_anon 403
>       nr_active_anon 89123
>       nr_inactive_file 128887
>       nr_active_file 47377
>       nr_unevictable 2053
>       nr_slab_reclaimable 7510
>       nr_slab_unreclaimable 10775
>       nr_isolated_anon 0
>       nr_isolated_file 0
>       <...>
>       nr_vmscan_write 0
>       nr_vmscan_immediate_reclaim 0
>       nr_dirtied   6022
>       nr_written   5985
>                    74240
>       ^^^^^^^^^^
>   pages free     131656
> 
> The problem is caused by the nr_indirectly_reclaimable counter,
> which is hidden from the /proc/vmstat, but not from the
> /proc/zoneinfo. Let's fix this inconsistency and hide the
> counter from /proc/zoneinfo exactly as from /proc/vmstat.
> 
> BTW, in 4.19+ the counter has been renamed and exported by

This was actually 4.20+ and this mistake is why we initially forgot
about 4.19 stable in [1]

[1]
https://lore.kernel.org/linux-mm/20181030174649.16778-1-guro@fb.com/

> the commit b29940c1abd7 ("mm: rename and change semantics of
> nr_indirectly_reclaimable_bytes"), so there is no such a problem
> anymore.
> 
> Cc: <stable@vger.kernel.org> # 4.19.y
> Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
> Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Thanks.

> ---
>  mm/vmstat.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 72ef3936d15d..7b8937cb2876 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1550,6 +1550,10 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  	if (is_zone_first_populated(pgdat, zone)) {
>  		seq_printf(m, "\n  per-node stats");
>  		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
> +			/* Skip hidden vmstat items. */
> +			if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
> +					 NR_VM_NUMA_STAT_ITEMS] == '\0')
> +				continue;
>  			seq_printf(m, "\n      %-12s %lu",
>  				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
>  				NR_VM_NUMA_STAT_ITEMS],
> 

