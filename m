Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA708C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E5D120820
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:42:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E5D120820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B3B66B0007; Fri,  9 Aug 2019 10:42:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 389056B0008; Fri,  9 Aug 2019 10:42:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 278E76B000A; Fri,  9 Aug 2019 10:42:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E47A66B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:42:22 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t9so46972746wrx.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:42:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
        b=ZNTGjG/ng7aycFR0/UN4HM5bMT9aZLh1B/hH2Vk9Isz+DQ8iKXnmxagg+a+Y9iA5mP
         oWXqpfPPaVm8L1qvfGN9Q1ruvAQKBvgcFNWwCi9/BRIQKeuyec+xb/jZ1z1vPS9UT7z/
         BtKlXuQ64tTK4krpqs7qlnaQN58r1KPANuV/Fewa9S8aEtkZ/wehJeHmMeQrgIf0bzpy
         mHCy9+bXmBF/Q1pjeuCpuE8kkz+fGZrm1L76x4u4UZsWUymSQFpwSpJAlK2B03ca69uK
         aVyS99RZFF6TzEaVlwwuY6KWauEpU69ZrgYci5qWkC9LJPVxc7G2iVc7kyjNAsUVqhoK
         Bz7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUI9zb2gPrFo2cqRzCjOA6ilWyidsCMCgdTlzFWGFKjm/Zl8S+L
	Fs/T/cxAgaBEKjl4dyud0dwYjXgUQxanD6SBAkqhmEmzYMJZGgHi7MId6gBrUvyN17sGFv5EGXC
	HyCJk5FHsV5R/u1Ioj4z+A0pNCrSy/rz9zELZc2TFlpiONAt3ZVP39BUf3xDQcJyw+g==
X-Received: by 2002:a05:6000:12c5:: with SMTP id l5mr12030352wrx.122.1565361742475;
        Fri, 09 Aug 2019 07:42:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyae/6qEZI6uW2y3yc37Q5XPzvbSYWhhmVyI+6yoI6jaQ0Syp4SvgXij+K62JsMzIb5q6KG
X-Received: by 2002:a05:6000:12c5:: with SMTP id l5mr12030290wrx.122.1565361741857;
        Fri, 09 Aug 2019 07:42:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565361741; cv=none;
        d=google.com; s=arc-20160816;
        b=Lq0dMvtHPp93au+FUcpXzzznN4vrqYR7Nz15XXyD/5NJooU/GXZOQNiZsu/KmjNv5l
         ubhXTl/kbVhWdYjL6b7UEHSczmG59ZXmF9t38WDp3ok1t+KENRlV44NteIjBOjD4OC0q
         ctDrOJZGRNXVaMNi552HOdphkpf73dKkGEaDX4M/8xfWGIR7YbQR3pIMXtuCtiTNQAkY
         VGPWTV63MKMojaVIXkjCPsPqSVvrtMrvQ5QCsn8Gliisl5Tr9n7nCMuC+bB0jh/cIFFO
         A2tZYt02vKTvYllRS2Aa/Qzqq5cE5Xz6JL+0dmCkv4+fgfj6EnTY5niYBwUpUdp6KpT3
         lpkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
        b=oTA51wmosoS026QtUy0b4zH+2qLXX1JRawdSjbVw57w+x3y5/trOa/P6CObiOQs+pC
         oJs78Y3zriKPmkVCnyW6pxnauGDixbFSiWew5iVw/EI0SapvFoh4zNUJhZER166Ic577
         AQQ1gTbQGtfNp9E0/rgGz2CzsWFUymE06IGcHiq4TLtW1Nyyidvp+asEhX6XvjuoAdht
         UQl2xjDBOexLlaB6AGZNb9PrFS8/meGdhEKv6RQxYBxLIlagihBl87ZmZlfQq0yy8jGx
         N4gjvlJA8WS8UdPIDLke5Buh0xY5M+KELJgYqx5Vfq/Gjt2Ca8Xbb4xKx6DVaHBTLI7w
         lm1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m8si77555106wrw.85.2019.08.09.07.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 07:42:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7386C68BFE; Fri,  9 Aug 2019 16:42:19 +0200 (CEST)
Date: Fri, 9 Aug 2019 16:42:19 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Fan Du <fan.du@intel.com>,
	Vishal Verma <vishal.l.verma@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>, Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm/memremap: Fix reuse of pgmap instances with
 internal references
Message-ID: <20190809144219.GB10269@lst.de>
References: <156530042781.2068700.8733813683117819799.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156530042781.2068700.8733813683117819799.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

