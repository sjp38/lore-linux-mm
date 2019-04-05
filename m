Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 456D9C10F0F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:24:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 034272184B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:24:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AIPKY/Ea"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 034272184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83D236B0269; Thu,  4 Apr 2019 23:24:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C5776B026A; Thu,  4 Apr 2019 23:24:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63EC56B026B; Thu,  4 Apr 2019 23:24:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29D6C6B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 23:24:17 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j1so3202801pll.13
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 20:24:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sEHuoVGsEvBgCKf3iCMGNhptzBAFaANekywuYd6WFbI=;
        b=AxxEFoZQEVgVBoUptmJdcmkvLhyOafrGCq8uHbkvkCO30uAf5CCJ6XHMNKnLosVw/Z
         QMw6i5UAKOmXFzR5Jk7AkZlHcfTPy2j5mF1/Am7qd24Z99XzTkNN9TS2V2RdP93t8RRb
         J0uoDySdti6jp4bC/7fIZbyhZtU/nMenqfzwOx1i+KczeiHYlcNHVgqQm1Izt+2EWJ85
         ymPRnspqOJPzgBIKoXrrU7sVMW3AQJBs61JtqcUWoTm3Drk0oHHe2a0njAUN9nSFq8qc
         x4AaBZIvyRwftOiygsfb0uAD2dnEESoNf/htsbco1O6sEzPG2BMjeFwQS8XukWfWMPMF
         FetA==
X-Gm-Message-State: APjAAAXe6scNRLvZsOmniq7KrYlRaLU4GdZlDhF2t+J47sW80jmKw8ho
	gkIsGCJPUXe8JUcxbmfXQZhFcqNWOcFgkCoUIj5M+Qsq+A9+f2hQiQL61QqkvhMlAxpo+SeXs2H
	iUEcMf15mEfyemhK4MgdSyfYeJfC8oR5/Y96pslJU7Cvl06aIu2Qc7JCf8EcpiIK+fg==
X-Received: by 2002:a63:4620:: with SMTP id t32mr9444544pga.363.1554434656614;
        Thu, 04 Apr 2019 20:24:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFPGNkUXQBQsYreadVBTS+fuGJD6jJ63D/ziwWiEeGV8Iv/MmRTFDoAsmSb0jeOaT8RP4v
X-Received: by 2002:a63:4620:: with SMTP id t32mr9444516pga.363.1554434655953;
        Thu, 04 Apr 2019 20:24:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554434655; cv=none;
        d=google.com; s=arc-20160816;
        b=Bof6oKwn7YDcPNXqOYcIXWgR1k70u6ZbCYiLMQWqq6kOaa8D+LLv38d8iqPYV+6eYS
         7OxYZ7fjDcy+bO+W5VHJSShlIbdndrYuEz14EjfSDpSAi7AbAmxc1Rso0wfvMVLrQpLg
         fwbgLP7LsNMKcZ/yY5S5JcjmiwC9YE4h21d8TPnS6u9PjD6qvC/VRjmcmtt4DkcRauaV
         lqB1+ScALsQNMWv+/dwf0ch0OYc6y7yaQPQnQW3P1p7G0Z+0rImWDG1YtFRlY7A2rhWX
         0n83nyqYVNxLvnYLQbym4RY3lTTiV/c7C4PvIPR7pSvXGP1HZPiRKBCvS+73ejZKtpQg
         kdww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sEHuoVGsEvBgCKf3iCMGNhptzBAFaANekywuYd6WFbI=;
        b=ev+kP4pM9uKsTqzdvZS4qhPCqQeARMPP3+xtJJWEs+uqleAZBajISRnWHQZ01gEznA
         PXnG8/+upEzTuhnm9EnkKOAT0/MUuw7IkVsoEuMiV787baYz172YeIx5rMksUXU3kn4F
         mwKYaulz04WL160DKWslnjP+YBIBk2efJRikcpBWFfTZGXd3ccFmtDXxYcMpVTiqAPv8
         82URAS5dOg/GEPqn4YcscH+r4bcR1b6zUjxqlqD4ICqiwLjUetupm8Ov3RYDvVfWSugF
         i7nW08lHY31I005co41cmnhZlp6B7CBO1CA7TLP0biaOBXUqKwkyatGk6k93pbm22z/p
         DHSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="AIPKY/Ea";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b12si17763211pgl.264.2019.04.04.20.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 20:24:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="AIPKY/Ea";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sEHuoVGsEvBgCKf3iCMGNhptzBAFaANekywuYd6WFbI=; b=AIPKY/Eal8reuHPR1gc5rhUoT
	ltk009Kz0TZx1LBUCtppHmZe6Mq4dSq2wMeY02cN/dFvpfKXLgjzUDaKZWM8WCOtI0/0Tt/Kxe6Rg
	wVEJWnkphRptqhtc4qNsCGJafutuHvzNAG7rUyZ7zWTr5Xd7s1RW/K91SsIY2MrmCtG8JILnUON8e
	4zjCouXFTRNE8eHDC/fhlrLFqQQa4wULOI84WQMOaAz475sgK4/hsG/yA97/oaEy5LQwwMPsRVmDA
	9qZiHAwmVUspcV4A/FV7fPoGMhtaEmnBOwaZr2tJYsFNH0qkdUwe40ZgRj2TwqfVAaTqUiHhssonl
	3gPH1peYg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hCFST-0002pE-Jf; Fri, 05 Apr 2019 03:24:01 +0000
Date: Thu, 4 Apr 2019 20:24:01 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm:workingset use real time to judge activity of the
 file page
Message-ID: <20190405032401.GN22763@bombadil.infradead.org>
References: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 11:30:17AM +0800, Zhaoyang Huang wrote:
> +++ b/mm/workingset.c
> @@ -159,7 +159,7 @@
>  			 NODES_SHIFT +	\
>  			 MEM_CGROUP_ID_SHIFT)
>  #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
> -
> +#define EVICTION_JIFFIES (BITS_PER_LONG >> 3)
>  /*
>   * Eviction timestamps need to be able to cover the full range of
>   * actionable refaults. However, bits are tight in the radix tree
> @@ -175,18 +175,22 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  	eviction >>= bucket_order;
>  	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>  	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
> +	eviction = (eviction << EVICTION_JIFFIES) | (jiffies >> EVICTION_JIFFIES);
>  	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);

... this isn't against current, or even 5.0.

>  	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
> +	entry >>= EVICTION_JIFFIES;
> +	prev_jiff = (entry & ((1UL << EVICTION_JIFFIES) - 1)) << EVICTION_JIFFIES;

These two lines are in the wrong order.  So you're getting (effectively) a
random answer in your 'prev_jiff', which means your testing isn't thorough
enough.  I suspect you're only testing cases you're expecting to improve,
and you aren't testing to make sure that other cases don't regress.

