Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E73D1C433FF
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 15:39:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF3120665
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 15:39:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KaJpknF6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF3120665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0BCC6B026C; Sat,  3 Aug 2019 11:39:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE3B56B026E; Sat,  3 Aug 2019 11:39:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFA2E6B026F; Sat,  3 Aug 2019 11:39:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98E1A6B026C
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 11:39:15 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4so42921922plp.4
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 08:39:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=I1NrYHa+YaTrMj4UyPPBH/9wAm+dfInLgj5QDmyuYaQ=;
        b=Yu3JYbM4MeaebwkSs+fuEafK6wGSdnYTMiaAkkbi0Bar2vMBG7oasbWq1cBRFvA3t1
         a02qnfvDEv4MjpNhsr2iPB4rgT/8o3ZJcSLifN/cHcSHbbdhkQmvHUj1X85+kku757fu
         Lk4U7MrC9qxZaX81+/fIiRLo3zE6zJkErjBYPzLfCx5fXtq+KpCkZFMc6JqCZEAQTB5a
         qVbgPWD4EvRReUB02dGQDQqfLfoffYb+NCT9AXow4KnQLtG7iB+dFfnwlY3P89vYw78Z
         58Bh5/RuudWwa3725mPAYUZzkM5lBngmgouPJCdWlNqEWeZ80UmjjY3TR8y1G/TuSnF+
         t/rA==
X-Gm-Message-State: APjAAAV0TfIeK8rmgf/zoKA0RloW1Ettr+iYxz0Q0BYIo4Ft03IW+zHP
	qNi+B2b2awPt8357KGaaRz43MAjdA0KQszLbt0HN3juazr4OyvMCW7s0yjhSZ9lltGW7SlxgDXs
	KBC5LC4m9l7ENH3hH6Go13XCsdMmvUpuVAcPBBhX+Kq3HS9prnNrxlfpdJHc/0pcUgA==
X-Received: by 2002:a17:90a:2247:: with SMTP id c65mr9453484pje.24.1564846754766;
        Sat, 03 Aug 2019 08:39:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu/0awZrsn9lXOlsEL/E++Ig4iHvhYbS2s+2DYHG74YHBCQ0Dk79+6ztJRcBXr4aGDrM+8
X-Received: by 2002:a17:90a:2247:: with SMTP id c65mr9453432pje.24.1564846753511;
        Sat, 03 Aug 2019 08:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564846753; cv=none;
        d=google.com; s=arc-20160816;
        b=Tw+mTPgouadKE6iojC9TiflHQaElkZr5C4wmLXjjG5uDyC3zNLGVoVm1jveD7EVW/1
         8hMX/5Cjf07yflcc07ZzOZOTBYY9TWWaURwTPzHjYu7lCD4uuYRYDSZ4O3Sb52isnW8t
         NZZ7ArXwrDxtQ1u7SoiP3WTqPqeCimi8KthWMj/ywQneTZwY5RDBs/370lrCFdgcPVfV
         s8cen+M3sxGYwIQq3sxKUA3YX41df06h9nUGhF4uZS/GmMm/w/KS7tdz0sUNZhqmqHyj
         th6mRhdxGcqqYB8egg14hRlIl9AGFC6RA7N3NV+DbBsl6OjuEEa6F/1JdAOP9c/D7OPl
         fxhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=I1NrYHa+YaTrMj4UyPPBH/9wAm+dfInLgj5QDmyuYaQ=;
        b=LACLE8yTdzWsKJDMlaCQSZVwUwg6ilpnSZ7DeYSVKC9RXKEiWkaegmd6ELbrjFEr7t
         Vy1MrlGNgaySoaVyWRUQ3TTfdm+qAPwtm1z967fOvor53uup4bey0JTU12lVzNV4/PDo
         rlxJ/Q6pO+AiSxSY/O2j1OAt/va3Rlbg9WZS3vg4WC2rZa7P/WmzU1myPIlBvL9aTiqF
         7XGVhviOCf1Jdi9jeZbSgnP0+i2lLuPXYVqVkMIsCgqeGhNJ9orlrUXI0ml7MrdXZHpU
         tRQ5ldbGzW49vH65Am5eu/YX/49SNLxaun46z+UYlpTftjjFRRtCQo6/ScAXicxWD3Sm
         XGDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KaJpknF6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id k11si40247775pfi.3.2019.08.03.08.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 03 Aug 2019 08:39:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KaJpknF6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=I1NrYHa+YaTrMj4UyPPBH/9wAm+dfInLgj5QDmyuYaQ=; b=KaJpknF6oyKuFSUS8QpoeQZ0+
	oO5lkFotXCzO34i1rtC888bSh5w4VMe2rdcZBVoXwym+9Z2lnOXcg7ahfBEQgWj2kRSUeUDo5wJl9
	HSLC4OoX/h7Z9Cn5OLIexQxK0GxaECorGHjmgRx8p/vDhIndP9vCdDwrVq65o6FYbdXLU5+ns974a
	Ch4goXJuQGZ1Lu88yLYcUIUx9TcU4+kY3/EfLCjDFs2A6onYOsSm+vJbUG8F+Zhq/fbGwjG5IfqnI
	Sawk07uOmPsZ28vxchbJ+ghXjXuRAP1ztosFlofvodsJeD162SaAT4XcqMyY9YqKHDJix3Ky8Mv4f
	tIWSGaB0Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htw7g-0003BI-H1; Sat, 03 Aug 2019 15:39:08 +0000
Date: Sat, 3 Aug 2019 08:39:08 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-ID: <20190803153908.GA932@bombadil.infradead.org>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-3-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190803140155.181190-3-tj@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 03, 2019 at 07:01:53AM -0700, Tejun Heo wrote:
> There currently is no way to universally identify and lookup a bdi
> without holding a reference and pointer to it.  This patch adds an
> non-recycling bdi->id and implements bdi_get_by_id() which looks up
> bdis by their ids.  This will be used by memcg foreign inode flushing.
> 
> I left bdi_list alone for simplicity and because while rb_tree does
> support rcu assignment it doesn't seem to guarantee lossless walk when
> walk is racing aginst tree rebalance operations.

This would seem like the perfect use for an allocating xarray.  That
does guarantee lossless walk under the RCU lock.  You could get rid of the
bdi_list too.

