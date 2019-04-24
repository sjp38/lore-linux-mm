Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F7BEC282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:28:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46EAE2183E
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:28:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gTPqPuJQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46EAE2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5C406B0005; Wed, 24 Apr 2019 15:28:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0C306B0006; Wed, 24 Apr 2019 15:28:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFB846B0007; Wed, 24 Apr 2019 15:28:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 989C66B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:28:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f7so12662064pgi.20
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:28:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hEWT6gPnYwEoKNDjpGEQFJKxFxQoG9b2gItqJSpRFRI=;
        b=PYVSnii3cs1oEcaudZTFKtsYUtGdJo+VvEnDp1Ev301ugjWQ8+wPhZS8V9nj1D/WlV
         Cx9fuCxnSPlI8P6kAppQD7LRwbpJ+U2P/KWV3zHk4n3oJofr9fjqxio+BcsHR7M5wlsF
         QJgmW8wii3RDiTdtXSSW3eiVwjVM/rN3kzbFPQJE5JjsAkMg8Yshw/U+j5PSUqGO77yI
         NltbHo9oPreV5YMcnN1JpH7//OqSzPGRfnR7AYd2JjLABGtai48Qo3abT9PqePU/naQ7
         +Lk8ASRWCtAmWP+rAzCOtVG1ZdieDfERRIjSeie5/Rizp5cthv9Wp5P6JPValRbmiIKW
         A0lQ==
X-Gm-Message-State: APjAAAW1SAzJ5Lj+cwfx7yNPHRGmOWAISY8UQM+wlQFr7kWGB+PS8qHR
	yA5TRHqzcnsZxosZVwLJGijtjrIFmgIZ2uvckKpSqsiJCMcgD4MApRQLD0B+4m0ny/PSVCG5Sr2
	vqK5x4D7TfZ9oA0r4Z1Qk5n2VWm/d3QWJyDXxkrdqFG7c7dsFTrf/tncaSXZXbSNerg==
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr31884635pgr.72.1556134094257;
        Wed, 24 Apr 2019 12:28:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxya/rab1RGKib3NvbNzSH+6KWJfFlcTgQw1XzhvlTLp/6DcZqVfU/C4Hxl5b7ayxKRotaJ
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr31884594pgr.72.1556134093589;
        Wed, 24 Apr 2019 12:28:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556134093; cv=none;
        d=google.com; s=arc-20160816;
        b=e7lAii4Gcmg+tKoyf5qLnCx/ig22AVLBbtt1BGxdh5Mbi/JMbIkEeX4BaFIV8NEQud
         M6RG0Koq/IxEtGv6QeOFXqGaHjWkxNpo0kZ4uvNGXUoz6YAuDIIVcyPl7+sSQdxnFGPs
         BaPO7kTVivPdYOBUqSVvgjbGJkVy8FX7IYj1SrF5cGH8GwjKZNgAmXeosUfFOcXjM3yZ
         /o4y13CCUcVsNNkRFtiFhWb/pYCNzbUbtC5d2mApU9gKkdd8ov4oJHntVx3nY2WQxb1H
         w9Sc6u3eYqHMoGCsK96hr18Yh8Jpv/37QjKgRQHQtKMmYeTRbr8/VGY4omPZ/PZnGAhN
         K5NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hEWT6gPnYwEoKNDjpGEQFJKxFxQoG9b2gItqJSpRFRI=;
        b=PVtPfmmnfaKRQqK83g3vb2Cs+kk16Qunh7rMZcoR+rGY228rx+P1vOtDsERSxB428W
         vETr99zvQnDd8HpxcbnOWpPc2phdZPdBRuEoDrbuw+rs3rxj1ktzbzTOhQKWAmIYOYex
         d/hoSKEnwRaMsuWSBRCCK6aKHjn8SxIoB5p7iCjaTgmcRBFz1xXoaSWGV4+TNngunPHG
         onpe+1TnnO3I4Uiz8yiWu/lHc1g6DlNlG86mI4FqxGmCvlY4UJb/myzqWqe0L09XCz1x
         Jg9JWXYln3no02J2FqBqBDaAjdLjI3eHKVyxzeRaF+iQ9l2VH6i0J4FHfw3PucnFDOjG
         z6Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gTPqPuJQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g30si3825138pgl.9.2019.04.24.12.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 12:28:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gTPqPuJQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hEWT6gPnYwEoKNDjpGEQFJKxFxQoG9b2gItqJSpRFRI=; b=gTPqPuJQaC+T3y8pejBbLw8v7
	vQRyhDc42Dm4v9Igf2CosDg9XMSe4Vupf6EGCqRRnWg0zCkfceJoNemUlXlWgVZGCjrlzbsC7A5mq
	J0KJ5AraOZaqi0lpdSinnsGv+j5fpa/rrHZWiw31Cr0yJWR69eNNa4W5BuNr6um/Jj/Kfd8HtIGfK
	lOrO5FmvHIo8Hy/QeX1IDDY1Hv8Mci/N3Dxtoo/lRZo4IddNo0lb9djQs9fhO9F3WVeXUqcA2YXQe
	oKzpAtZYJW/gdDKjUYELAZ6pVgbzlU0YCG3VcucMFdOmjv0DwnC07Ctz3xq/u/N28BIf9ZiFo4bW0
	CLJZDcLSg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJNYz-00085z-2L; Wed, 24 Apr 2019 19:28:13 +0000
Date: Wed, 24 Apr 2019 12:28:12 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Matthew Garrett <matthewgarrett@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Matthew Garrett <mjg59@google.com>
Subject: Re: [PATCH] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190424192812.GG19031@bombadil.infradead.org>
References: <20190424191440.170422-1-matthewgarrett@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424191440.170422-1-matthewgarrett@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 12:14:40PM -0700, Matthew Garrett wrote:
> Unfortunately, if an application exits uncleanly, its secrets may still be
> present in RAM. This can't be easily fixed in userland (eg, if the OOM
> killer decides to kill a process holding secrets, we're not going to be able
> to avoid that), so this patch adds a new flag to madvise() to allow userland
> to request that the kernel clear the covered pages whenever the page
> reference count hits zero. Since vm_flags is already full on 32-bit, it
> will only work on 64-bit systems.

Your request seems reasonable to me.

> +++ b/include/linux/page-flags.h
> @@ -118,6 +118,7 @@ enum pageflags {
>  	PG_reclaim,		/* To be reclaimed asap */
>  	PG_swapbacked,		/* Page is backed by RAM/swap */
>  	PG_unevictable,		/* Page is "unevictable"  */
> +	PG_wipeonrelease,

But you can't have a new PageFlag.  Can you instead zero the memory in
unmap_single_vma() where we call uprobe_munmap() and untrack_pfn() today?

