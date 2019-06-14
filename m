Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5578C46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7012F20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7012F20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 107408E0003; Fri, 14 Jun 2019 02:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B83E8E0002; Fri, 14 Jun 2019 02:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE8538E0003; Fri, 14 Jun 2019 02:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id B52B38E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:43:42 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id a126so212889wma.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4ewZIXMd6QVZdJWtzUTUDe+bVjnKK3XZRSDBcNJAUY0=;
        b=H3nicXjrdufGo3ONNQshTvQ8szPccRzpRs39glAKveAimMiB89SiuK7y7XuAhF2KmD
         wNOcfWmruLBmIhVt8RB58lM3usSjKqCKRUSgcTJrQ4vBI8v8FBMIEis4lH2rgsTTJznM
         io54EBqA/qkF3rgAnyk26nMBs428xkgdoiCkFBLkOuFrIEAZEnIiSJvShVy+kBOeKwnC
         Lw/1rQro0Xo86ExLVEk9qdmUfmIndpwctMryhQfavwSTsyvTPrMCX2Ivar3X+Bo8twCo
         5pDEwZ9XLhbR1K4cVxsxDeAktgLTWQ9jjuaS5HodNvE4mPKM1aiY/sRnSXMuq2hc4Bcq
         f7eA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAU6mKd8L+4pK6s5CVpRQRISKXxpjM2Deachf9599/MZyuV6xokK
	xwuSmnfS2JE3+AyVZq7Gs2Nk6BGXzl1KDqVOkfJul+186nUcUzCgYQQIpjxdxSMgnMLJsw/cpKQ
	uHfeD0q8NUDAFTZrSPUMNnOkpplgG6fqvYY+V+Fl7qwxUQ54Eyg+YtmrjEcSUUc4l7A==
X-Received: by 2002:adf:ce03:: with SMTP id p3mr36239146wrn.94.1560494622191;
        Thu, 13 Jun 2019 23:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrbFpzdxiQQsFp3JdmOVIW9BmxyhBKKfJp0wyz2ovpuj70v1doM8EE/LV6iccQnp8e705L
X-Received: by 2002:adf:ce03:: with SMTP id p3mr36239107wrn.94.1560494621589;
        Thu, 13 Jun 2019 23:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560494621; cv=none;
        d=google.com; s=arc-20160816;
        b=NQA1Z19Z3yeH595Y673GmA8cDYOeBov0Qbpv7SfjTsXcArtGFwlpZG+RLgsWXxn/Ki
         ZwQSRPnFKa6k9l9LhFuoTC6EHPaJs5bJFNbOSvuW6HT3V/r7mUIc7he1yUdwmgY82JV1
         Hu34KLR72BnZNOKjRMcn0bKwhuYM4Gj21G8chMEhnb3n+MBEX1CO0XMZKdZvMYI/DnO0
         a0UAFZ5lYxtfpQxS03pjYF76ZGGk5qJgqpk3FY0JGv0MLuUCiJBPXQv4+Xw6ztJ7Iqjm
         Bnm1ue/2GAiiOBDL0KqdBJK5amaplLD5zafXxiTCRVE/kcrPQYIbjJdQxD1EBDzT6BMm
         LN8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4ewZIXMd6QVZdJWtzUTUDe+bVjnKK3XZRSDBcNJAUY0=;
        b=IgKIWL75nOHuaNJmDWvbVsVCjCwMG57xSnD3aXGe2CfwBInO71tMzinEqMivwqw0fA
         kHR69LF5N2H4mvHHexUXCNrHT9VF1rP7q2wZ6Ct/AkiL+0qhRESRq5rgztDSoLnEpWg2
         5UC+OfAg45fddGq5m09WRVcJDdONQRz6XxZ+04ODCUslM+ugdu7WvzVCgjkT++Uac3Ie
         0IN/kO3MfcFSK/lOdam69CRWsFsYy1vX719le/iHeZKEEp6suqElxWltGuYr0Vrv4znj
         v5r11nLAUJHGGcMd/ffSVJLEmgiUTXykThgxVTv1blaoZlRbfXI7e+0X25EOSy1P0zdR
         mGlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i16si580082wrn.219.2019.06.13.23.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:43:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id D916768B02; Fri, 14 Jun 2019 08:43:13 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:43:13 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Message-ID: <20190614064313.GM7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-19-hch@lst.de> <20190613194430.GY22062@mellanox.com> <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com> <20190613195819.GA22062@mellanox.com> <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 05:43:15PM -0700, Ira Weiny wrote:
> <sigh>  yes but the earlier patch:
> 
> [PATCH 03/22] mm: remove hmm_devmem_add_resource
> 
> Removes the only place type is set to MEMORY_DEVICE_PUBLIC.
> 
> So I think it is ok.  Frankly I was wondering if we should remove the public
> type altogether but conceptually it seems ok.  But I don't see any users of it
> so...  should we get rid of it in the code rather than turning the config off?

That was my original idea.  But then again Jerome spent a lot of effort
putting hooks for it all over the mm and it would seem a little root
to just rip this out ASAP.  I'll give it some more time, but it it doesn't
get used after a few more kernel releases we should nuke it.

