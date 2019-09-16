Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3550AC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 12:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9BB4214AF
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 12:56:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="LI0rw6Yw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9BB4214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71DDF6B0005; Mon, 16 Sep 2019 08:56:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A6EA6B0006; Mon, 16 Sep 2019 08:56:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 546E16B0007; Mon, 16 Sep 2019 08:56:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4406B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 08:56:22 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B12462C3A
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 12:56:21 +0000 (UTC)
X-FDA: 75940782162.01.kitty99_548b312fd7a63
X-HE-Tag: kitty99_548b312fd7a63
X-Filterd-Recvd-Size: 5459
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com [209.85.221.66])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 12:56:20 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id l3so16043767wru.7
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:56:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6Qvf/tFB1NW9gGSqT/wR7yVJwgXaFo5u9eZ6TcvIymQ=;
        b=LI0rw6YwWN8ZIfFY1x3z7d6DQpjq1QMQHKmc7RC7CC750QO/kXXnllfg27qnoqAVwj
         eOrs7Ok0zw8+0mC4k4Jas6ArWZ1toc9mxNIsx2MGIjCIOcF6TgNm28y0xTH98tDtjPvu
         z6tuz4dguo1cVBhI1ATSthZKAKNTJDFbcS59WGmsG1v5ES0TckZ2dtl9VnI6EtbL3yL1
         nHOVapGTD/Ab1h2qi8Z5Vo6nyxPqUu++h8xLt+tZK/mdN2jQHtbw1gKF2BwoPBLN4+ey
         zop2FPw30hJ4cV7Q+Rttu+1PEwp0yQnXa9Ou3W/AI2BZ/RImBrdhOkEdR6QzE4EkXBUT
         yCRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=6Qvf/tFB1NW9gGSqT/wR7yVJwgXaFo5u9eZ6TcvIymQ=;
        b=azoOUw65tiA/iDYWx9T8EFZhLOZo51ugDzDRS3o64k7Znse7UfqOd19AmrgwQRfTKN
         MUKQUhiLklsriNLGpCdQyTfAI4reh5rgDU4cbcLADvDiP7LVHQ9JsrsN94fV84TPcytz
         ZYg2es1uvZm8Wwh+sBoqABawD3DodLe8pcolAGvwQseBL49WRhD45ih6xiUupIoCGAL/
         EZtZT/B64H3MvlAD0ykl7N4hIx2pU/LGu6TTcPKQNbd0jLqCktZnTadwpJua3N2b50xw
         iind5wkLjRIBDTHr1mBA1fSq1qadC/o+4afx6RyDsb/QErkijpT8NCWtN2DeF7hMcFWl
         cxcQ==
X-Gm-Message-State: APjAAAX5W0XpOS7W7vOFR9X8XNjKGk680Ks57in1idtLH4Mu9lnCLlW8
	TZjsrEXaJBDlGDoc1g3VslEgCg==
X-Google-Smtp-Source: APXvYqytJbglD1pOkKufvUeMbQb432tslSRsIFuH1ov//lw/rbWtIhtIllKqnrzkTkZ5UcG3DSZjlw==
X-Received: by 2002:a5d:46c4:: with SMTP id g4mr11644497wrs.189.1568638579404;
        Mon, 16 Sep 2019 05:56:19 -0700 (PDT)
Received: from localhost (p4FC6B710.dip0.t-ipconnect.de. [79.198.183.16])
        by smtp.gmail.com with ESMTPSA id q15sm11000696wmb.28.2019.09.16.05.56.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 05:56:18 -0700 (PDT)
Date: Mon, 16 Sep 2019 14:56:11 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH RFC 01/14] mm: memcg: subpage charging API
Message-ID: <20190916125611.GB29985@cmpxchg.org>
References: <20190905214553.1643060-1-guro@fb.com>
 <20190905214553.1643060-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905214553.1643060-2-guro@fb.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 02:45:45PM -0700, Roman Gushchin wrote:
> Introduce an API to charge subpage objects to the memory cgroup.
> The API will be used by the new slab memory controller. Later it
> can also be used to implement percpu memory accounting.
> In both cases, a single page can be shared between multiple cgroups
> (and in percpu case a single allocation is split over multiple pages),
> so it's not possible to use page-based accounting.
> 
> The implementation is based on percpu stocks. Memory cgroups are still
> charged in pages, and the residue is stored in perpcu stock, or on the
> memcg itself, when it's necessary to flush the stock.

Did you just implement a slab allocator for page_counter to track
memory consumed by the slab allocator?

> @@ -2500,8 +2577,9 @@ void mem_cgroup_handle_over_high(void)
>  }
>  
>  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> -		      unsigned int nr_pages)
> +		      unsigned int amount, bool subpage)
>  {
> +	unsigned int nr_pages = subpage ? ((amount >> PAGE_SHIFT) + 1) : amount;
>  	unsigned int batch = max(MEMCG_CHARGE_BATCH, nr_pages);
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	struct mem_cgroup *mem_over_limit;
> @@ -2514,7 +2592,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (mem_cgroup_is_root(memcg))
>  		return 0;
>  retry:
> -	if (consume_stock(memcg, nr_pages))
> +	if (subpage && consume_subpage_stock(memcg, amount))
> +		return 0;
> +	else if (!subpage && consume_stock(memcg, nr_pages))
>  		return 0;

The layering here isn't clean. We have an existing per-cpu cache to
batch-charge the page counter. Why does the new subpage allocator not
sit on *top* of this, instead of wedged in between?

I think what it should be is a try_charge_bytes() that simply gets one
page from try_charge() and then does its byte tracking, regardless of
how try_charge() chooses to implement its own page tracking.

That would avoid the awkward @amount + @subpage multiplexing, as well
as annotating all existing callsites of try_charge() with a
non-descript "false" parameter.

You can still reuse the stock data structures, use the lower bits of
stock->nr_bytes for a different cgroup etc., but the charge API should
really be separate.

