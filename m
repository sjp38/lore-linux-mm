Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0C5BC43612
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 01:57:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8956C20856
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 01:57:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8956C20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38DB08E0056; Wed,  2 Jan 2019 20:57:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33B8C8E0002; Wed,  2 Jan 2019 20:57:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22C958E0056; Wed,  2 Jan 2019 20:57:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE21F8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 20:56:59 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so38230094qkb.23
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 17:56:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=auLAF9ATH++WQpXqvP5fuSf93rvZcX7YLus5DiU7jqc=;
        b=iiQkVNSEFA1VwLU6RjAdUx49pUv7O0hXGqlh6F/rpSCTevBaCaAZG4s+d4L4BBn3oM
         TAgWeTtPHjsFzgSWn4dtL0+femZBhbCHuPWksAmbeZdowVRNZswKR4rrNP9t+Azch2J5
         Kv1IHD9nKHDyUq5fqdyeKmRpz/9y14YTnPpQpZz8iYBimhbY4Or7pQW6mi3arpFXDurf
         0Mby3tgXjfQhyGBYJRyBTju1uGxUKRJWDxE9nJSvx/f5UjCJJyOCLrbGb0PpX+JC1dpT
         bGfloMVscf6Vnjghun3z3v45mTz5I0WAY32ZxDjcKAbFTG0lSXtspaVplIaAMpOH62zG
         FFmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukf8w+Hb66ZwTf/rkgC4YpnEaGkDAWphozzL2eE1VW7Bmi3YGR2W
	SKnEOkjWYMG6ixlp32++2Gt/4+Txr8hqyhdgP43joizVj7FxDz5Y9SvcrBREoE3EniWwOG43Wgs
	nFpdMBqZYOsk87JY7EhlyDxTNKNN3wGBzpHICJZ/WFsUvufINpDmb62ssOYpdqb1teA==
X-Received: by 2002:a0c:96b5:: with SMTP id a50mr44696401qvd.33.1546480619776;
        Wed, 02 Jan 2019 17:56:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6NyGj6VAaviVgaSFGFKYrHJoOagT70BiQiSMyYn0Z2i7atZNlDyZzY3fuODNn+wolg56cL
X-Received: by 2002:a0c:96b5:: with SMTP id a50mr44696383qvd.33.1546480619343;
        Wed, 02 Jan 2019 17:56:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546480619; cv=none;
        d=google.com; s=arc-20160816;
        b=hfVYpefh9uzbqHYG4jIbLUFKSjmukQcNUWUjYA7fTV3qPY12EKY9o12P3gsFKtTtLs
         u4QQeQ7yZmkVlf7p+oed0unTi07/nRcfw95XiVdYuqpOxFZOOxUdLMdFJKMrOS84tE/E
         T7qHhw/hVmaZHrfxJ5UU3f5afe9HK674yOcdspZYdzHKeiOR9qrZkT+b6a09lp3oXikM
         t8XK+qfg/16eKhNbbxG+dvEcUCiyNpLxLyjNCz0hNFOb7M+zIq/R1C7ZmORS0AEYJL//
         qS1E09Vftov0Q9ObfdKoJYzKxGx5IvSN258U4J0e7YgxwEUdDQWXJxXSaTE2KBNRRZYC
         /caA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=auLAF9ATH++WQpXqvP5fuSf93rvZcX7YLus5DiU7jqc=;
        b=mc6J7T9clEgj8aFU33xohi21OAJtjDhA2NgHGI7wAfpV0pw6eusefspfnrvJqfwrfv
         +C3gz9TXDYi9pZUekZV4myKXLr9VcqkN378T4QLIUmdqT54JUlSp2kw9As9x5+5t3j8B
         uiJRMw8owXx1DaqcitQHm8WfxxY4G4rPQKJF1N/I4qp06JIWQimHCTCOeuMjDE5BGUmz
         ya+rZdWmxviHZvByz1EcOvVdNVgvYrxXIjHqQGmje1LI9qp+UaUuzxpGPpPTKy329k9X
         InuBPQNDpKzCtihHBn0SzB2SZTpNam23Y+aJKoHPGyDA0dgs7d5UTpJ/9i1KW71G6EUv
         qwnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s12si4626114qtn.255.2019.01.02.17.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 17:56:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8E29DC0669B0;
	Thu,  3 Jan 2019 01:56:58 +0000 (UTC)
Received: from redhat.com (ovpn-123-62.rdu2.redhat.com [10.10.123.62])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3C1595D9C9;
	Thu,  3 Jan 2019 01:56:57 +0000 (UTC)
Date: Wed, 2 Jan 2019 20:56:55 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103015654.GB15619@redhat.com>
References: <20190103002126.GM6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103002126.GM6310@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 03 Jan 2019 01:56:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103015655.k3qZ9AdWacsU6OBnxPA3Spqn8t9BSMdJX_c8sUwyg10@z>

On Wed, Jan 02, 2019 at 04:21:26PM -0800, Matthew Wilcox wrote:
> 
> One of the paths in follow_pte_pmd() initialised the mmu_notifier_range
> incorrectly.
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
> Tested-by: Dave Chinner <dchinner@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 2dd2f9ab57f4..21a650368be0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4078,8 +4078,8 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  		goto out;
>  
>  	if (range) {
> -		range->start = address & PAGE_MASK;
> -		range->end = range->start + PAGE_SIZE;
> +		mmu_notifier_range_init(range, mm, address & PAGE_MASK,
> +				     (address & PAGE_MASK) + PAGE_SIZE);
>  		mmu_notifier_invalidate_range_start(range);
>  	}
>  	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);

