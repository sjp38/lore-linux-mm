Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EA70C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:21:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EE4821473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:21:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EE4821473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE45B6B000C; Thu, 13 Jun 2019 17:21:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C96206B000D; Thu, 13 Jun 2019 17:21:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAA626B000E; Thu, 13 Jun 2019 17:21:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82BFC6B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:21:30 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y80so118163wmc.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:21:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hqsxt+fbgR3jIazqyw4s21M9SKHahZPUw060EYSVFHA=;
        b=f55U5qJ5cd/dMz2WRFNxwlRUFfvPBwinygDgCzXMu486mJRlpd+EE2kOAKn8VRrt+B
         CIeCIybp7opMbgfRPELtXQneDIIavC0CiWBKXgPT0eWhqlWdBQIMDfutQl7lEdkaZgNS
         RpahzeFEmWEQvpiCxWLP6P9b2f3uow1/BNhUAJ2Dm/7Y8DOgoRCbui5AgjmsOBvd3loQ
         TwMlggczjl2In7aYtkzNta9UYXuXJwmgQBUyjloan69skryIIv/8rJYFnHOoW4SJtd5h
         w87olRMauw91WvJZxaUBxJFNm5GFVQMRWfF+fCHxnwnipu1ih8wVL1Eu+7EyW/ipxvLs
         J7PQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWuybXBp/y7jQdZex8SMdXZrtEv7uOWzxCnkzSjSvsUZhULkUvO
	nn10+er9LODJAqv+8Lk7nIcaVWTPQhJ5wuKKqfOC8btIL1XZnxU7e74/3Ciy963NKXlfqbHj/xX
	yCSebni2HJBBv3OUBf4Q/GeJ5+YmA6WJvan8vkFFc70mCy0VYZgWIjpAKPS7826QmZA==
X-Received: by 2002:a1c:452:: with SMTP id 79mr5319025wme.149.1560460889985;
        Thu, 13 Jun 2019 14:21:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsRWE3mM1oQ7yiI0xSPLMuC0RF041Vdx3dnpqejS3qO5WEC8bSy5AUnqLhgYcXCncuTAQ+
X-Received: by 2002:a1c:452:: with SMTP id 79mr5318996wme.149.1560460889293;
        Thu, 13 Jun 2019 14:21:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560460889; cv=none;
        d=google.com; s=arc-20160816;
        b=03MeibGM2bRZwtL6ckxFP5mecf8NOhzgenx0OT556mXas16rruGHtEI1PsvUO9BRGs
         9hL/Q5Np/0ZK6OkuX8VF1t3RR7ZgB77hOHMoo9g942izOsiuz0M073A5VX6pG/HJ6/QB
         saHi+8tSvlx8NWNlODZYEXlAa9oKU/WeOrT+InbeWEkK3CCJ64oQaI0DxAOQ5B8aiw6x
         LPJEXBk8NGrdwv6mjsZRZJ3UQKGcaUaemnI+tSIFQ2ORQ9IEPZ8ttR09kKgco+M7iXlZ
         1ZEJs+cpBczHJL9F10flRuaTGbuS5Lx4Y+PLykAXjjUN/yhQdvr8STeRRBbm7YGg5x5f
         urxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hqsxt+fbgR3jIazqyw4s21M9SKHahZPUw060EYSVFHA=;
        b=guCSdUFoVqeQqTkZzY3UP5KNrXBVeAJ/AP1Olz/dxrhXLx8SzTnV53lKqOGPD7PH5Q
         UJa7P5Fc3jGNCccQNuwvfnjBId9xUjGbcr5kdvrK0MaTPfOWzo0uVsqkEKNmrE5KktMr
         WOGf3jdy/JgCMJZ+XgCJbDugINQ2EVCJW9Fl0jPC24VrZ9WuSuHfyaooT4E7IL0KPRsN
         G+mPrQ9oFxWLzfRLH1QRbcI52g3VCLbU0Sq8EI4trSR87eCkFzaJAGFhISN+WtdHGCSA
         EBCHh4CS4evQ/NFdffpImSVatpSGf/T3Hqf66ulZZW8LqKYEQY97VD5TmBhKH09QKcQ0
         DUTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e10si729068wrm.258.2019.06.13.14.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 14:21:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id A375468B02; Thu, 13 Jun 2019 23:21:01 +0200 (CEST)
Date: Thu, 13 Jun 2019 23:21:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dev_pagemap related cleanups
Message-ID: <20190613212101.GA27174@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com> <20190613204043.GD22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613204043.GD22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 08:40:46PM +0000, Jason Gunthorpe wrote:
> > Perhaps we should pull those out and resend them through hmm.git?
> 
> It could be done - but how bad is the conflict resolution?

Trivial.  All but one patch just apply using git-am, and the other one
just has a few lines of offsets.

I've also done a preliminary rebase of my series on top of those
patches, and it really nicely helps making the drivers even simpler
and allows using the internal refcount in p2pdma.c as well.

