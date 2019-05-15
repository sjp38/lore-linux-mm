Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A03DC04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 11:50:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED84E2053B
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 11:50:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NJTP+oeO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED84E2053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90B2C6B0007; Wed, 15 May 2019 07:50:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BC3B6B0008; Wed, 15 May 2019 07:50:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AA5D6B000A; Wed, 15 May 2019 07:50:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 415F76B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 07:50:01 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o12so1568880pll.17
        for <linux-mm@kvack.org>; Wed, 15 May 2019 04:50:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=mc63LhWg2+r8G6LyepIMoQgzu86nCTP3tUKDYnTysXo=;
        b=ireYRprcGBnTnpRbTBw3YMJI2rFO2TEEuMRfmFqtmyM9nPCd69xkhYJQzT064RDvLf
         nYFIN7EGsgqLux1YKHIkGoMqyPK9zULqiMRQ4eCchmRQMjR60BhzkgsZhRCP5WCyfNhp
         zLwIQW+DFFXE8VGn7GT/OJ4NwLUrelbT2wf+2+EFMUM/m0rJDd/Ba5K5RhWDWz1V3arT
         qQi35b//bc1qz4OMeqmj40GwaQmKVC+HwrH4QzROGGb1DJ6SZb/owIGVMwl2K4ANx8iJ
         M2K12XRQov0ADS486RQKbmVnnbxI1XouHIfX3YdGAfuw/qhp/K8dXxatwpCaTQ4/EJsj
         tgmA==
X-Gm-Message-State: APjAAAWxT9CTxBfwetvrtILDgG4aGLLO4PD4uKc+wyj0m2Ixpwptdy/L
	aIVpSbIh+cwrAd/CqH4HD3DB+OvGqhqEkEnGqGp078yox+vXjMjOiynIureY00caEHzxa06944E
	omFcRFmE+3ONHyjfjpwS2YkBDdT9HBt6ebyrnEZrm6qs8AAPbvqgxHCXEyQCvkNFftQ==
X-Received: by 2002:a62:6582:: with SMTP id z124mr48322522pfb.0.1557921000613;
        Wed, 15 May 2019 04:50:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxCFElkravMLIgNX7dHw86TyDGCbHsNytJeN85T79d8v4howigXHaQWus//RHlxjuFm3MS
X-Received: by 2002:a62:6582:: with SMTP id z124mr48322485pfb.0.1557921000001;
        Wed, 15 May 2019 04:50:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557920999; cv=none;
        d=google.com; s=arc-20160816;
        b=dMv7HggUrX5ciyFIWwWCBPoB3vydIML7BlM+V59A0O8DrQ99eeAJeIilyA9yWK4cmT
         8jMR1GA1muxthtcp1dnGnxaPXvkvN5mWhcx5Zv2RNGVrvNmlPkCSUDg88DOhP0nP6ajI
         RXYoozP9IzXxSvldaAmYkrgAbdn9wEz6NgRRb04AAaaLktuqpc8gUpPyoC7O+4e/vjvW
         WxhNjDwElLRkDHy0D9T8gSiZVkdfIC5Yhql22oRMrd6apeT+8knnMAzcBJMY/ZeyVQq7
         jm7nY9ZMhONCyihBX3J4IqyYmI2Fr3lp7AgikgQeIQzZhmBqCm0Qt4q7iGBR/XHM8bdP
         JUWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=mc63LhWg2+r8G6LyepIMoQgzu86nCTP3tUKDYnTysXo=;
        b=h0vLSxMzXi9A7+EUNopU6ZM//ZMjM2BslSUUxTaqhtCOQSjDlRUl9CIZkAS7dv99Rl
         UF/1dPLr9ArLfd0Dy2WAVZ1Uv4gK4mTNlE3q8c2b5WJPZjkqyteA+WFaQCd+8UiGJwQ0
         Tv1Y17LdOHdnoxe/TvWAB2arubC2uzi7hMQIpTUS81IYdUW2o5gsYM4603VeRixAGC/E
         UIqEJkRvrhJu1tXVKqGheFT2cXdu1nAIGIqNdSSY0Sq52jwzW6N7iz80ZPfRQbnuk9h8
         yXmyXsMPdeNZi1fGdzSNvKAORyn+Dav2+ETR2n0Fjti8+y5xbQZbSU/EmqdaHoffyccd
         S4LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NJTP+oeO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a3si1727354pff.117.2019.05.15.04.49.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 04:49:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NJTP+oeO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=mc63LhWg2+r8G6LyepIMoQgzu86nCTP3tUKDYnTysXo=; b=NJTP+oeOJ2KTSYKFCNvyNdWTdl
	pkNAYs4PuM9AmwDSp+SRpJ2s5RQMLUOl+KvQeTbeCBBsWXMw//5EKv/S1ECv3NJFKztodOWSY+uLL
	x6LYCjisteMmKVkA80CIMjyz4BJLmCPomB9t/OOkhdsAJ/bWKo979xjvYWMODNwDryd1NyB1llGar
	THnvqn8pLDBzW6vZ4tX+ssfHbXZ49/xxkOo0JV+TI5LpknghfuJv6cbIJh7CPO5Lot3bObhMxV3Yt
	Fxo2c5686rUezL0nFqDfxSaVnWqnD555AqmYQNfVM1IDIDTE/CQfBBHzPVUdAf/CZJirFW1pVKzht
	Sl5ZZM5w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQsPy-0000MW-Qa; Wed, 15 May 2019 11:49:54 +0000
Date: Wed, 15 May 2019 04:49:54 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: khlebnikov@yandex-team.ru, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, oleg@redhat.com
Subject: Re: mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
Message-ID: <20190515114954.GB31704@bombadil.infradead.org>
References: <155790847881.2798.7160461383704600177.stgit@buzz>
 <20190515083825.GJ13687@blackbody.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190515083825.GJ13687@blackbody.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 10:38:26AM +0200, Michal Koutný wrote:
> Hi,
> making this holder of mmap_sem killable was for the reasons of /proc/...
> diagnostics was an idea I was pondeering too. However, I think the
> approach of pretending we read 0 bytes is not correct. The API would IMO
> need to be extended to allow pass a result such as EINTR to the end
> caller.
> Why do you think it's safe to return just 0?

_killable_, not _interruptible_.

The return value will never be seen by userspace because it's dead.


