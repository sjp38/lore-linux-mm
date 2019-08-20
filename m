Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CA23C3A5A1
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:59:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4089C206DF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:59:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LpB2kY8B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4089C206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD6C56B000A; Mon, 19 Aug 2019 22:59:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B874C6B000C; Mon, 19 Aug 2019 22:59:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4FC96B000D; Mon, 19 Aug 2019 22:59:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4446B000A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:59:45 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2676A181AC9AE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:59:45 +0000 (UTC)
X-FDA: 75841301130.30.sack08_8f49067458d4a
X-HE-Tag: sack08_8f49067458d4a
X-Filterd-Recvd-Size: 4430
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:59:44 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id q139so2403374pfc.13
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:59:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xkr4IFk7JE8tZJ5lH5GPaHBkXeIGAFFTk63OiHmuliw=;
        b=LpB2kY8BgQK2hpTo0dJctfeVuA/CaP6yYvy8cfnj76Y9sDqI2ujKQhZSHFyNdKgaOs
         En+s/YIUmXOpUpSzJTHQ7L9BYKYm1ICz6+j5v7Yn0Sdogcfa6s4eOsu2dqZSyHi45U8/
         a2RqmxLh5nbeXuobqflCMc6jX2UZmlpRQSfEPkWYz1bxdpL+Vd9n1i+SWJmDrOfA2hEI
         YnBsyt0rW54mhn5WbD/lZVZ0XdHuH6p0TlbXosYL++PdLoHrkBIqIbwb8GEbE//u4zKw
         ZXuaOuvuhOqOD1yY2v9vrc8tZRW5SzcTdfGKrwhu8JYFRYVhYS54t9e6NnjDlB0kPyw2
         4qMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=xkr4IFk7JE8tZJ5lH5GPaHBkXeIGAFFTk63OiHmuliw=;
        b=caqSziTGbVnsv0AiYWr7+WQJ7QVP7mTh6apHg6IhJcOMs2Zc8JGdLq5erJAZ1UskkM
         yXVlGmZwh8AelXBopXeF/Z5oPwFxtHSccMsACOd7OEEIE5zQ6Hu7lQYsFIteGGlYwBi+
         6tuXoWcKMlofqku8xyXNTAUDA68xbeQazjkV2LPx5GlQAJGLkrPDvj/nuUvGWwW4006u
         uuPqmPkbgn6CVrZQxsSX7jDq3hr2QsZf0nwVp2ef3YhRRQBabD4l5NgU/fkpvVIkHz8S
         68bbnSaklQxe9NAyTLt/lSyQ+ptu4fAwYk7je8wJIyT8XdphMMGNfWXKjJ4klldON3uw
         xEdw==
X-Gm-Message-State: APjAAAW7jPRlgdZw0QgS2jxQUjnOmkLRwg4g/E7r2OOUI2X1U1/dW0aN
	tdhK7vK2T2u2fD3qt1refeE=
X-Google-Smtp-Source: APXvYqzoJkr8vPoB1+xNhD+aD7juFSbD1YaXoFMDG5Df9hXhPBM+Xp+F+o2wbpAawUabV7nmevHZzQ==
X-Received: by 2002:a62:38d7:: with SMTP id f206mr27847336pfa.102.1566269983701;
        Mon, 19 Aug 2019 19:59:43 -0700 (PDT)
Received: from localhost ([175.223.16.125])
        by smtp.gmail.com with ESMTPSA id a10sm21744430pfl.159.2019.08.19.19.59.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Aug 2019 19:59:42 -0700 (PDT)
Date: Tue, 20 Aug 2019 11:59:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Henry Burns <henryburns@google.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Jonathan Adams <jwadams@google.com>,
	HenryBurns <henrywolfeburns@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2 v2] mm/zsmalloc.c: Fix race condition in
 zs_destroy_pool
Message-ID: <20190820025939.GD500@jagdpanzerIV>
References: <20190809181751.219326-1-henryburns@google.com>
 <20190809181751.219326-2-henryburns@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809181751.219326-2-henryburns@google.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/09/19 11:17), Henry Burns wrote:
> In zs_destroy_pool() we call flush_work(&pool->free_work). However, we
> have no guarantee that migration isn't happening in the background
> at that time.
> 
> Since migration can't directly free pages, it relies on free_work
> being scheduled to free the pages.  But there's nothing preventing an
> in-progress migrate from queuing the work *after*
> zs_unregister_migration() has called flush_work().  Which would mean
> pages still pointing at the inode when we free it.
> 
> Since we know at destroy time all objects should be free, no new
> migrations can come in (since zs_page_isolate() fails for fully-free
> zspages).  This means it is sufficient to track a "# isolated zspages"
> count by class, and have the destroy logic ensure all such pages have
> drained before proceeding.  Keeping that state under the class
> spinlock keeps the logic straightforward.
> 
> Fixes: 48b4800a1c6a ("zsmalloc: page migration support")
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

+ Andrew

	-ss

