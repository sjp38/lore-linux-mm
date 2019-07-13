Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9470BC31E40
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 21:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 288242063F
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 21:25:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="n+MOy4uU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 288242063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C7156B0003; Sat, 13 Jul 2019 17:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7517D8E0003; Sat, 13 Jul 2019 17:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CB818E0002; Sat, 13 Jul 2019 17:25:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FFF86B0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 17:25:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n9so4559555pgq.4
        for <linux-mm@kvack.org>; Sat, 13 Jul 2019 14:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gSeKyUjR9e/8E6Ail8I9eTrrv33i24P5Ay0IpiUeSuk=;
        b=IMaXvUKB7HJCjSKy307JKcxq2dt2x0/7Kwgn8bhbHYBls/lEiLwHlbkTlnN6zuVex8
         97uOLr0YknLXnPCZE2mA4hQum4YZGF47WEYH4+ST5BbibeQe5gPZXbGBndxqlNinymuk
         SO9kROQwK4qhZFCwnEb3QHNmd71bRpAZJZzDYyfBC2NGHuZN01ZTNP6dh2o4mtgpDI2j
         RyMRAGJsgovlKharNfiUJcVNH0E98Zx3UzUJjlq5A5fxgW1Yk8qlz/NjgLNcDasN9f+e
         bi6IoNPWWTM7PXVE1+0GPGGWWYckxr7GMxxtV8GDfUHX8t2vhX1GTz2IJh3gQCERpEn8
         8VIQ==
X-Gm-Message-State: APjAAAX0+WYObFAGyPibYXmDgbLvHyChPaR5M+FBzwCrda28t9KZGB15
	j0hHPcwMd+mWKggc2bT13t3BUl4zQch4ftQCJN/QiMmoOXL2zaHOeWwQz0idBE4CjKJEUXS7X69
	a5dHmA/M/oWSIgTMk10VC8+3BCvcsCFq9acX4YxI+Nq3BoQQD4qCYaEX2P9UsvTw7Zg==
X-Received: by 2002:a17:902:4283:: with SMTP id h3mr19111958pld.15.1563053156668;
        Sat, 13 Jul 2019 14:25:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCughgt3KfSr6hhrDEbLNTIZhdFjb8j1GEoB7n6JSDSD2cPjB6ITC1tTeNIO+RKW7t+lbW
X-Received: by 2002:a17:902:4283:: with SMTP id h3mr19111909pld.15.1563053155930;
        Sat, 13 Jul 2019 14:25:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563053155; cv=none;
        d=google.com; s=arc-20160816;
        b=lc7wPJTdsurQ81jj143xTZIBseGiKFU2MC1BIHnpus1gdac6U7XUMqdH3kubzYLgFP
         V+J0mDMB03BazP6eE3TkIa7w/BtYCM65s+psOI03MJ7qsdfju++S0TiQB1sy0PKB//Ts
         06fhBECV/KAy1zRIADZyKcOKSVYbujJzr57JgJWdp9/J3BI7D0oxDeqMev80c8yi6Mo8
         JB27u7oOr6gYJ2xWL82yqvZymhXNSit/TurB7lY/MrOVbniB+HgmLfR1AMtTjxEt1QGM
         KkISJ3Fll7xXa6lrdFo0pfijod94G6ha5iw0UaWtqSE4CwM3AoIoeVke/RL+7wdA2M4f
         8JAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gSeKyUjR9e/8E6Ail8I9eTrrv33i24P5Ay0IpiUeSuk=;
        b=Rp0giG3BVYtfyBDGskA+7NCCOuPNa9SORWFtGofk9R3fptNf/2jiP8/h1UOQq7vR1E
         a8XdJ9KLF+FlZwdbh3/gJBVk5p+nBt5k54lxE5QXpeRqHZqeK+Alhl5zjx6qoj7nriez
         eZhbGAf/ZIB90+bEtZwpFtbYXsQSgPhv7A9fPf1O87wYRYtbfUOEOEY+kH7nrbWXkj9V
         lP1TZVdTq9QnJRXWZFUWgUmtGUdfi4Ys/Qb3Sx9b9UR6pppG4KZoA58+t+2JMW0d2cOq
         eyNmKnmlLewx/egFbPJPlo4OmpBjGfFYJR8m1bfE71h0nXzzkRJaL6kwrLCVp1n4OmI2
         HHsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=n+MOy4uU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 73si5095381pld.221.2019.07.13.14.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 13 Jul 2019 14:25:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=n+MOy4uU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=gSeKyUjR9e/8E6Ail8I9eTrrv33i24P5Ay0IpiUeSuk=; b=n+MOy4uUpRDDKVw797VGean/L
	sLUlmgRNfdhMrcyVN318bqRxqpOqYGP1ql3GAbR51HRE1PO6hWDniUxEovN4bBCID4hZBrBc3/3tW
	1UU8uqKuIEz+vEOchWEaAW/A8YXw7qM+rzkndP83kJeIfXlC5qCWy49VTdHbvS1yp1oKfRPrgWR/G
	CDT6ujKi+a9TkD46YJ6fBfxu4DY2Jsw9TZm6nZ8F3oiGPI0tDKH3KnynKzLyiMjBVkAiYuaSyPo+h
	3acXGDjgf3JYRk4OygMyT6AzThsOMTGJ8ip1m/HH0WmJGNjCt/PYtYOAE4WSxQ2YV0L6/4F3b6lUc
	KgI9MVqCQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hmPWf-00081A-1g; Sat, 13 Jul 2019 21:25:49 +0000
Date: Sat, 13 Jul 2019 14:25:48 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
Message-ID: <20190713212548.GZ32320@bombadil.infradead.org>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 13, 2019 at 04:49:04AM +0800, Yang Shi wrote:
> When running ltp's oom test with kmemleak enabled, the below warning was
> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> passed in:

There are lots of places where kmemleak will call kmalloc with
__GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM (including the XArray code, which
is how I know about it).  It needs to be fixed to allow its internal
allocations to fail and return failure of the original allocation as
a consequence.

