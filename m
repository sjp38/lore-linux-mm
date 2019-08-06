Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAEF5C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:52:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F20620880
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:52:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="q4fdESRb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F20620880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00E366B000A; Tue,  6 Aug 2019 01:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F000C6B000C; Tue,  6 Aug 2019 01:52:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC8DE6B000D; Tue,  6 Aug 2019 01:52:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A62036B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 01:52:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w12so11950912pgo.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 22:52:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iZC/LxWLoozeZ5gTwVtLdiR4/XxQSz/euJz+TZ/eCnw=;
        b=rgb9QkjR/6OH/79OqFbdlGkxZ6qC/5L0g/jk5yfothNpAZoDPs4IOR/Bc8v/uvhb8m
         aVgrm75+PGIuK8CT9rE5qBiq7Ameuufx6+8VbbB3CX2IS5aJv/OsysPUng6FjAA11gJh
         InM8E+gbZSmkjzmDWI3z7tMqUqCgVMnwy8EbrLy0fM8J7pzwiLPlVGaJ6haYbdyZNqo/
         SV9NEuXYvYuB18iCsXv1S5YZOH6dJaGOJV1QzkmYR1UDpV/y1ILXs3kn0WbNLjoGUHQG
         NZopR9hkMbgt1eqPhdKDooz1jKlplvzjVVqcsV8mXgrpeVNLCgyygwjqLW3Rdw9rzG06
         WwFA==
X-Gm-Message-State: APjAAAX8HTuuPC+jhFM8OD1XoNMs6yxZJKz+6pCNwyIKTeQC56MEzBaN
	gzX6b3kQ086HIFhobqwxsjqd56tzclhwwWgRWxPB2HPF8DfD8U5cEM/m5wXf5HVbqUuaxyUcTnH
	K1FOnFy2vqbermBHt7F/cqZv49YeeVifauS3WDxWvsrSR6bqj69j45VsenUJUIstZNw==
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr1401497plo.313.1565070771346;
        Mon, 05 Aug 2019 22:52:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXR++b2TI042vObIgsxkEXuqR4kMaMrpbKk99P6UkF/VEA4pZJubH7hlshSrzdse/eUOCN
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr1401465plo.313.1565070770736;
        Mon, 05 Aug 2019 22:52:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565070770; cv=none;
        d=google.com; s=arc-20160816;
        b=g923wvqtCyYOBFuDeIcB6ouXM7+XwhSb/O/pML0HEhzq+kTy7KDrK/xovnPrRkVNPB
         v2pS2KmlBYyXfNv4Xb2gxLXKQYP1WQ5Jn3flMRMiXnODsz4oGe+zMhhVmRiSPg9Z3rP2
         vkYyCmPJvO2eHtCgse5Ib1f1w3Ml9HjZsc+iPZQeHhCRxzQ/yNxZVZxJPCiIg7qC8EDf
         8RC3200fsSAbzd/7jCPWk9MY9Fb0f8/VYE+JKTyyHqI2eAT/FWMcx6s9YN0JtApPQ/yb
         eSdxcAprv5m7Yuu7WzQ+pdxzWDyMLc5902Z+VtF/90FiZnJC1k21Fu2hVKrJ80z+xETw
         k/xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iZC/LxWLoozeZ5gTwVtLdiR4/XxQSz/euJz+TZ/eCnw=;
        b=xWMnw9GKwmlovwBRmIsUhQx9vDoe5Vsws3hslWXZLwSRf2JtPcmGxI8fvIkcvG0lId
         MMzMoDDOUE7mFwO5cuFm4+unooyXYH04O7s9ZoX9D1GoHddRe9xlMQp60myH01L6TWxX
         ir3Rr2JKr1Q/QR0GrxieXqgw16MvMi3dNeskdaaDV5PPWEfJgAsS2j6ga6Mu+VZ7AqRM
         6+rbTP3C/1gVtflJ5wSZrtvoU/T7tqCLG6DpC4phvpqBOqF/3XXejWq4wghzBwesYFjR
         thwDqwlhyA1jlpvkoQzmgrzJqaJrBuSXMRz9EXf977ss4mSpTqAL6V1MUs6HxVLz2Ybc
         FZpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q4fdESRb;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x3si23636302plb.164.2019.08.05.22.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 22:52:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q4fdESRb;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=iZC/LxWLoozeZ5gTwVtLdiR4/XxQSz/euJz+TZ/eCnw=; b=q4fdESRb6K3x66Fw7txqEcKK5
	4KlVi6yIEoU7IvWdoy9lZ6LSDjSRpCegCickw8Trb/Haj10d8zo2wciqzZ6s9G9DczOJhnIObH/TH
	wYOxI58cGZXCii9uduwIFPZDFo8r61nR9BiczF4vm13RE9hiAGOE3MeK4LGa/WwEABECUcOtqpsEu
	s6kYqRzozSPGGJ5z50LuBMxFjeW5CrWOidhdOTTy4QCimsu6DoRb/mi/rPSeo6rZxITF9BYMzS04c
	NNHfGBn8IsfKmDXkiArhcjJW2V7TIY5fOvthXcFsyOwVVYRcMF2SlByBldUA+uRdrNKtjz7gZdhby
	Stz3sgd0w==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1husOv-00085U-Uz; Tue, 06 Aug 2019 05:52:49 +0000
Date: Mon, 5 Aug 2019 22:52:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 12/24] xfs: correctly acount for reclaimable slabs
Message-ID: <20190806055249.GB25736@infradead.org>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-13-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-13-david@fromorbit.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:40PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The XFS inode item slab actually reclaimed by inode shrinker
> callbacks from the memory reclaim subsystem. These should be marked
> as reclaimable so the mm subsystem has the full picture of how much
> memory it can actually reclaim from the XFS slab caches.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

Btw, I wonder if we should just kill off our KM_ZONE_* defined.  They
just make it a little harder to figure out what is actually going on
without a real benefit.

