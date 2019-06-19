Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78D62C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:18:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2889F208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:18:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2889F208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9532C6B0003; Wed, 19 Jun 2019 01:18:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 903388E0002; Wed, 19 Jun 2019 01:18:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 819218E0001; Wed, 19 Jun 2019 01:18:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3786A6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:18:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so24469904eda.3
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:18:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9vipYaSJ6BMz6gquEUlu3+yR5KbrxPlIt7hKWE2cUQ4=;
        b=PhCKAyZIx9sxuzhjdVffnzG8vG2g7UIqqfNKS+ZgW/5P097BDUrdO9m64fsHX9m+RI
         YP1Q6uRIz8zHRgVrDAiueAYDcC9sfTzCz0mlK2gTl7M+dpbqRdXK7lajTl/Yfg9KFt1H
         FLFWv6JVKg6jxU86uYFaHDoG1S8mrjep8KzUXsZZaMPEk9NClDdnasvgbtqtto8rcf6v
         89lfNfGDocsiZpeelKfduTRfIdHVIR81o96Ucz83w5bK3E4bQgo0mDsUxVDAtZayGSz3
         qoC/v7KyiwTvRY9FEpcIKBeqNtiKTCv0vbJ5kR7sxvyb6Ju4tZPAnjvSJ3wosyDGDPtZ
         +UxA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUsNGv3nVmJnbf3HF4/Ej4VJNQ9SajMhqvQVetYtB6jmcoB+KA8
	BSEBhuMX4GwSVLWqMCpaUqPbaw/M7L+PH/CXV30WfDeliNXkb0DoE0e01ltEdvrKsnjY3gHQGHR
	uqcss+0OZusvJ4ZRpeFE5vmzra8+Q9iJBmTXVa3mrbzwaEyUvitvBvFgscvebzt0=
X-Received: by 2002:a17:906:8603:: with SMTP id o3mr16355570ejx.162.1560921489802;
        Tue, 18 Jun 2019 22:18:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMl2gQ9H38qOLkVOIub19YUP/5ciKaFFOwiZQKWoPx547/tvDEEkR0DWFFEiQhhB0iD/lV
X-Received: by 2002:a17:906:8603:: with SMTP id o3mr16355537ejx.162.1560921489055;
        Tue, 18 Jun 2019 22:18:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560921489; cv=none;
        d=google.com; s=arc-20160816;
        b=xkhUGGAXyFLWIFtBTKTw6i+nmcc1agnZlBtVlLaR4y4cLtXxL1qDVl8ct9OVc3hSa+
         TSrDEja7bfoQGLamlPocDH18HUK3WDKrux4v4bJOcrAy46ukI6cITNcA4fozDi4+1NTw
         1v23ljUQSRlkyzuo/IX2K7H7xze60JR/QtftRse70mpENKWmIoA8KxY0MSzcaUwezHQR
         skrbthOLZMoWyM+zJFGj++T8Olc+GMRpYdruBtDp9FwIDNr6UK4Xzw2QnE3TMB6R293b
         peGvQjH3T4hgzP3Y2unHK1z0OOJkTYA/b4Br6IyU768J4CZX8hShsqyUd4DjlOW9b3XG
         yg0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9vipYaSJ6BMz6gquEUlu3+yR5KbrxPlIt7hKWE2cUQ4=;
        b=0So/gnnN9LePK0EpfxbOoPxJoJTncjXOSOkZdebs5kHQZwilAhfM4AFxwYSWEKWdhd
         3fqgFzQsDNp27dI6W3LeCGA1dHoaDV3NoX1cxYpiGCdSp8wllazze6jGM6yJIzWE228t
         p1vxdzXVKzpzCozrjAJWApPXE3SaV7VZnoxu9UtGVMDa2me+dpt5XvTrnktOjv69yIdO
         q4dOKwd4AqsPJkK9KYE8wpx0BF520sg4eWYrrioPUt0QX26zsMgQehV2nDOFpQBwJywW
         Ox3KiIsS3rVe9gIAg1BoO38jk4pMjfgniJcl2o15kk9JLN5UcVseZKtj6qybShT1dkr+
         Hu0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n12si10196500ejr.105.2019.06.18.22.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 22:18:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80758ADF7;
	Wed, 19 Jun 2019 05:18:08 +0000 (UTC)
Date: Wed, 19 Jun 2019 07:18:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/1] fork,memcg: alloc_thread_stack_node needs to set
 tsk->stack
Message-ID: <20190619051805.GA2968@dhcp22.suse.cz>
References: <20190619011450.28048-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619011450.28048-1-aarcange@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 21:14:50, Andrea Arcangeli wrote:
> Commit 5eed6f1dff87bfb5e545935def3843edf42800f2 corrected two
> instances, but there was a third instance of this bug.

Sigh. I should have noticed when reviewing the above. My bad.

> Without setting tsk->stack, if memcg_charge_kernel_stack fails, it'll
> execute free_thread_stack() on a dangling pointer.
> 
> Enterprise kernels are compiled with VMAP_STACK=y so this isn't
> critical, but custom VMAP_STACK=n builds should have some performance
> advantage, with the drawback of risking to fail fork because
> compaction didn't succeed. So as long as VMAP_STACK=n is a supported
> option it's worth fixing it upstream.
> 
> Fixes: 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

I have double checked now and it seems we have covered all the cases
finally.

Thanks!
> ---
>  kernel/fork.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d6c324b1b29e..9ee28dfe7c21 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -248,7 +248,11 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
>  					     THREAD_SIZE_ORDER);
>  
> -	return page ? page_address(page) : NULL;
> +	if (likely(page)) {
> +		tsk->stack = page_address(page);
> +		return tsk->stack;
> +	}
> +	return NULL;
>  #endif
>  }
>  

-- 
Michal Hocko
SUSE Labs

