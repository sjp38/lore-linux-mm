Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12FA8C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 08:47:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCE5F20657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 08:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCE5F20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 660B98E000B; Mon, 11 Mar 2019 04:47:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60FA28E0002; Mon, 11 Mar 2019 04:47:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 527AD8E000B; Mon, 11 Mar 2019 04:47:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFB0D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:47:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d16so1708392edv.22
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 01:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IQliClByDtdpq2tK0UidAA17wxvL04QTsP8PR6jl6h4=;
        b=HWq71mS0roWpW7r4y8dNaf9UAKwOgkYBEBTQXi6zrHMBkEE0jkp5YZms+qIwjUK3gT
         Ebu8ZhVT5rbc1tqw55G+MoZPk4dWll+088RUKdO7cB41aQ+vEjC0s1U1yxpdX9XVZLYD
         nZB97hhA3F7Lqt0hznV4PKhhM8eO2H3AvUeB21guhpNkeY50N2H4EK+BVvWZD1l0YD4r
         skDnKMsZrPhb04ow9bh55HrZOYOCzpcrnu7T+l13NtrZP+nqMKS83IC9Zr2DqLJ+XA0G
         K1QjEA4Xn2ZuAQECVBPLgCNE/Od826nMhLLbyOjurO7UkwYvSF0wcLgoPo4EljjYstbo
         qQxg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWbDAmiyKlBX6VXOEz2v6O4Xyj8QHFJWukTH6TjrmkO4SZ63DkC
	YOL2dvDE5/eiOqttaTdw4Ur1+kDB0yW+/wpW3XAKePcndP7/ZzMtroLrp5VHDOox2gPgoBwt3Oj
	JwYJin7uGfj6wyII5bVIIQWb5SvWdXiruusSQru6nqG0+Pf4zWVrSfFxkYPtbIZM=
X-Received: by 2002:a50:b16e:: with SMTP id l43mr41313871edd.99.1552294065534;
        Mon, 11 Mar 2019 01:47:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSBjL99NnwS81hhBkRcvm276evEN/MshB27oKKOTiUfePMzoFHYIb2Duzg22acMH2/HAj5
X-Received: by 2002:a50:b16e:: with SMTP id l43mr41313823edd.99.1552294064610;
        Mon, 11 Mar 2019 01:47:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552294064; cv=none;
        d=google.com; s=arc-20160816;
        b=hQlVle37snWkIiNzib1EP6tmgPqPlanfEy8vYiEAVxykN7GOYn0TFO56D+wUM9XJfI
         Y0jTnluigFNGpf9nF3cPKnutwI1iSYEaLDCMU9uowZodMfbenovewDF7OAYx890DebVe
         2hJWFRm7MWO3yU7nKTv4zuZA6c2ptnz0LgiNoHr3DYztKWQzvtkauKrySfN9MlzFj2VD
         7Jggj8McysNH6rO6uDxQzIht0JkiLZB92W40NyEjAMfAqXn/GjKbHriBqJfCCTLqotPm
         ipC7V9zVWDJbTqSWsLquVJ74r84frwDC8lLaDLcWX2WmC+U3ELj1EDL146Aq2FeDsm4t
         lmyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IQliClByDtdpq2tK0UidAA17wxvL04QTsP8PR6jl6h4=;
        b=aQU+aJsgRyCnCVbcOAGkNJkzCyxJrTs4KFXbXDvu8R0LUCVv/ucSGe3yiitvTw1XLe
         GOVAGqkGFusPYX12cok/WdK6ZjzJpIO20x5Tg4pRW1Yh9FJDQ5L++EGzxYeN35ku2Hxj
         75EFGKrC2vD532X6/OzY8180RUWa957T2I0KqOdV5ch37K85rzsIsH1TFylLI2coCnLT
         vYIm65sdVY2BcvU94CRn+yQ0Ui03yS2wz+iSypqwmHj+HpTYlSoOTjNL8V5oL4R2kAW4
         CwMLHsC0LSdyDAdK8HenoNMfLRiAzHtO3ofuGT8e7GDhZk/EqXQeo7QsqQTc4TrVADuZ
         I6Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v19si3609720eja.285.2019.03.11.01.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 01:47:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2FD81ACC8;
	Mon, 11 Mar 2019 08:47:44 +0000 (UTC)
Date: Mon, 11 Mar 2019 09:47:43 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: vbabka@suse.cz, jrdr.linux@gmail.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: vmscan: show zone type in kswapd tracepoints
Message-ID: <20190311084743.GX5232@dhcp22.suse.cz>
References: <1551425934-28068-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551425934-28068-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-03-19 15:38:54, Yafang Shao wrote:
> If we want to know the zone type, we have to check whether
> CONFIG_ZONE_DMA, CONFIG_ZONE_DMA32 and CONFIG_HIGHMEM are set or not,
> that's not so convenient.
> 
> We'd better show the zone type directly.

I do agree that zone number is quite PITA to process in general but do
we really need this information in the first place? Why do we even care?

Zones are an MM internal implementation details and the more we export
to the userspace the more we are going to argue about breaking userspace
when touching them. So I would rather not export that information unless
it is terribly useful.

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  include/trace/events/vmscan.h | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index a1cb913..4c8880b 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -73,7 +73,10 @@
>  		__entry->order	= order;
>  	),
>  
> -	TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
> +	TP_printk("nid=%d zid=%-8s order=%d",
> +		__entry->nid,
> +		__print_symbolic(__entry->zid, ZONE_TYPE),
> +		__entry->order)
>  );
>  
>  TRACE_EVENT(mm_vmscan_wakeup_kswapd,
> @@ -96,9 +99,9 @@
>  		__entry->gfp_flags	= gfp_flags;
>  	),
>  
> -	TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
> +	TP_printk("nid=%d zid=%-8s order=%d gfp_flags=%s",
>  		__entry->nid,
> -		__entry->zid,
> +		__print_symbolic(__entry->zid, ZONE_TYPE),
>  		__entry->order,
>  		show_gfp_flags(__entry->gfp_flags))
>  );
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

