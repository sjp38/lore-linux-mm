Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5304C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:46:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87E7C21852
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:46:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jq+jJYRz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87E7C21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 201738E003E; Thu, 25 Jul 2019 02:46:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B10E8E0031; Thu, 25 Jul 2019 02:46:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C7208E003E; Thu, 25 Jul 2019 02:46:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B39CF8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:46:03 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id p13so23476788wru.17
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:46:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ISwW/FPdFOwMA+f1KXsWT0wyXaZu+d7Y2bgLdC1RZjY=;
        b=IihDnSfihAwW+EPzo/uf7vFhS4MD/YV8hS+kOpaBjHZt0/xH1bGSVroL12opWxOPB6
         +dhcpGVAxe5hcOl2fze36yv18O7+9Ro1os3o7aRX/JgVHP9+DoI0E9QuEMyOUybKIuhG
         pjxJhmYY6VvBznkVHsOx6D8e0HdS4eKstOfXMvRVwZ2g/m0jvxhA8qIcBvqZpxCK876S
         LFPDWGA8vz9k+pas6tet1RegUQLyDAO9NsCIAaV3Dh4QZ0Px7FMtMw2eYROwYgq/6n9i
         zT8xZNeeSZkUywsNToc0961HJI5GDiQNRrdPSnu3WEA0Nw+CrjDdqXsupu59Vzk4+spl
         V4Rw==
X-Gm-Message-State: APjAAAVOlC3/ilUjAlQ+dQPaHp9KOBEyEqZz7ZX4zxHKTiDH3I967i7m
	MErFU/ff+wOpYRWHoMhK75PUwh9zAdnUQjwiF2nzU79gbGQyGMev3J9adl5QvH514A1qVtFvQBk
	QNbsz0XkExAod4OgOKZFON3YU0D1OZ/QnXGmw0sEXcxeytdzQ1Ppd6eagqz1TVW9R9g==
X-Received: by 2002:adf:f104:: with SMTP id r4mr390536wro.140.1564037163316;
        Wed, 24 Jul 2019 23:46:03 -0700 (PDT)
X-Received: by 2002:adf:f104:: with SMTP id r4mr390444wro.140.1564037162425;
        Wed, 24 Jul 2019 23:46:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564037162; cv=none;
        d=google.com; s=arc-20160816;
        b=pTPAqDFOoWIRQNQ5eyJc2BwndEQg30eohpw6yK2g9mN6YA0J4YSySPxzAf4YGaYbGs
         7R6sU0B59U71m8xL8mEKWCHuIanKJAG2TU8gdAoBtv8v8g82wFr8pRT9XAfzZWg+SZNI
         qmptcaLyJNrE7c+3aKXuLScrz3X8XJetSIN7fTPg+G2knAIQa5n9Byv5uDeMMVvRC8oO
         01whsel5jnnl6yv6MyJcXPrQ6umj0elsRyBu5+b0ZHg6zxGnG6nGryZHh/5ZuUFgf6tz
         5kJXUydj5PHvxzLBDDlwwGSJyJTqyJMDOvZCZG2UWjUhx1SJjaB9pA1TXQitJApSI1CA
         oerw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ISwW/FPdFOwMA+f1KXsWT0wyXaZu+d7Y2bgLdC1RZjY=;
        b=fS6tBh0JLnaQlTzgP8OXANqKgsBOqV01+gXoGfPTppuT8pkpA4Hsde8iX2g9q1CEvT
         Rtx0nbYMMZVI4U40ntGSAolQpeFun7jWjhrdpmbOcqoyYrfELtI+w9tloLQJOv0D7gcX
         1BgfJbGQ2PQZByIyPUlz928pHWH4ObPYcMejfEWOizOwy+dJc3/OEAKPJ44xK5umMxYp
         UpV7h4jPRZxRzd0G8F8YRPMpAKdIXrJLTzwzjaLRxpQWia2Ly2Rlu3d/E3nO2ji6EFr9
         Hu4Sd3bk7EuZ1a2TG71mHyRHpZSsGeD5XekNKHMU2hlO7Ou6iLqMYsMuu3hD+awa0sfz
         L9Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jq+jJYRz;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c64sor27362081wma.17.2019.07.24.23.46.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 23:46:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jq+jJYRz;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ISwW/FPdFOwMA+f1KXsWT0wyXaZu+d7Y2bgLdC1RZjY=;
        b=Jq+jJYRzfYzjtj7fKK0dtSv3ZF/A18/38UcphRm/yWf5nVbWUOLOrO4VS97m49N5SA
         XirL5G0G+/iKpELlfYaYk81exRKefcgnzTvDMzUdsRSEH8cYAB8YXERggG2w24UFC2GA
         XlllfPfL43oFmbHrq2Q+NOwk5OqdPZHMjUTFx7VxeMHZY5qCAQaCC4GGopeFZ3DcQlzt
         tz5Ox5LXUqYY4bAyhqyspuD78R+vCHn1q9IXPHFJSxrYRdFQt5M414PPQ5xhOk6vUUfN
         aMnUnvH9jrNR6ZKheUTfcEfvKZUqKQjzRrYm4CMNQXOpNdfIHq8Uyo9RU1IxpFxK3ovL
         nJvw==
X-Google-Smtp-Source: APXvYqx9qbRIvepznXoOQPiyozZryEUn4nKZyf68iBqkNSV/ji1vnWNYQ+l+Lz/JCf7w/f41c8ClMQ==
X-Received: by 2002:a1c:d107:: with SMTP id i7mr81850351wmg.92.1564037162140;
        Wed, 24 Jul 2019 23:46:02 -0700 (PDT)
Received: from avx2 ([46.53.252.231])
        by smtp.gmail.com with ESMTPSA id a64sm47009192wmf.1.2019.07.24.23.46.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 23:46:01 -0700 (PDT)
Date: Thu, 25 Jul 2019 09:45:59 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"mhocko@kernel.org" <mhocko@kernel.org>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"hch@lst.de" <hch@lst.de>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Re: [PATCH 1/2] /proc/kpageflags: prevent an integer overflow in
 stable_page_flags()
Message-ID: <20190725064559.GA14323@avx2>
References: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
 <20190725023100.31141-2-t-fukasawa@vx.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190725023100.31141-2-t-fukasawa@vx.jp.nec.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 02:31:16AM +0000, Toshiki Fukasawa wrote:
> stable_page_flags() returns kpageflags info in u64, but it uses
> "1 << KPF_*" internally which is considered as int. This type mismatch
> causes no visible problem now, but it will if you set bit 32 or more as
> done in a subsequent patch. So use BIT_ULL in order to avoid future
> overflow issues.

> -		return 1 << KPF_NOPAGE;
> +		return BIT_ULL(KPF_NOPAGE);

This won't happen until bit 31 is used and all the flags are within int
currently and stable(!), so the problem doesn't exist for them.

Overflow implies some page flags are 64-bit only, which hopefully won't
happen.

