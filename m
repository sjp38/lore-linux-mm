Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 141EFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAE812173C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAE812173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2588E0004; Wed, 13 Mar 2019 04:03:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E87EC8E0001; Wed, 13 Mar 2019 04:03:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D77468E0004; Wed, 13 Mar 2019 04:03:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81F2E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 04:03:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o27so532608edc.14
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:03:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jjQc6ADiSKUgjKXfNMvuBpTkUULfapRIjNtsf6W0KkY=;
        b=snYvRRd38VJ2r8sfGGINWnvQJmDWKaM/dHV84IJ7MEPUQ7/ne1fkAxP6l4ZeoNpu5g
         CqWdIYGxe3Qvh1njrXxLHgd0/w2ohtQRabFxwBskiDnLkfCqkh1e8YCRKLWeCgmiwadd
         fuLpbWthITAgPFJqY5b4l18jug9rNWhjKdkqKwUvafYaEdaOAVkVHgFEXfk/PWpjUHS3
         c4QBhx7tn3/bkAC0Z/Y3c9VNrYfEsa3bWGqfb5f1q9c8/O0OF+4F9ikTvjsad0jOijZa
         UBxh1TUdjmMvgXCDaOXPA5vhU6ycduf4ss5vHYvaxjb3k5PyiBOEV5f96njSJietGPwt
         IEHA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXz04fj20zfcSZrK60n6/3d4F1tSkNI7VVb7TdPu6P+mhBF9tqK
	0Pkfi0TPxy7lg5CDG95AY6Az19ZixNcdanMAeZuKhp4U8ZI5zqWQRGDdmi/uJfM6kF5aNHOCpOg
	u5mfDqXyx6lVTak0D2RBenIWXFDDaDTxi16iL9y0s2LCGAmfJQ4mpckx8zpKarxU=
X-Received: by 2002:a50:c212:: with SMTP id n18mr6416101edf.23.1552464237120;
        Wed, 13 Mar 2019 01:03:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw7PF78Tu76m1l/XbSdfH+3G9oSAoA/MV2cztzGiwUnwVbM7Eo5QussA+x3abL5snHNUJU
X-Received: by 2002:a50:c212:: with SMTP id n18mr6416054edf.23.1552464236377;
        Wed, 13 Mar 2019 01:03:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552464236; cv=none;
        d=google.com; s=arc-20160816;
        b=tM8z45OlznTypNywo243qMhTJC5TVQKfh7BB/YmvATCkyFU82GtZbbJa6lob1xN6RA
         nKoaRtb1GdOeqyoxBisSkOZmusapSSW6X8F4ozwC4IkUJCEoj8ehQqT7usf/J4QerMmW
         MXMzddbyvbPvz2EIWjx5gD/71MQ/AQUKuHk4qQTbLMVg6kFbPrQAEN03oiPlO29OHmaD
         f99jUDm9/WqFLV+yWXr2OV3k6Wd7TEffp1dlh0YPODy3nub0Yr2Oi6kw/WVs0/e6asA4
         vyV52aVGvR37RXIgfYyz/XmllLCQuLXMwcFf6bFcS3KqXw4D455sUtM0vLaKj+kTt6d8
         TzSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jjQc6ADiSKUgjKXfNMvuBpTkUULfapRIjNtsf6W0KkY=;
        b=nYKUmNYSYpJCpPXFI2g9/CKvmswWG/h4zrtxG2s6poJea6+dtzjBGRwcfLkwHqbRu2
         nr8YYEM/xIZZ8gvn+nQESuTh1wvyWYyREfYnm/Yedh2S+/P/3wrr0lhSwwGDKpEwTSqG
         tbM8jyUo67LcEhMubIM/O3dGxuZTub5tnbUEEDaRvyIBHv67EiRRRIGhM87dicKn9nvg
         BJzxu5hFowql0mrljkY7glKH6wkMhawm9XX2Wo291TnE9yOJIjWoZZoj4arAm7U4bYKE
         F9hRuTjfFpDtY8w/3ddFKK0V5bsyvYo+SR9nja5FrmmsGtkJILGCWz++JnsNUxzMzqFP
         K3Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o46si495135edc.36.2019.03.13.01.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 01:03:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EC868AE1B;
	Wed, 13 Mar 2019 08:03:55 +0000 (UTC)
Date: Wed, 13 Mar 2019 09:03:54 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: vmscan: drop zone id from kswapd tracepoints
Message-ID: <20190313080354.GH5721@dhcp22.suse.cz>
References: <1552451813-10833-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552451813-10833-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 12:36:53, Yafang Shao wrote:
> The zid is meaningless to the user.

This is quite bold statement. We do not know whether that is useful.
Quite likely not. I would go with

"It is not clear how is the zone id useful in kswapd tracepoints and the
id itself is not really easy to process because it depends on the
configuration (available zones). Let's drop the id for now. If somebody
really needs that information the the zone name should be used instead."

> If we really want to expose it, we'd better expose the zone type
> (i.e. ZONE_NORMAL) intead of this number.
> Per discussion with Michal, seems this zid is not so userful in kswapd
> tracepoints, so we'd better drop it to avoid making noise.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/trace/events/vmscan.h | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index a1cb913..d3f029f 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -73,7 +73,9 @@
>  		__entry->order	= order;
>  	),
>  
> -	TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
> +	TP_printk("nid=%d order=%d",
> +		__entry->nid,
> +		__entry->order)
>  );
>  
>  TRACE_EVENT(mm_vmscan_wakeup_kswapd,
> @@ -96,9 +98,8 @@
>  		__entry->gfp_flags	= gfp_flags;
>  	),
>  
> -	TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
> +	TP_printk("nid=%d order=%d gfp_flags=%s",
>  		__entry->nid,
> -		__entry->zid,
>  		__entry->order,
>  		show_gfp_flags(__entry->gfp_flags))
>  );
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

