Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F08B7C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:16:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B46EE20665
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:16:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C1DulZkK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B46EE20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A3BA8E0006; Thu,  1 Aug 2019 04:16:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32DF08E0001; Thu,  1 Aug 2019 04:16:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CEB68E0006; Thu,  1 Aug 2019 04:16:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0BB18E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:16:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so45117486pfo.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:16:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=K+R31uQAYJxVzLY0NV2lfQguJWjRp7kXscTfedazeQE=;
        b=S+PeVIa4UGuEwQmE/mo5nzx6yT9pCiXEedXmV/yNqdCbPzr6FhhcoVs07kdjbvdgLd
         v3QmbuqZhN8+BP59E7mT85AwKWy6t1FUTg/FTnRyESJc83f84sylQs2Lai8vKUcAnnGJ
         hu8f4ti3w70I8EFidphfsOU2Nwf4kKLNf/7ron36JyYkImgThTOU2htBVr09Fug+WI9u
         DlLTf+roMTrxmZ2InS58nvhWvYof53gI0nPhe2Ypu0AO+qaM0D7kUNkhMJf22eQVGjeA
         rYkS+J4KEnNOuLFisbK2E/ps6WO5QoNtU2UdP8eM/cKNdpJZVhq4E9rzhuSWPg4Q/7p5
         igtw==
X-Gm-Message-State: APjAAAU8FahzwiwAF3tG0UeaPT86IWnwP8TJHbaYV3+6sOgdGXA72e3z
	o/liY5pB129rKI68CA7IUbdwYb7yMXsBBC78XoG5qyuyYXIAXd1XOAvW9HY/qdQFuhSj1f1AqGC
	KZ0xS++YW7m82vM+4zQeyNLlV4YLiy6wvvTQ2Iv3iEqcfhpGM0StQzLgIpuDTtzl9CQ==
X-Received: by 2002:a63:5f95:: with SMTP id t143mr57433895pgb.304.1564647365304;
        Thu, 01 Aug 2019 01:16:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyShnZ0GwRTdgozzKGxvU//M3JNNKAZFww9gPSABXcKu5Nw+8Dl+em8snw/UQcXMtHyslaM
X-Received: by 2002:a63:5f95:: with SMTP id t143mr57433851pgb.304.1564647364617;
        Thu, 01 Aug 2019 01:16:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564647364; cv=none;
        d=google.com; s=arc-20160816;
        b=T9SRhkPrHuFn8Sy9klnydzPAwC8U7KSZrwzXREo+BAITcesBbOo+Yj8QBhvX73g/6W
         7J/AOmGC+DmtzeKyufU70dBZ0/9DO8VHoxEyCvnj/QYSQLiTI7+ZJX3rFK5Z4FWnGl0F
         Z/xEgOtQ13rYNqd0VQiga3K3Qrv3x/lLEm2WyZJ9c/ittgVpM/8cVMIpJSkZK35EWpq1
         y8wBcWdnc23j98pFDNjYiyj8p4P+gvjWi1CIddWvpgmt7Vq590vutfxUh5TiU0IMZlD7
         UmCII13IUIA6ynmoeg8Zfp++UVxK3O/CyGNwfFwUS5I1U1Bh+bad+SVSUe6dzLZhE1ot
         SZjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=K+R31uQAYJxVzLY0NV2lfQguJWjRp7kXscTfedazeQE=;
        b=cwzAwJkYcGUNcnqWpQ6qZSpbQTI+e+j2izUMnlvIlIwMPtPNm54lUo6BdaeG3zqi6x
         bl2OByNxbDQZrdgm7JPuy0gcwL2zmh9kw6bHnHIi7OPJY88gH3S2ZTFIWF38LQTiaHqC
         wvbXb2BS4JMi0utUlPrj47PWczoUvFII3TKN8c1C/28CkeArL4cdNA+cW89W0v4cvC7C
         He+J8j2M0GBULOdEuhAxspZytL9i43u3X7IDAdi7HkhjmhUBCoVeJzNtr0JXuVSnfaa3
         RLN/BLyM7wygkz/xv1o6KwYTAlrSvsAjaKQtBS4UO97NMYIKmAkdPSf00VrLmmu5n2SQ
         YU9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C1DulZkK;
       spf=pass (google.com: best guess record for domain of batv+f91b4cf709acd1b15965+5821+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f91b4cf709acd1b15965+5821+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id cl14si6238605plb.341.2019.08.01.01.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 01:16:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f91b4cf709acd1b15965+5821+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C1DulZkK;
       spf=pass (google.com: best guess record for domain of batv+f91b4cf709acd1b15965+5821+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f91b4cf709acd1b15965+5821+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=K+R31uQAYJxVzLY0NV2lfQguJWjRp7kXscTfedazeQE=; b=C1DulZkKdXZyhRXjAkV96vjDd
	k4fzHk6RD6Vq2mgb1I/HdfGKnnUP/1Bb20dVqsxjZpx2LkuN3GUqikSuzxznPdrdGUj3WzVGIn7wv
	hVxKkmbIDTIZcD6IYvbOsOkS5uO9/xbJXAlLkJBQsJxEUkv4ZP2sYREiYdK27fuujk6b8cza33Hci
	HJsVwY7lM87oOGPucyyFWLk0ZyO160eqTvURjI7PwB7fA1yJ/hvLVB1SAuS9PiGeGl5gpmOgDe7Xp
	WHT8/6DDs7s1nY4aQ7Bvx1ORWYBl4/mU3ZdDFJesinhVaidQKyy1wMGkxbqR8Xg5CLbDSSF7lgyTo
	a6yhXve7w==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1ht6Fn-0006B9-Qg; Thu, 01 Aug 2019 08:16:03 +0000
Date: Thu, 1 Aug 2019 01:16:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 11/24] xfs:: account for memory freed from metadata
 buffers
Message-ID: <20190801081603.GA10600@infradead.org>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-12-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-12-david@fromorbit.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +
> +		/*
> +		 * Account for the buffer memory freed here so memory reclaim
> +		 * sees this and not just the xfs_buf slab entry being freed.
> +		 */
> +		if (current->reclaim_state)
> +			current->reclaim_state->reclaimed_pages += bp->b_page_count;
> +

I think this wants a mm-layer helper ala:

static inline void shrinker_mark_pages_reclaimed(unsigned long nr_pages)
{
	if (current->reclaim_state)
		current->reclaim_state->reclaimed_pages += nr_pages;
}

plus good documentation on when to use it.

