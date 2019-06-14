Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05D89C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC32F20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:48:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC32F20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F7118E0003; Fri, 14 Jun 2019 02:48:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D6578E0002; Fri, 14 Jun 2019 02:48:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E51C8E0003; Fri, 14 Jun 2019 02:48:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3618E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:48:52 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t4so660074wrs.10
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:48:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nthXR7WMDdAS+InvoyRL0xRkrGwwx3yOXiOa7B6rMRw=;
        b=h65iwJpnhYsn6zUrvQLIsu/6+G+/+jd2kRx9sWf2fIiEEjY6M5HPlQJQwGn0+0BPeN
         7U+sEa9jzSh+B3wTUF0cfrTS37bBDJafqqXDiyURRxMS//MNKi/AmZrgr2RoZpJMaWK6
         6pVG8MxeAPem1+4VQxeeZC8+R4GQHjmAftaHRxzolGuvfLttaU2Z7+PfmcLhdLy5AzWp
         mV+KsOgbwHzQYV1DKc7nvRQrknVR7D7PQf0SKsKEct+olsUKcz2tp4kEsW6CeES2oAP9
         xS9QrlZh06eUmqoQ2E20+aQuiJblXrZqKHP+aBAN6meVUJuCO+D22AagXfMQxaM6ZRQ4
         njLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVZpkzhHlGKDwD6Ia0bpd9XdgsdtTOPrWYjz8tbSD7uWtt09oIL
	Ft0UL64lef4FeUEh/kjs63hays4aFXDYpY/Ezh8pEGKw411v3AIzG1p9Zq6jffsc2gxGhLM1UL4
	sgxyGEyNOuSqUJrbgJhWNw9Imbjb0bASQ4n8tgUuSaCyJsytVqJ4Vsj7nykkpiVX+Tg==
X-Received: by 2002:a1c:40c6:: with SMTP id n189mr6363248wma.118.1560494931749;
        Thu, 13 Jun 2019 23:48:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkZkWdB5ezbxxSOUjiyzwf4ojDB2CellBZ83sIcgDR6CfBHE+ks2g2JHrGu6iIWDnEtK8I
X-Received: by 2002:a1c:40c6:: with SMTP id n189mr6363218wma.118.1560494931132;
        Thu, 13 Jun 2019 23:48:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560494931; cv=none;
        d=google.com; s=arc-20160816;
        b=KVSmDtKEHYJxwrUGnxjsBzd3gBjQp/7gbz/PCHeqtfPcwYzeXGxgHroJyb1/YOUSJn
         YUka85wvPx9O63Rj+LD7JfPZEzinzmaDyI/FACkJRN5kHEa1vL1brHnAxU3IuuB1toPt
         jY62UiatS7bYTHmkPfw+GyYRW0RLRRiNjXE/U0oFYBZPSYI6wwHjarsykh2WnQV6jjXN
         8+ABXrdzKExPYDmYbGwguYCdrcF9PZ5OD9R/c3aN0uR85VEnlIUIFwtn4q2SCk745frC
         dJxQpK6+7MjusEIsIh5E62/4qMtgMExBYmPB3GtCe0OVAZ51ZcHmbbASHFl3E4AoEy20
         7uXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nthXR7WMDdAS+InvoyRL0xRkrGwwx3yOXiOa7B6rMRw=;
        b=zJd3FCgBGBqwtnQ+T89kQNmS+aW5kxRVw7cOqi1FzlFma3Pavh/a4q7MZ9PaG6hoWC
         qLZ9R8pn6xjwDuMROZhDCJBwaXksJC0PNnhrzhm1jQLIBGKwDOgYxePBO1xrTU6jmJc+
         0ugTixWcRrQVdSVALYv8cp9cajOyCLAbZyLOt0lhbEa1RHNnP6Bm2ThcHS4F8g/xmByw
         jpYIMPLV7QJ28MBFpd6vo1ZQobiidfw1jl2wMWMYxA4+mErcsgEvqP0swOg5iDJ/bfyC
         mQaXAFtu4LvDBpQ++M+5mQ0NkTfkC+Bq1aHvZJBUZvlurxOVstQ1TbKGGORtQVZ1e5Yj
         A2Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c1si1205130wmk.119.2019.06.13.23.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:48:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id AC5EF68B05; Fri, 14 Jun 2019 08:48:23 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:48:23 +0200
From: Christoph Hellwig <hch@lst.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [Nouveau] [PATCH 22/22] mm: don't select MIGRATE_VMA_HELPER
 from HMM_MIRROR
Message-ID: <20190614064823.GO7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-23-hch@lst.de> <7f6c6837-93cd-3b89-63fb-7a60d906c70c@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f6c6837-93cd-3b89-63fb-7a60d906c70c@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 06:53:15PM -0700, John Hubbard wrote:
> For those who have out of tree drivers that need migrate_vma(), but are not
> Nouveau, could we pretty please allow a way to select that independently?

No.  The whole point is to not build this fairly big chunk of code in
unless we have a user in the tree.

