Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18F94C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAFFD20851
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:20:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAFFD20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66FE16B000A; Fri, 14 Jun 2019 02:20:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 621756B000D; Fri, 14 Jun 2019 02:20:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E7EF6B000E; Fri, 14 Jun 2019 02:20:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 044776B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:20:15 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id q2so624349wrr.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:20:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lCYmOEmKlO5ZrrPVD1pAoZebQosiMr6++uU8wuwXUQw=;
        b=MNw+EjkbkWV4GDadyZzpjgJYgdgZeiOCP2E6yip2h4pWZUQuoUflHoeaqXo/5WqAp4
         x49FpwG9AXZH8/dxgy0LMa9N3zuZUIIDIyVGe7gn0yZGkXSJhewdWWoXpWH80ITd8z/y
         UD/k+EVwlobg40l3YjA1knp7WTsnjUgmZPe/hAyv46RfpYrV9BzwPKlflYD9QsJ6J4QT
         ShlTgLMT8xS8vaViUZmGmfVCX+1XUExzGoHn4ZB5FC3RDoolwbiGAiXlezJsaotwnKZX
         /DVvdM72x1V0+f6WmKUsDzNvms758oQtteM2xhjUN2bphGYYg4qq83I0KTvfc0Vf90+e
         zstA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUsEJQiAhco/1rEfqYgYPnwfLup4GMpKuKqb2eCnyAFRM7WFB23
	LvxM6rK0d4542R8OTPSgrQ6T9hRH36zZIvybkRuvDYRnEw+gA5pqJWs1s7EWAuPrO2SvRNV6IzQ
	F5V2xFkshoy3Wctch2lXMykivoRKf0O68yrgB3HwWEoQX1VYn97sfnNLYac1MYcfxkw==
X-Received: by 2002:a5d:4cc3:: with SMTP id c3mr37419316wrt.259.1560493214471;
        Thu, 13 Jun 2019 23:20:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJITjRGkmtNJ8WZOIz5o+3k+N1tJo2kHjM8lAm+O0KcsMsE6LNlasO8isW+20meVmB9IQ6
X-Received: by 2002:a5d:4cc3:: with SMTP id c3mr37419268wrt.259.1560493213894;
        Thu, 13 Jun 2019 23:20:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560493213; cv=none;
        d=google.com; s=arc-20160816;
        b=OrGzXtWW1nBfw66f8vl6mU5LNCyp3sV1XqeuPx4yifxCwrIu2bPyEDSEYPfVtJ+iv3
         nFDKQPGfX+e7H8qZunHJWejNcXdZvCSYzKv5xqJplw2GaYN8ut0WKWnRzdJ6dao1bmae
         3UxIut51QzjJjnJsvvPOgz3SdiYJH+lfgk1wfLoLlRJMlhO/yrFPC3JLzIQlNNExCYio
         KWlYnAbMkqNPIhOPyeFY4QeG9nSD9nF9VKJ5pySMLy+FjydH9jBlt7667MnZWD+JC270
         FS7QW97InXBmjSOeibGGYmb2zfGYH3+GGoV4kOao3eCat1nFbfPxBSq+FBc9Q1Rruw6t
         lRlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lCYmOEmKlO5ZrrPVD1pAoZebQosiMr6++uU8wuwXUQw=;
        b=dNYfFQxUHYsXK4UgpzeH62FbLNcnKJ8QFaU/Jgaph9pUTopFcuHGDtPzoRS8G339ZG
         mIv3z5mJNk4OZnOfK6UxQDxUo31iY2SBMcTlV1TkHgmH+lJ1cwm1R36emqYy8Gownh++
         9yZdIjQPwbutPD2qRcY72ixa8ITRaZ5ZRvafyZZnYrRE1cTJDJ35NbNh6GYbdZtF3mFg
         UwHvmLG3jRwBiY110RXh3MIMkRdrgRxXJIW6fySVrIVX3KXgfAqG2bFBPjHVjv5lRa5V
         r552Jww2t2ipAjD7Q4Y+SSho29R+UV5gyNDL4wW7gJuerW+mYKrgkKd8a7jxrOCIuPOk
         4XTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j26si1782500wrb.265.2019.06.13.23.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:20:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 4C76A68B02; Fri, 14 Jun 2019 08:19:46 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:19:46 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/22] mm: remove hmm_devmem_add_resource
Message-ID: <20190614061946.GE7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-4-hch@lst.de> <20190613185239.GP22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613185239.GP22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 06:52:44PM +0000, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 11:43:06AM +0200, Christoph Hellwig wrote:
> > This function has never been used since it was first added to the kernel
> > more than a year and a half ago, and if we ever grow a consumer of the
> > MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
> > directly now that we've simplified the API for it.
> 
> nit: Have we simplified the interface for devm_memremap_pages() at
> this point, or are you talking about later patches in this series.

After this series.  I've just droped that part of the sentence to
avoid confusion.

> I checked this and all the called functions are exported symbols, so
> there is no blocker for a future driver to call devm_memremap_pages(),
> maybe even with all this boiler plate, in future.
> 
> If we eventually get many users that need some simplified registration
> then we should add a devm_memremap_pages_simplified() interface and
> factor out that code when we can see the pattern.

After this series devm_memremap_pages already is simpler to use than
hmm_device_add_resource was before, so I'm not worried at all.  The
series actually net removes lines from noveau (if only a few).

