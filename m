Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20777C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 12:55:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B21522075E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 12:55:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="cKJsQ4QD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B21522075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CB516B000A; Tue, 23 Jul 2019 08:55:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27C178E0003; Tue, 23 Jul 2019 08:55:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191E48E0002; Tue, 23 Jul 2019 08:55:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDF136B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 08:55:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y15so28202983edu.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 05:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pFZp4l766Ry5QM/RMTGMfDyPknAkOz9aAyfaDcK3dFA=;
        b=rev7JdgP+5Ded5Ynx9oSZ9m0lSxH07P/PyWJhhgnoO0pTx6fshctsz3EpZJAV2inqc
         vDrwqBOr4x/1BDhwDwmjgf8Xz0OwdKoP06ELaABw17PMDxrJmShnDazShgL7Tui+0vs1
         6n0WMoBFw6v2ytCdP2uPAF5wUwBVPYOi7Re0dmZO9MLyeDlBd/xO+Iau6KoDeEU0BYHc
         sJ2NQA7gjGjtl7vUbaQ1RdAXaJfdsK4KzitYGsSI9N+JK5Z0TlnuVC6iB83h0R4mONJ8
         1eIb336YdL5qf8JC4Cm/EcQqRRpIPIkyt9j5V+aDVJBl4g00d6DyQKONkPTne6KKVSEr
         nfwQ==
X-Gm-Message-State: APjAAAUcSNvzoll5LGvRPXaxCGdJ0qDfRF6uQhnGRFIals5z/I1KOH+5
	jZCIwCxW11tWeoZWiKg4P88v0UVLwVncYlsNWn+BmxPTyILwQ/Y72jno0zrOoxkjYTg47/oIlof
	Nu1i2Sa4P7Uu/ask1iKd4EmAJ87lx0kQnoA3IvN2kApdEbIDKeFiG5W3wIXZO4M8=
X-Received: by 2002:a17:906:6a87:: with SMTP id p7mr57669998ejr.277.1563886527280;
        Tue, 23 Jul 2019 05:55:27 -0700 (PDT)
X-Received: by 2002:a17:906:6a87:: with SMTP id p7mr57669966ejr.277.1563886526679;
        Tue, 23 Jul 2019 05:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563886526; cv=none;
        d=google.com; s=arc-20160816;
        b=fsiSjNeZHwg6Dpz/HsM/eu/Y4UT51jMkwrtZXkOkdk4f/XTbza1t3m57amMDd4snIz
         mjiP+Hku1k58Wb+4qwjIzM8qwaeN/9rYb7LHJijf/Ve2jw22SqBosuxpJXBD3qSBqys+
         xx8BV2OIL/f8i6Z8QlGfrNkg/KCH9jRx0sTNPguInZHOe4ZOJzG+EiPY33ZpglcILEvr
         1Kph/EYl+wnYyqq9inMHyGb+zAH6tQbf1Ep16swvI/flpZ0z6SMLWxfYDROtOT3XkIPL
         RwA5QPCAdfghmxKl+ilmkE5zo7wwt3WNviFTXmiVniY10Iqhygp0c9MiuGSSAtQ6d+JR
         x1rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pFZp4l766Ry5QM/RMTGMfDyPknAkOz9aAyfaDcK3dFA=;
        b=Tjxb4jcta46eHG5mzThu5w0BlPoNu57rVXrpg259mv2yPT17jH8p58Q24McFk4ANfY
         7YRmMV8nh6z3Tn1BPHGzlIER6FN88Ccwhnr2Gw1Rh979+wZVB7ZYI2WFQTd1kZv8p6eG
         hHA/3o/AsG1yfe9Y4RE287+PVc1zG567fccoM91t20wOLAk0AHthObh5zFffGT5nvf9I
         gHfqNNw1HSAASA21bg0MELPTmGan/984WMQZdRCRgRw6AWF1pULF+LuEDOJ1k48K21+l
         WVOVrivnAuIQ5tI8gaptKJiscmeb2KQzNiKhS+5aiu+iwxqUQIwkMwSz4MnhNt7tqvav
         JVkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=cKJsQ4QD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor9465484ejg.7.2019.07.23.05.55.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 05:55:26 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=cKJsQ4QD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pFZp4l766Ry5QM/RMTGMfDyPknAkOz9aAyfaDcK3dFA=;
        b=cKJsQ4QD3okpMFjUzCnQbjCLjk8/e84oAHL2rCr9LW4+2+PdK5kkYDoiBbfiueFhjw
         EzaD5MnDImUn3iAqjkIh3Nw7CgFA6/o5CUhvNwUGOExUxbFV6lmKZ0+FBgLPW9FqRf3F
         8YpWDKgP3OF0afSZbd9KZ45BlHWyUH7bzmu4QyyxdtQtAG0XfzSOImcnZksFlg/gvhO1
         NGD/H1egwUSzyK/edjRc9qUOvhEmfDLfHfCB6XCBLSgDlrnnpFb4KGm1C6e/WaYkUC28
         jnSBh/Kk0pxEtxXYCrM4+4iuaADalrHFaCQ+hGuckqFlLdJha+DckesZQ814/jb5P505
         RCFQ==
X-Google-Smtp-Source: APXvYqzxCc827yDGfGMrXU/nQ/Qqc1u48EXuN8rntj8kc0npcGBSiMMgW+KtsptRmJGwmcHa1TXPBA==
X-Received: by 2002:a17:906:499a:: with SMTP id p26mr52912526eju.308.1563886526315;
        Tue, 23 Jul 2019 05:55:26 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id rv16sm8635717ejb.79.2019.07.23.05.55.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 05:55:25 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id A1D16100ADB; Tue, 23 Jul 2019 15:55:30 +0300 (+03)
Date: Tue, 23 Jul 2019 15:55:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH v2 0/3] Make working with compound pages easier
Message-ID: <20190723125530.eaz6522seslrkrdm@box>
References: <20190721104612.19120-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721104612.19120-1-willy@infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 03:46:09AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> These three patches add three helpers and convert the appropriate
> places to use them.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

