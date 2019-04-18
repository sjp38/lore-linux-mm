Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35E8DC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:38:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF98520652
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:38:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="X8JPWrXu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF98520652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E4396B0006; Thu, 18 Apr 2019 09:38:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 793DF6B0008; Thu, 18 Apr 2019 09:38:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 682986B000A; Thu, 18 Apr 2019 09:38:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 495F16B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:38:45 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d8so1717459qkk.17
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:38:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=YooluqR2zLnyx9kIzkVplFE7uY5Qn68HU3DwywbdkkE=;
        b=mMP8nnu9cwhJ6iOpSABwrB4FOpvpl0dxWMNia+XySWvdhN3LV8OsHkAxGMXbhJzYiE
         0U3bIdv27J1kVLc79O0GtrdHeBVjn0Ljd5TgzQbkUxu4vw8ORPpcE/vGbrbq8vTmXIm5
         G0fJzoeeR28W1jICjY1xpABA1paeBJ655BAaS1L3T9E4QKERJ6Zo+mXNRM1oCHxh9eBk
         LI7FvoJ2GTEQwOHyV+Jym28ic0TqoZyDNtQJgvCVaG5rLLDU5e9BAUT6q/pJZYcJlVwO
         pXXJXEgtKbAICj0J89lmOMTdJzMSgFat+IyhAqz267/trHZYh1bQtMz9NO/Eg9f4xhOw
         OScA==
X-Gm-Message-State: APjAAAXss4FPc2xByUQVp1w6SqZ1UXeLqJuVNBlGfV8XhC6RXeab6CmV
	KtI/PcQGhRClf+N+jvyhtUmmsziK4Tfw/wM2PMILMTusj9I1S5cm5so/xhHXbWZnOANMWrGprQV
	S82nk+9gxJQAS9S/vKJI5oAdJozgjI2lENQrhDHVMZmV0zzzFVLEleScsE7xIbgg=
X-Received: by 2002:ac8:36c9:: with SMTP id b9mr75147427qtc.281.1555594725080;
        Thu, 18 Apr 2019 06:38:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0+dDDCqps/oy6Ynamfluu6oJrErme4EqSaSGMn/sDjzQeqyPGovix6ePsffMKKufRFjOb
X-Received: by 2002:ac8:36c9:: with SMTP id b9mr75147393qtc.281.1555594724622;
        Thu, 18 Apr 2019 06:38:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555594724; cv=none;
        d=google.com; s=arc-20160816;
        b=rA5+HOmwM1rpIZGm2OohVa6L3h6YmKvv6T1KmbxHJsbWXiEg4fV6KnPhzL1FpsYW4X
         Jno+jjUS1kdz4NHGafUJXKJLRvs4rejuYg5UBKDDUZ+iXDlgJYoneUBpQwRlP/YR9Sw/
         342FAYv6swjMjTGftBI8BXAO9JeKAKp0JzO46h9pSMEXbKJ92o9idO0PmQ8QK3KnhGGM
         KmYZx+j5RikaL4ZUfKyDRQ17lcJOkwvx7icmoeIOe02Viy1ZBRH0OY2HsEYtXMjBJSW0
         bOv66VuV0OuNjwEE1lTDF9ordyTGRQ3Mjx2EsRbbkwg0PWloL/cVE52p9BstIszulNJF
         2YBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=YooluqR2zLnyx9kIzkVplFE7uY5Qn68HU3DwywbdkkE=;
        b=0qbf9NNqpynBeXLX5unDRdjw6ZFLM2RXi6XEts4Kl3LWyjEaoOSqOOlVjcbDSiWMtL
         Qcu6+vXYJd+WIINLzIS4O7TGxuGVne6KmabAgKsnOJOiecnjZ10ZpJYKKa2/WzX3Ao1l
         u658h2GDkA/OS0d6qQ8HjEOS1BZZeJdlZgGMlo1psUuTugMcIfsCwYX0ucyJlQ8j7ewp
         rDUerOSCtkVobPBg1pCvpaA58nc8mGsIXPKwAvXrUDym4apeDVdpdtLiDxgkdJLrlVAE
         bEo5VY+sUnPybI8viUSgycxsuMH7Vj/mmT294iGhio5aZt1mQN4elf3m9QuwIYuda7vj
         E9ZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=X8JPWrXu;
       spf=pass (google.com: domain of 0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id n54si1383667qtf.156.2019.04.18.06.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 06:38:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=X8JPWrXu;
       spf=pass (google.com: domain of 0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1555594724;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=Mn2jJaVyXnfxUugHqDabQsqBL//yamSkxsI3eXyDlrA=;
	b=X8JPWrXuwI/DmpMMQRAri2xJUwQ0i7jWaes61IDWWWuJLbXYDrbCni8Zo0sXjXuW
	yuEhkjEnFwk2btLft+ero1yzF/zwR+mKYyrtIAMwHcfTE867Fpu+T5ENro+L+x0VPM8
	HiGNCzzwCW0kHJo5F8RXhjgVSKoGCFVBJ3UtdK4A=
Date: Thu, 18 Apr 2019 13:38:44 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Roman Gushchin <guroan@gmail.com>
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, kernel-team@fb.com, 
    Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
    Rik van Riel <riel@surriel.com>, david@fromorbit.com, 
    Pekka Enberg <penberg@kernel.org>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, 
    Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle
 management
In-Reply-To: <20190417215434.25897-5-guro@fb.com>
Message-ID: <0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@email.amazonses.com>
References: <20190417215434.25897-1-guro@fb.com> <20190417215434.25897-5-guro@fb.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.18-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019, Roman Gushchin wrote:

>  static __always_inline int memcg_charge_slab(struct page *page,
>  					     gfp_t gfp, int order,
>  					     struct kmem_cache *s)
>  {
> -	if (is_root_cache(s))
> +	int idx = (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> +		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> +	struct mem_cgroup *memcg;
> +	struct lruvec *lruvec;
> +	int ret;
> +
> +	if (is_root_cache(s)) {
> +		mod_node_page_state(page_pgdat(page), idx, 1 << order);

Hmmm... This is functionality that is not memcg specific being moved into
a memcg function??? Maybe rename the function to indicate that it is not
memcg specific and add the proper #ifdefs?

>  static __always_inline void memcg_uncharge_slab(struct page *page, int order,
>  						struct kmem_cache *s)
>  {
> -	memcg_kmem_uncharge(page, order);
> +	int idx = (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> +		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> +	struct mem_cgroup *memcg;
> +	struct lruvec *lruvec;
> +
> +	if (is_root_cache(s)) {
> +		mod_node_page_state(page_pgdat(page), idx, -(1 << order));
> +		return;
> +	}

And again.

