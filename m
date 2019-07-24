Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C6CCC76194
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:38:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1C4B229ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:38:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RULrgcX4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1C4B229ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792988E0003; Tue, 23 Jul 2019 21:38:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 742F38E0002; Tue, 23 Jul 2019 21:38:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 631CD8E0003; Tue, 23 Jul 2019 21:38:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7878E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:38:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so23093931plf.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:38:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AFwPz9F7BR2KO7EHQe4D2tuUr0dHyiHUKqAqUScb/5k=;
        b=FNWdX88LGdtBL+CaVqVvqrVerZ8cJXmbAo53FNieZJWMIGaKYz7WU9Pf3DqL63fmWR
         USGwntbp3wKdrBm1ycYeLcQnsC6BL5ngEIpZZDLlrx09Isg1kJBSTyy+1JgxgaycwA2h
         4CWlUX4feRwArJ/zC7fTt45n301NBcW87KEa/3xA5Zc1xmtMiDU23z7zXIXRPLTcRFkD
         T7/inVb+BmbBKnlQ0iZ8LrF1vClKEPgQ5RkzzGiXVj+aEzuE54sFHD08d7+w/lwe8YUC
         moLW1C/xu+LXN00+wmeOWlZA90cTJg+pKnsvsM4EFZb1xf7jWUiEN0i3WZZRvLCyGiGq
         qdiA==
X-Gm-Message-State: APjAAAXuvaswN5rIi3lvT+rXhMZH6HS7VkQ0/59LUxpBaYiwdTv7zLAy
	08REjnv2wKDgqyXQbOEpI9tTyCAcRJLOF1GVBau0A1hk5H3IlNeTbKf6xJbj3nxDwif1OmKe6+R
	s9XN72LbRK7WIsLR1+psCpRjwWJ6VxcPDHEW2jvNCA240zDNqtAIjiv5K+jvtXmFfAQ==
X-Received: by 2002:a17:902:4aa3:: with SMTP id x32mr79792404pld.119.1563932324849;
        Tue, 23 Jul 2019 18:38:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnqLaXU8WO00v3EzmI1tvoTvx1WZdtyV00Ph7kXRU+G9ms+fvFsxmEvjwF/ZUVq2HSRKqQ
X-Received: by 2002:a17:902:4aa3:: with SMTP id x32mr79792359pld.119.1563932324152;
        Tue, 23 Jul 2019 18:38:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563932324; cv=none;
        d=google.com; s=arc-20160816;
        b=vMNEVQrtFrTOZeXdEWEUWLANEK8kTQ9YGv7xfL96Au7X+9Q7wGqKlIgFG+x+0LC+fJ
         h9W9W3ZEv4A+mZQoY91i4YfykWlE8ys43c5E4b7LmzeKtxlvx9mql+LqgJRjNm50s3aj
         sEOUrm46yuUV5Tg+Zxc6YNc5jy+2ns6UqvkPfDhKES/JdFSbQWAapH0OZxSu59HWNQbk
         4Td7Jrcf5us1dHhS+xXkuYZC7sKf0yHix+U1YjuYaK7hV3zJJzBvfE/sQR5eUENuQ3g7
         CFwwQgdSfxGKj3mrtkfMBSIo4/+BBDIkr6kUXtVbsuvnpD5SYwfMgvl4i7MIdcjxwFnX
         bcsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AFwPz9F7BR2KO7EHQe4D2tuUr0dHyiHUKqAqUScb/5k=;
        b=cinj0IHnKZkiv89B3WvVyAhF7RWUfZCbjK/gDvUZEtvHv0yX6nqjI7frWMQMbQ72w/
         YW3q4VPsiOhEeiay0MGyTONRlcYMoOU5Ybe2HVmMaBkSqffR6+cPSkN18fyLPIkT+Fxk
         5WK0Sb9Tw0DTD+igzv9fHXwRwQslX0ItadDrCpcEdQ4pH4NejW/Nx0XGns1iewW0C9JJ
         SbWQY/U5vnR3Priea2yIiHOFXuHe05u/41vMsdMte4CN6mplodwMR/mPDCj2xcTY/5Xz
         Nl16+ae23a8TCrXWweeSkcT69C//VQaSvypjYtnwtyfykEODbRmrNd8KX28SXuj6ROBz
         XUvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RULrgcX4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t185si12549441pgd.596.2019.07.23.18.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 18:38:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RULrgcX4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=AFwPz9F7BR2KO7EHQe4D2tuUr0dHyiHUKqAqUScb/5k=; b=RULrgcX43IxPsdqZAr6lzCNtc
	zncXOGdm5at73wpugQrjVm/0D5jAFMwnWKMKvNEA4wlnwbE6pgoawegICLrGsEQBv3zxPp/3b/kuy
	irE/ozw1NZOQwzdR1gpTm0V1AtY6m0TW83pVr89t+9aWKmjX7SJCi7nfKmLroTQsKWOB+LVwEItZC
	qlFd1a/r5p9/fZ+bovKzNcmCrBIXwIgFiTVdaetrzDdeLU1VPV7tJXwY4XA7Gr5jj19De7QnjImV2
	+emEkD2xFmY7RB4rzv8jQmLp24bAE5Y8MPNZ8EYASJsS1q40hA7KT+nJarwSVQNPfOCF6U0kNje1W
	SSuCf5tTg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hq6Eq-0008Ul-UO; Wed, 24 Jul 2019 01:38:40 +0000
Date: Tue, 23 Jul 2019 18:38:40 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jane Chu <jane.chu@oracle.com>
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH] mm/memory-failure: Poison read receives SIGKILL instead
 of SIGBUS if mmaped more than once
Message-ID: <20190724013840.GS363@bombadil.infradead.org>
References: <1563925110-19359-1-git-send-email-jane.chu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563925110-19359-1-git-send-email-jane.chu@oracle.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 05:38:30PM -0600, Jane Chu wrote:
> @@ -331,16 +330,21 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
>  		tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
>  
>  	/*
> -	 * In theory we don't have to kill when the page was
> -	 * munmaped. But it could be also a mremap. Since that's
> -	 * likely very rare kill anyways just out of paranoia, but use
> -	 * a SIGKILL because the error is not contained anymore.
> +	 * Indeed a page could be mmapped N times within a process. And it's possible

You should run this patch through checkpatch.pl so I don't have to tell
you whats wrong with the trivial aspects of it ;-)

