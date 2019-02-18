Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AFFCC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:42:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 523CD2177E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:42:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 523CD2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFE6C8E0003; Mon, 18 Feb 2019 04:42:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAE088E0002; Mon, 18 Feb 2019 04:42:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D868E0003; Mon, 18 Feb 2019 04:42:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7093F8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:42:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u19so6769701eds.12
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:42:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RPO2bw2HIkkmuCkSN+K19nDicU+YEEq9xX/u+I/+Slo=;
        b=mSX+EBWWkrrJwkjtgeJtgea9/K+nUuA++HDusA5yX28NU1QSUTs9ErJBXdSNXAhw5e
         xiIyp4W7lv47PCM8NjMoLsq/FN9lN9GSp18uVaJnMDL+lbHeLNqX3hdJeqFekNFIjBth
         FScSR8yq/lqIanW82LTMHaMM/RkwCr93sALLA2iAANxXWMzcgQrzYNa4OZyz1Dwe1BaV
         Ei/YHg+f03BNsCv8xh2HhmZsiyjTg64MfHKJK2z+/Xs7z+gjkHG7CtErmMkcwAw6Ob0B
         cujyhb/tskb5JfPK9fwekyQrUwGl8FHf8oweyjC2tUiSYsEIouB4xMt7+AAFVyEaOM3O
         NjJQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuapfPf375Hxx3ZTDjojdzzW6roEKAaakU2Ze68y4MwQImSWFqkP
	hXpD5eUCN6b58gSqrzp3APdsdO7Buz/s0rNp7rZf8DWPx84QsD8+RxcniQZ4ZwKpX7ie2rWETrS
	SHea1hpRveDhS+E/2sjz9cI0YX3Ek6o9/9MEDhI9akMg/oHf0BtrhyoQeLnBDMjs=
X-Received: by 2002:a50:9927:: with SMTP id k36mr18390612edb.31.1550482933966;
        Mon, 18 Feb 2019 01:42:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ2Y/BdmNnf8ncZ4IPolt99M3dohiCWCB/tbNxaIP6yZFRyjf2Ec/RjIuqarGQyG8ErT8pe
X-Received: by 2002:a50:9927:: with SMTP id k36mr18390570edb.31.1550482933140;
        Mon, 18 Feb 2019 01:42:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550482933; cv=none;
        d=google.com; s=arc-20160816;
        b=PZkUZxYSyonkDdlUH7KncDtRLZZ2wL2hA/gcfroj3N8OTQ3UZpcKZyxJKc81GooRj1
         7tzIvVtnsQYEV5F62Hf1sajZKWcPDUcEfdvXvvLJAeaEk+BpFF5VIa9NrHl6KYpG3Ln3
         IiUGw7zG3/nBJCanm+ts0E1Ax6JIevpn82FkZk1skkVUDI5tMOglwjZXdKpuwR21MRGF
         Ga0vPR+2bt94JtJ3ZVmc9shXSg1Hy8L03XDtr/6cHoPzp02IGluFPLLAIaZlN31VJvdd
         OC1bD4DNojPmLeztissYdkws3UdH+uTzuoOTDhwMDiJwGygQZr/4HExmLEYwBosAbwfx
         z/MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RPO2bw2HIkkmuCkSN+K19nDicU+YEEq9xX/u+I/+Slo=;
        b=Zq9b1s9R5AeYu5xqMa9Og/y5xWNzpvnRvB/Z6YKWIP3wKu3O7xg1C9RmMszFoTb9JA
         tnBAuH67DKBpjg0ANbyfTT9aIW0oIw8tK6K8+fRu5gl32p6jDsA/tX2NI+1vKP5jmR2y
         2keuTXzlBpkopa4Ttm2b4Zu1S9pzF4m4+WXEFqKao+NFU7unXFttlLKpY4ykHKPZeaHZ
         lsYyaNNMXEzM7CPhmTk9Q20nB4GbNbi1e9SodLmyXSpcQslrpcxETTii/SEEBVeb1w93
         v2YfADG5lX2WmGsAN4viaODHOfUCcISUZRY7YnKVSVk3gg1kfQ8aNowIOCVFL9Enf68y
         nazw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z38si3195142ede.62.2019.02.18.01.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 01:42:13 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A0BBCADF0;
	Mon, 18 Feb 2019 09:42:12 +0000 (UTC)
Date: Mon, 18 Feb 2019 10:42:11 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix buddy list helpers
Message-ID: <20190218094211.GI4525@dhcp22.suse.cz>
References: <155033679702.1773410.13041474192173212653.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155033679702.1773410.13041474192173212653.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 16-02-19 09:07:02, Dan Williams wrote:
> Tetsuo reports that free page statistics are not reporting correctly,
> and Vlastimil noticed that "mm: Move buddy list manipulations into
> helpers" botched one of its conversions of add_to_free_area(). Fix the
> double-increment of ->nr_free.
> 
> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Tested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Thanks for catching that. I have really missed it during review.
Sorry about that.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Hi Andrew,
> 
> Please fold this into
> mm-move-buddy-list-manipulations-into-helpers.patch.
> 
>  mm/page_alloc.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2a0969e3b0eb..da537fc39c54 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1851,7 +1851,6 @@ static inline void expand(struct zone *zone, struct page *page,
>  			continue;
>  
>  		add_to_free_area(&page[size], area, migratetype);
> -		area->nr_free++;
>  		set_page_order(&page[size], high);
>  	}
>  }
> 

-- 
Michal Hocko
SUSE Labs

