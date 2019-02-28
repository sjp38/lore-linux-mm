Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A888DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42C1A21850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:17:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42C1A21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FF8A8E0003; Thu, 28 Feb 2019 05:17:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AF3C8E0001; Thu, 28 Feb 2019 05:17:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C6538E0003; Thu, 28 Feb 2019 05:17:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 343408E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:17:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id j5so8235980edt.17
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:17:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4C3XAH+QuDraFAsdDGUjyzEh6q8SRREFBupEwZkK1Ww=;
        b=ZwYZgNpt3XkdHshT65Zd/IAD9ZaajqVpc3AxejuPgrZPblCN+t5dvDcIGNms+rs4w1
         0sJXB21uWWSq8fvLLK6SixsnC4kBBm9spDJVqWuZQoYvlG86j8FEPkXz5RG3iY1kzrAz
         d9J21P0f+HuTMZCGswSccnWfv7sCxy3iud/Q64G0wBKkwBr3HWULyLs+YyiWNHbgIsBc
         Py7s/o9iEEhDuvk6drYyqmc8n/ZA6qrjilr6HIEzdb8PdIPx66h+TeAB1bKwfEd0hdTC
         zA0H3DVuIqr0NndP7CHHYSChNj5OaFoxn7zXfEni/MOc4VjPixAylIrFjRdEQaUyOwNw
         bRTw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ5+FHP4g0EWzgcgpHbOhf5B/TUkW5iKYsRafM+N+Kd5xduq+Hh
	lFpaA4EJc46z0NV3C8rIEcSt4NhLOaixwgTssbrgH3vt0w6CI87T+Ri8k8h+WQtUJdB37mRvf7J
	tfOuMKvAoH6cX5vaIHsPv4ntt4jft9lua8NcVON9t1KbMWwOjswfnCgqIRMs0PbU=
X-Received: by 2002:a17:906:5f99:: with SMTP id a25mr4741908eju.140.1551349053674;
        Thu, 28 Feb 2019 02:17:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZTYpr3LfI5q+R1msZ+8RaaGJbEzaoxmwAjtq1PIRsW5CcM46NfRBl0QjGzStkdxrt8mQI4
X-Received: by 2002:a17:906:5f99:: with SMTP id a25mr4741854eju.140.1551349052699;
        Thu, 28 Feb 2019 02:17:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551349052; cv=none;
        d=google.com; s=arc-20160816;
        b=mwYQye/CFI8Cejadvq2dT74qoG0nQVhYBKUpU/DczHCFEDeVnzXQ+la+Yxh2/WVE+E
         Jt7zu2AaMydE5rz3AY+etufREbROf2SMpjmReidxEyXsxDNg66FZKuVHwPhZS7ocT0dC
         6DERVczU65pymCzFL376fRfg7UbbXcoGDubevbCzU3d8oC+1A6iN98AbF58WCwaBazVV
         v5DohcM9lNeK9hgSLKUAOD2snfmEMo9yEdvWpUMX7GRzkd6Gvix9yBJqHrY1FjarlFej
         RHGDauWk5LiptkFVHwfVfi5pJKej2I8GHI72SvINLrfyrMHor2t9+Ro3VgoZYObT0ptj
         qJIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4C3XAH+QuDraFAsdDGUjyzEh6q8SRREFBupEwZkK1Ww=;
        b=lX6PZKFHeB75CP8YHvnNIyVOIMP2R8Z+lS22sp79ece79wVFKh2kj5KQG93jN6ywy6
         GcPqckTtu86GSpe/hhSQeQi5Bxs31dPKWw+DTnGeUwZ2FQDfxwTc1IrtAdL54qHAHKLo
         E83i+P43RXtaXO6fe+r6rnukmeXbYyTZg57W7bd/lSSMzcloNm9DI02959Zgj3RpPeKU
         sXlL4KMGsJgTpDkyshYNOrbjXLSLYwaGG49DCxrdKOUpjVd2BavGjTrJtTGmGIGHL5WK
         wwUBqg2J5w+pheNc6ZUFzuQ4QeWcAMT7wtqXgMrtQUxzyrZ9EKankxtY9qB16O/cHDly
         vSjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12si472174edz.345.2019.02.28.02.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 02:17:32 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AD721AD73;
	Thu, 28 Feb 2019 10:17:31 +0000 (UTC)
Date: Thu, 28 Feb 2019 11:17:30 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, ktkhai@virtuozzo.com, broonie@kernel.org,
	hannes@cmpxchg.org, linux-mm@kvack.org, shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
Message-ID: <20190228101730.GY10588@dhcp22.suse.cz>
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 16:14:24, Yafang Shao wrote:
> In the page alloc fast path, it may do node reclaim, which may cause
> latency spike.
> We should add tracepoint for this event, and also mesure the latency
> it causes.
> 
> So bellow two tracepoints are introduced,
> 	mm_vmscan_node_reclaim_begin
> 	mm_vmscan_node_reclaim_end

This makes some sense to me. Regular direct reclaim already does have
similar tracepoints. Is there any reason you haven't used
mm_vmscan_direct_reclaim_{begin,end}_template as all other direct reclaim
paths?

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                   | 13 +++++++++++-
>  2 files changed, 60 insertions(+), 1 deletion(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index a1cb913..9310d5b 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -465,6 +465,54 @@
>  		__entry->ratio,
>  		show_reclaim_flags(__entry->reclaim_flags))
>  );
> +
> +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
> +
> +	TP_PROTO(int nid, int order, int may_writepage,
> +		gfp_t gfp_flags, int zid),
> +
> +	TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
> +
> +	TP_STRUCT__entry(
> +		__field(int, nid)
> +		__field(int, order)
> +		__field(int, may_writepage)
> +		__field(gfp_t, gfp_flags)
> +		__field(int, zid)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nid = nid;
> +		__entry->order = order;
> +		__entry->may_writepage = may_writepage;
> +		__entry->gfp_flags = gfp_flags;
> +		__entry->zid = zid;
> +	),
> +
> +	TP_printk("nid=%d zid=%d order=%d may_writepage=%d gfp_flags=%s",
> +		__entry->nid,
> +		__entry->zid,
> +		__entry->order,
> +		__entry->may_writepage,
> +		show_gfp_flags(__entry->gfp_flags))
> +);
> +
> +TRACE_EVENT(mm_vmscan_node_reclaim_end,
> +
> +	TP_PROTO(int result),
> +
> +	TP_ARGS(result),
> +
> +	TP_STRUCT__entry(
> +		__field(int, result)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->result = result;
> +	),
> +
> +	TP_printk("result=%d", __entry->result)
> +);
>  #endif /* _TRACE_VMSCAN_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ac4806f..01a0401 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4240,6 +4240,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  		.may_swap = 1,
>  		.reclaim_idx = gfp_zone(gfp_mask),
>  	};
> +	int result;
> +
> +	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> +					sc.may_writepage,
> +					sc.gfp_mask,
> +					sc.reclaim_idx);
>  
>  	cond_resched();
>  	fs_reclaim_acquire(sc.gfp_mask);
> @@ -4267,7 +4273,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	current->flags &= ~PF_SWAPWRITE;
>  	memalloc_noreclaim_restore(noreclaim_flag);
>  	fs_reclaim_release(sc.gfp_mask);
> -	return sc.nr_reclaimed >= nr_pages;
> +
> +	result = sc.nr_reclaimed >= nr_pages;
> +
> +	trace_mm_vmscan_node_reclaim_end(result);
> +
> +	return result;
>  }
>  
>  int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

