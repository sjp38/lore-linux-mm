Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAA7EC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:14:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B121521019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:14:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B121521019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 619706B0003; Thu, 18 Jul 2019 17:14:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A2E76B0006; Thu, 18 Jul 2019 17:14:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B8848E0001; Thu, 18 Jul 2019 17:14:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19EEB6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:14:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y15so20759313edu.19
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:14:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EyUZu0OR6xdNkd80tcmVCqPnME+hvjeHMGNo1OmaVsQ=;
        b=OgqkkjFMDDUvgDbE7FGY7tFLK3V5eP3oOrNkZ7sOOuil8EU96Dp35IxW6topF9308U
         q3Hxx5RvO7Yhwye34Dvi+B/2AIImEDWD2Jt35BWj9qctJF4HlMOK5vbYxrzzDRszkK3Z
         4oU4P8uvVEhKhUg+mX4qBGOVFcDDhHh1JGgfPZeHVUy3trUTHB9TdrF2feCMhjY1Btl5
         6N2TXwYOMU2zvGzV5YIrmjG/8518z73btsOMJPBR/TRjRExZoNusIbjsvIs1D+qzvUgO
         MLyPTM2PzUYkWBGsI8Ze+K/liG8lxUXXEy+hMM2Ww/NDFA16KWi5dvCcnuEzOaVkXHgr
         JdKg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAX4A2ahqtFobcn7cn7/kMnyLRYscFNPqG4xSgNzQ2kxBzNhPjuu
	ZgZR/3c6sAKdTu+nTez7BpMWlecUHK4SCMt+EBt8IkjgwCZaIAhdSoS/sGuBTtfv4bP4WZiZs4y
	b0ecViWx0fYj3RhKKhtvVZN1Cfv8h3wHc9G8R3jlhF686iuiQ6Wp2s7GSK8jK19Q=
X-Received: by 2002:a50:ad2c:: with SMTP id y41mr42039466edc.300.1563484449635;
        Thu, 18 Jul 2019 14:14:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7rgMUdVLD9C4my7lICWth700NIUZIljAAOwQTx6+U9hb8GD/nTTrJd1iYHjuk9X+BxpTe
X-Received: by 2002:a50:ad2c:: with SMTP id y41mr42039435edc.300.1563484448866;
        Thu, 18 Jul 2019 14:14:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563484448; cv=none;
        d=google.com; s=arc-20160816;
        b=lMHnG9GBabkotDMPWfGQ80xIOLyFa5TGpoIq3gZUNsKr88KW28Z63Z3mt6HPz5zOzU
         H2QDuGkMF0i1753h2Iy2qcQXuBGgRZMlT7dFWqoETmVZB5UtZ4Xb4iw73hGvyl7isKXa
         Zw6kr2jEnF/DSRB/OI6xdlMUOlWceu9zQ9sLYjNbkRQ2kvfz4njHZv153+4BitrHHYN2
         4XaAn4x+n4jPXEg2dXKevCZkNh/4G15IxHOxOfzctV8R28N3Os/waD1voQEfPPnY39pR
         /WsEZAnYB7YSuWQ8CqX4oYfqWZNa7C2CLu+nbJQil1rMRc+SDR12nek/k9gGcsue1VPx
         ilRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=EyUZu0OR6xdNkd80tcmVCqPnME+hvjeHMGNo1OmaVsQ=;
        b=wTnB/M9eYKH8k0Dl9Vb91a0ZDdeye7DoY+GPVVyo23B4z+Ba9pm6xPS5CImI1FoRwS
         tB6m6gWhxaFD3RpnhtDikYzbRIBC4QvN8EsToVgMY1MVwq1CpuZc+e3celnWnZjTIKXb
         zCXrUra6u5xoDyV16y86pg+/411L3bA0KRm4A9jXdpWtmaPqDHMTgcnae8zhyw2HILka
         LDrU4BkJvMVKYMt8dD4eruVbercwPpkcE1+XWRYM2ugRAg8RuKr3PsOLg96Ra8k1DlxT
         HuuE+W0Twjmc41ET6j/AC2m/IZZQkv3uf+IwuppP5r4rwCR7LadFuvDzEuK8S+FXs7MU
         UDDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id x34si11075edm.138.2019.07.18.14.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 14:14:08 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 29B831528342B;
	Thu, 18 Jul 2019 14:14:06 -0700 (PDT)
Date: Thu, 18 Jul 2019 14:14:05 -0700 (PDT)
Message-Id: <20190718.141405.1070121094691581998.davem@davemloft.net>
To: ldv@altlinux.org
Cc: hch@lst.de, khalid.aziz@oracle.com, torvalds@linux-foundation.org,
 akpm@linux-foundation.org, matorola@gmail.com, sparclinux@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190717215956.GA30369@altlinux.org>
References: <20190625143715.1689-1-hch@lst.de>
	<20190625143715.1689-10-hch@lst.de>
	<20190717215956.GA30369@altlinux.org>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 18 Jul 2019 14:14:06 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 18 Jul 2019 00:59:56 +0300

> So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505
> (thanks to Anatoly for bisecting) and introduced a regression: 
> futex.test from the strace test suite now causes an Oops on sparc64
> in futex syscall.
> 
> Here is a heavily stripped down reproducer:

Does not reproduce for me on a T4-2 machine.

So this problem might depend on the type of system you are on,
I suspect it's one of those "pre-Niagara vs. Niagara and later"
situations because that's the dividing line between two set of
wildly different TLB and cache management methods.

What kind of machine are you on?

