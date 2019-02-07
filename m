Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BAA7C282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0670921721
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:25:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0670921721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97FB38E0067; Thu,  7 Feb 2019 16:25:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92E288E0002; Thu,  7 Feb 2019 16:25:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 845E28E0067; Thu,  7 Feb 2019 16:25:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 431A38E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 16:25:24 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b186so285694wmc.8
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 13:25:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LkpSFcW5BQTN9H+/QyLdobjxgg43K7KYi5yJX5tHA6s=;
        b=Zb3XWnrw3vVA/dylLvlS72xRY+lX7l61YK3t8XVNcD1xH+PfcimpiK3vmWd7G4WpS2
         Z8NkRP2KzL2M1bZd1mVYs9oAuddP1Qan2rZ1fNxJDIt6WyDrmsR3rGD/ab4YbAQVnyLl
         hxWRTWXxxmq5T/mfzpghyORUlSWMpnY6qmsM69uaw1SKfJNR3Bk9I+AhcEjkGnK1cV3M
         6sJo+9PopQMNjHXWff/s1w/a7azaS2ovgT4GHEk9ZcAbDfINyRe1ETVDtBri+kpbaS5g
         MTOpSqofQzCQQxd/hiQZ7S40KODU//Do+phmkipy52lWJdd0jrEvfqvONJhU5x0tRBEa
         EYmg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: AHQUAuY8RiWkofWtxK7oRMvxBQziJpCHDqcm3GXPG6XzUNYnuCc3LBFn
	vUtqQRRuYV3LzGYFOAMqCVtSMAq9oUUljtMLSdM/toOJf+mHPbzNXzU0gJ0gSba9a20NZvMF2mI
	zUuwFhWQhH9XOa+ArQWdpMXmhfSHmCBUgofMMnsyyuGzuS49CqhMysnpImYRusi0=
X-Received: by 2002:adf:9dc4:: with SMTP id q4mr1776851wre.330.1549574723365;
        Thu, 07 Feb 2019 13:25:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayQvUIJp+hx39efrVU+7gc7eWquKaYHL0xWQJi6oKexaMYf55EOGQC280LIswsQbguQEF+
X-Received: by 2002:adf:9dc4:: with SMTP id q4mr1776818wre.330.1549574722550;
        Thu, 07 Feb 2019 13:25:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549574722; cv=none;
        d=google.com; s=arc-20160816;
        b=hQ0vf/J2sGUTd5j1KSCS3wlQ44eWpiOx9At1lo7ITwQWncb2A0RcLtjE87nYI3G4SP
         ig7ri2s0zvIdYrLiIgTcPTYuAHU1a6XQoR7qIOTNqp/ZKIW/ZAPA0YA0rPRtlhlZVamV
         pCO1sbTC83cLoNXGJm1n+OJEBK5sR0H6zQHv5s2jyqDjx2+aBnh0Rcv0lDM0p/JplzHm
         +zaDxymmpQT9Qz1Ytqvk3uUMC6hwblGytOOpC6yAglCuiun0OqNNUFZ+LoRpyttpIgUF
         GRNQ2Rffztc/B59RUCMJniovV/19nIhlmIwGRb8Rc/gWx0vS8j4QdNugYFGTM5Rtdbes
         hRcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=LkpSFcW5BQTN9H+/QyLdobjxgg43K7KYi5yJX5tHA6s=;
        b=AdXTX/nkxod9xVba5ND0U1QHYw9M5H0+tvq36TJvJIaCxg9ZKhr1rEPPyCU6jyG+hE
         uCPtwJP7gbLr1hg9xrnjVsqjcVHpqSubvHjC6X6Etep4M+fgsXRUqofYQxTVS+31L2/A
         KiRieLIxVnxFolz8fuHdldLyjk90GllvEX5FRzcqmWMfQuAuiic9pycXIVUasUlq1T+r
         3rQwbvsLqgLFgubtoUdTjyTsD6iGGUYgrQeHfNWAI941qvUXy4nxNOOyiYSPdTOwH3Ey
         dRlyJtTZK4J39o+3EBj/UqGMNdrO8qKYItgqpqiesoyVDeGpe2P1EoYwOZAUb/wONJRJ
         zGEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id j7si45858wrv.370.2019.02.07.13.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 13:25:22 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::bf5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D7249146D8BE1;
	Thu,  7 Feb 2019 13:25:19 -0800 (PST)
Date: Thu, 07 Feb 2019 13:25:19 -0800 (PST)
Message-Id: <20190207.132519.1698007650891404763.davem@davemloft.net>
To: ilias.apalodimas@linaro.org
Cc: willy@infradead.org, brouer@redhat.com, tariqt@mellanox.com,
 toke@redhat.com, netdev@vger.kernel.org, mgorman@techsingularity.net,
 linux-mm@kvack.org
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190207152034.GA3295@apalos>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
	<20190207150745.GW21860@bombadil.infradead.org>
	<20190207152034.GA3295@apalos>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 07 Feb 2019 13:25:20 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Date: Thu, 7 Feb 2019 17:20:34 +0200

> Well updating struct page is the final goal, hence the comment. I am mostly
> looking for opinions here since we are trying to store dma addresses which are
> irrelevant to pages. Having dma_addr_t definitions in mm-related headers is a
> bit controversial isn't it ? If we can add that, then yes the code would look
> better

I fundamentally disagree.

One of the core operations performed on a page is mapping it so that a device
and use it.

Why have ancillary data structure support for this all over the place, rather
than in the common spot which is the page.

A page really is not just a 'mm' structure, it is a system structure.

