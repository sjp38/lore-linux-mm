Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E512AC43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 21:05:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A1B520679
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 21:05:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A1B520679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAD7A6B0003; Sun, 28 Apr 2019 17:05:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D378C6B0006; Sun, 28 Apr 2019 17:05:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFEDF6B0007; Sun, 28 Apr 2019 17:05:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 868456B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 17:05:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r8so3921659edd.21
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 14:05:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ABQT6IhWTFvKBHf0jufWEatzXY5brCQQcrimFhPze4o=;
        b=rZ04PVr4gZOF2OnFRS6ljYfzfX2wZOtE5RPwdxnQ79X9OWbiLtbFAXwHZbQqEasyy9
         Q4ZXo3N930HJq5vpRyA1eazLsULTVtQmWrsFGuNKXdRkS2HKRABP9NkGD7pA3Lc9MaLR
         78KKM8mv1BcWCaKAqZGDgeIMmupolI4KsDcqJ4n39DRh18cT+m5nEkpatvMIwBgEuv/G
         SnYZ12HV0IzOQUKBlpAjHaM1tGsIqHoYNksc3vtkaFI+GpWKVUYpykAR0ygb9cuRWuDU
         YfnCgQgVz0Cuulvv1O+JFH/AaVxh4JcIJM079pudk25Auebd8rUdaxq6+0Wby2h8WloO
         Q0nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAU7se43YNu6U/UBVaOZDhPhoC5pdSNJUH8bC/vhsfVWpDZbB+6/
	IKJDHLIn8dR+ZkH/IKG2SssL8kO3mmCHms8YZGb0/OW5sdaW+YNqrM7dNejbMQi6v76qzApjeUm
	qi1x0YsnPo/cIMGIFO9m8sgQqiaxlUAHEX6xhrETW34eueHsR/3qkTjQgJ9xwCwualw==
X-Received: by 2002:a05:6402:13d4:: with SMTP id a20mr36564900edx.279.1556485544079;
        Sun, 28 Apr 2019 14:05:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRAegJDE36QrOIZnMTiniwV8VtMBxlN4baYUc96dSZlXoXrOXMcczn36L0qxZLRbFzvP4Q
X-Received: by 2002:a05:6402:13d4:: with SMTP id a20mr36564881edx.279.1556485543350;
        Sun, 28 Apr 2019 14:05:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556485543; cv=none;
        d=google.com; s=arc-20160816;
        b=aVW585k+Vo3bFs6snO32xesYGL+zlJ+2M2Q8JS9iBhBmq0rbQr998XPxmfU6Z2ebH4
         T8bif8VYulma1uPzOpEuAUWQWtjDbRUcPHJVeKB8XO8TFSJY4xWM9qOXGr86/aFBzOjU
         uE+qHXmVSxjIxjdmn0zzwdjpmnQCq0wmaVkMxSrYtGZkIZWKMrrf31C80R0OZVta0s2o
         zq7wTCHYXrCXGdeRtmqcK4czhBfuwM1naWAqWI3QTSF3R/3sqR25ORT/IZY3AJoXQ0kL
         MlAIZ5H3WAAh5BdQk8xTiVFPUbMOyG2wtg7T15/RH1nNNDaVcLDcjk+0WHPnx/fiKOOT
         3uKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ABQT6IhWTFvKBHf0jufWEatzXY5brCQQcrimFhPze4o=;
        b=QaA7iJy9emDGniGRwAEaQzM1T0Yh4G4SJmCc0MjJoyMoj48/4l/Nntei/di5gOdSfm
         SmtconB+HSPlZrdHL2dQyDUAyDESPxUlFPUyMMQKj9G6+BowDqBM7yAV0y+H6CdwZwsu
         RG801oiPQOzQhaD0PV+mEFxd8vuYT5TNhBFa2fBhK6bmpdOLzlX/ygE0LWo8Jm+TANsu
         vSz43IJAS2gVYzVF1LYE5g9AChaVCYMjdtCyDorFBPuM5sHw3aBYElevD7rK2GB2r+pq
         WY8GZ5k9ZFFUWxKC4qkwce/eahtdbn1Y35fV60JRyWwcHy92vh5sBtRgwQIXBATRggws
         rpkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si3272459eda.435.2019.04.28.14.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 14:05:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8181FAEE4;
	Sun, 28 Apr 2019 21:05:42 +0000 (UTC)
Date: Sun, 28 Apr 2019 23:05:38 +0200
From: Michal Hocko <mhocko@suse.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yafang Shao <laoar.shao@gmail.com>, jack@suse.cz, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/page-writeback: introduce tracepoint for
 wait_on_page_writeback
Message-ID: <20190428210538.GB956@dhcp22.suse.cz>
References: <1556274402-19018-1-git-send-email-laoar.shao@gmail.com>
 <20190426112542.bf1cd9fe8e9ed7a659642643@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426112542.bf1cd9fe8e9ed7a659642643@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-04-19 11:25:42, Andrew Morton wrote:
> On Fri, 26 Apr 2019 18:26:42 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
[...]
> > +/*
> > + * Wait for a page to complete writeback
> > + */
> > +void wait_on_page_writeback(struct page *page)
> > +{
> > +	if (PageWriteback(page)) {
> > +		trace_wait_on_page_writeback(page, page_mapping(page));
> > +		wait_on_page_bit(page, PG_writeback);
> > +	}
> > +}
> > +EXPORT_SYMBOL_GPL(wait_on_page_writeback);
> 
> But this is a stealth change to the wait_on_page_writeback() licensing.

Why do we have to put that out of line in the first place? Btw.
wait_on_page_bit is EXPORT_SYMBOL...
-- 
Michal Hocko
SUSE Labs

