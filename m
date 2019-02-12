Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 565A2C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:33:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1363B2082F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:33:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1363B2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA9FE8E0014; Tue, 12 Feb 2019 03:33:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A58698E0007; Tue, 12 Feb 2019 03:33:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 948C08E0014; Tue, 12 Feb 2019 03:33:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 395358E0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:33:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f11so1773269edi.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:33:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q5DRaxmW7lxiNbVPe0epPmhhIOtSaCUjtXl4REFUAiA=;
        b=LZYaSSRUcvCDmX30Q9cjFOK/SAdbGDsmvwpzKF15y37dQ5YXnT1RkuKUiChl5TqaFO
         yRRTl4oa8P6iZswgU8bnrg4y2wBMokAccLmD5A55t+TrClIAKQR4w08iUc/QkbMdgEy+
         YQCANzdzoukrxihH1w5VMligy6uLOumcXjav9pjZPMlX4I2+caM/3WHKasQHvXQ8MUxF
         LSIYNDKcfnvD16XisUzQJPi4ARQRrHZkGl0kSNiZqSr7A+JZ9+rQu8QPei6lajqTlhaV
         WNnA+IinxyCpZbs44/XojajN0Re55EJWrEOOmmXVUkOe8LwJ5v+dgBmBRShwcr11Tejs
         uKdw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZijQpuoQtben9AcqwBqyJhkP1RfL+R5c5Ed12GYLAGFIkm3gTJ
	TqrzETeEA06ZBbtVLy7X0wLESDEQHbEjL9t7yfrglx2sZoh48lFne1nTJsjtEPz44qxOxitancO
	R/GLf81Qhd5KlfIqnwgISa/v5EzhGpEsGRXWtgoDZFk4e5mKf83AC3FcFa3Nz7HU=
X-Received: by 2002:a50:a8c3:: with SMTP id k61mr2063050edc.296.1549960412741;
        Tue, 12 Feb 2019 00:33:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYF8dt71o85LHmPtCpO46OTEtBybAO2B+6mClba+UYlqYRJ59dYWKAwVqzJgWciy9SoDNHb
X-Received: by 2002:a50:a8c3:: with SMTP id k61mr2062989edc.296.1549960411700;
        Tue, 12 Feb 2019 00:33:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549960411; cv=none;
        d=google.com; s=arc-20160816;
        b=dHSOLanm6mops8GEpyOQKxsmhKlV7YfRUspTXyA2dbHFP/3MyGvTNyVTPAT4SXvsIY
         tUUCC2PdBGV2eRudvoL/deTSq+2M2XxyWmyK2Qs9qLav48qWxR15jRtWrKnDAYjKuuJx
         E6weu737nNyUldIAIf2YPaS+58yYIQCFqQ5MjA0koS5OqEk82j4Yoh9KfcwQEqC5DpI9
         BPuPL5FqyTT7XXillxss0ckRKI9/OiqznqE7GpZfgjZjNGWWmsnl2ycnkmy04SqO+JFf
         paC09T34hWJfq0rkn03YlvX2vbol/bw8u9tm9FuIXCBsD2YntZ7pug8CsnNMl+MRJaPc
         zWYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q5DRaxmW7lxiNbVPe0epPmhhIOtSaCUjtXl4REFUAiA=;
        b=apHCe3oO4G9oIYe9GxWtv280QU4TKY5xZnk+ubcnvvsH9cdluy7YFxYIp8AbzgSfBP
         mJPELC2IDLDRNW5slTeM7WXJIxuvZvri9f4TA7RvkpJdwL2vk29q7d4k0msHARyopLAw
         0ySSaufdAb2BkUC7rHqooADWn6rc+dIPzbXWQBJk87ka9InnAx2sMfqNEi7Jo4ZrtT28
         BxOlqWrtAnBwx8jMS5CqOnPmz+TmKUdUuqYSyXjw5cI9Y29HJ6UQxxfH3CFgwLtMWZvn
         N8gCg7GzyExAllI45zJL2m3imaf8TcDbWxFOKk5N23fXaIhNfOBwXofPviBG6PIpbcBs
         hCqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h17si1031745ejj.234.2019.02.12.00.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:33:31 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4EC3EAF17;
	Tue, 12 Feb 2019 08:33:31 +0000 (UTC)
Date: Tue, 12 Feb 2019 09:33:29 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, anthony.yznaga@oracle.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
Message-ID: <20190212083329.GN15609@dhcp22.suse.cz>
References: <20190208090604.975-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208090604.975-1-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 08-02-19 10:06:04, Oscar Salvador wrote:
> isolate_huge_page() expects we pass the head of hugetlb page to it:
> 
> bool isolate_huge_page(...)
> {
> 	...
> 	VM_BUG_ON_PAGE(!PageHead(page), page);
> 	...
> }
> 
> While I really cannot think of any situation where we end up with a
> non-head page between hands in do_migrate_range(), let us make sure
> the code is as sane as possible by explicitly passing the Head.
> Since we already got the pointer, it does not take us extra effort.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

Btw.

> ---
>  mm/memory_hotplug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 656ff386ac15..d5f7afda67db 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1378,12 +1378,12 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  
>  		if (PageHuge(page)) {
>  			struct page *head = compound_head(page);
> -			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
>  			if (compound_order(head) > PFN_SECTION_SHIFT) {
>  				ret = -EBUSY;
>  				break;
>  			}

Why are we doing this, btw? 

> -			isolate_huge_page(page, &source);
> +			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> +			isolate_huge_page(head, &source);
>  			continue;
>  		} else if (PageTransHuge(page))
>  			pfn = page_to_pfn(compound_head(page))
> -- 
> 2.13.7

-- 
Michal Hocko
SUSE Labs

