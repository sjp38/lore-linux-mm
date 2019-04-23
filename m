Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62E60C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:52:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20067214AE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:52:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kgA5DLjm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20067214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B27266B000A; Tue, 23 Apr 2019 04:52:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAB6C6B000C; Tue, 23 Apr 2019 04:52:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94F306B000D; Tue, 23 Apr 2019 04:52:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52BC26B000A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:52:54 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q18so9954684pll.16
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:52:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=l21441oHLnK9oVeQ4gnC65uBIN32WtWZE/gHPIisLWw=;
        b=KkY+pYRKs3gDSO05XjkDDohi7VAH3tK21SXrGv5Cd/Vn/bSHyxHYXa+Hnv9sKFfife
         iARPa++l42tZl6YlLqialNVXA+hhGZJQcLh2+wuvcN21XPctQrAM3JKDILTmot1ssvXl
         G5n19cUe19A2gwVms1Y5Kojf1uB2eUWLWjcq2kiJ7nWyV+pRVz1OTkdEILmVWSLG8H12
         sAkMFsPsNp5vvnRDY78jtjQF44kruzNJLxU0m6eSbh6N4ps2QzgU10NGf83WWW3CHdlV
         KXuLidt4gWOmDdKlTPUy8NCDwfuOQqI51xNIJUZj/qh5TrEoRC9eBXHjsk8VH/Oqi2cn
         loSA==
X-Gm-Message-State: APjAAAXBZaH7sHJ80/sMHaFzgOe2WoUbaq44pU+ULpZrURf2pF+ZBxp1
	M/cS9XCkdX+SpWgAi/XH9sP4n57k9s9ailcyJXip2VebYy6gDoj+T03ffi5QbwkSr1Rg6YuEhrY
	61XPK8GvT0Q2Z8n5ZujFT2g3K2YqNrm9ffsrYOXZkrOHxFc5qgN6y+C5SDSvCu/FiLQ==
X-Received: by 2002:a63:700f:: with SMTP id l15mr23991253pgc.3.1556009573460;
        Tue, 23 Apr 2019 01:52:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwG0KkFtn9afRMq/GCE1FcOX5ODDqrlZ1w2Nnqd/Q3jkLxl59I+in7JTbRXTgs4Kqg5Tpv5
X-Received: by 2002:a63:700f:: with SMTP id l15mr23991216pgc.3.1556009572764;
        Tue, 23 Apr 2019 01:52:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556009572; cv=none;
        d=google.com; s=arc-20160816;
        b=Qsf9QTri+pfYNeC/U2H9fZZlRmhgqdtXEudICoGgXpB6Bx7uY6ootF7Zyz3n7RpyYo
         4zYp01w31Jt8/8j6X6Sz7Ei3qj+GRDkJnqweD1sgp+M89tm15ZJQ+ZiT9slcrtSRh5qz
         g3BOSzvTnb8rFBEQ/qOTF3vFFxMjME7RFctY931tsWKyXOl1q314gcvgTu+XZEuQcNrh
         V2q5XEgryIWANOCYLu/kMSXqDMLTpQyeZTZb9CW19lcXmxs7dse6uBgp3KmlkhoCQAnp
         9aXeE10qZe+E0Gt9LjOjw1E7XWYzJUbfrkhtyKnoFiKMyfWaueADaUm5h9uw/raOoEaq
         L13A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=l21441oHLnK9oVeQ4gnC65uBIN32WtWZE/gHPIisLWw=;
        b=U0dPYfrYssOb0zDVsKnSHvHlz10BMfrS/3KYVepHq1bgKfAOQEjJt0NN6XHgVXKfyD
         QKbjLpK2PSOskYXkCbM3Z0j2mEtEAjgrACLQVhq1ya9U9aoUvMbHZWom4ZirkyxtypT1
         b7rvTSKjy6Z5PABX4nVk6cqlDMu3CxCfC7CzK659FHqQ+MBZiIFnx7XITeAFpJPn/kGi
         LRQEdhVanoHJjcVfBVycFaANalP5uyviMdipT00/Xhp5Ofika9zY8NBM833J0jGAuIhp
         G/n4NzJLD3PzFF6tZz9HFs6W+fc5AStB8UhDsr73RY6tJ9avtxvvxqiZVt42xwYQ1Ipi
         KnGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kgA5DLjm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f18si14804575pgj.188.2019.04.23.01.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 01:52:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kgA5DLjm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=l21441oHLnK9oVeQ4gnC65uBIN32WtWZE/gHPIisLWw=; b=kgA5DLjmKDrcmj1FrTMFaqf1XB
	E/x9JKVM34KNwPxbgHhdKrN/iVMK9XkeF/7yoFA9QGsy6Ck4ud3zKMSGh6auPpU8SXPpG4zkvcdST
	KsiL+a3hpVGT1nnQQqMDBDq8eTyxW0im9mkmxBZ4QzDVtr2rvPWinHPRaBjawhI12NLWWPJXSfHil
	Pwix2KdGI9smoDmdhoBDJKDK9kzvaAFfdKM4utX9OJ9pXtOJtu5mm9P50ve0kHBwN8V3AWv7S67Oy
	PhxYcROSzP7UT2Z1x32CD6L+jTYLrAqrVUQdITivscU2LbSInG//SPRToWzsKbqrn63VbfsCBLwpN
	yApA1c7w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIrAY-0002WP-HT; Tue, 23 Apr 2019 08:52:50 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0683F29B47DCB; Tue, 23 Apr 2019 10:52:49 +0200 (CEST)
Date: Tue, 23 Apr 2019 10:52:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 2/5] numa: append per-node execution info in
 memory.numa_stat
Message-ID: <20190423085248.GE11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <7be82809-79d3-f6a1-dfe8-dd14d2b35219@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7be82809-79d3-f6a1-dfe8-dd14d2b35219@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:12:20AM +0800, 王贇 wrote:
> This patch introduced numa execution information, to imply the numa
> efficiency.
> 
> By doing 'cat /sys/fs/cgroup/memory/CGROUP_PATH/memory.numa_stat', we
> see new output line heading with 'exectime', like:
> 
>   exectime 24399843 27865444
> 
> which means the tasks of this cgroup executed 24399843 ticks on node 0,
> and 27865444 ticks on node 1.

I think we stopped reporting time in HZ to userspace a long long time
ago. Please don't do that.

