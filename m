Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0CD9C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:23:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DF5C20838
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:23:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DF5C20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22E696B0007; Tue, 23 Jul 2019 12:23:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 205CC8E0003; Tue, 23 Jul 2019 12:23:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 144618E0002; Tue, 23 Jul 2019 12:23:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D592F6B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 12:23:40 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i2so20945201wrp.12
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:23:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xyJTWU9b5fco4qOLbXrIOwiVKVypfmh+8Us16UT6fWI=;
        b=cBx12zI8uGtXkadDFJzct6/W6E0VosqdTXHN+K6Rpg1+vU2jfwLV11laab6Wsi7bd2
         fPGiidieb9fLU/hwTJKP/LjUSeZVWn7i0RfIEgkgVaayBrXr/N18nrdE1mhXfn13Gqwy
         6gEgHJL58ylzMwvanleyATW8odTVsauPsa4iJh/Yc6fmvFYLNgIomyIV1O83Y4MROG5C
         kZcDj0vRwW44nUfETdggJGIt46hIaRiczWwFU+e+2ESPtJ5LRh4l5MrI/MOkY8ubKlHt
         bcxFIXlV0u9l2Ynzt3kcZvvcOxYxcSt8FUyS8rKrZeLsv0+NKFDmZNEfQLjq5eOdWMr7
         Dxlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW7TZLBUcffPbzzPDX7HTm0sQr4+JZ/8A9NtZQMfmRnKJuTvI6d
	3KzQXYUmqYRUTGy7u4t95pk9sPZFnaWMuaWjC3DVBLO2V916UUwbHTpDYzKGdq//BajXKmZKnqF
	JNYs0xY8oVIUHyduTvbyYqoKIIBcfIksc4RVhOq16ZG39ur0zlhL3j/+0gcCkZbi2fg==
X-Received: by 2002:a5d:670b:: with SMTP id o11mr26317412wru.311.1563899020431;
        Tue, 23 Jul 2019 09:23:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1ZMNrm+D++m0QbJEo4IZDVSgcIbxLxu6rojEgIbSkKJ7tsACeCLycztjHFO/uDSvqVMeA
X-Received: by 2002:a5d:670b:: with SMTP id o11mr26317365wru.311.1563899019723;
        Tue, 23 Jul 2019 09:23:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563899019; cv=none;
        d=google.com; s=arc-20160816;
        b=QVJ0ipVy/vMBbet5n6dxRGsoJYO45+XG0VS7j9g9xCMlnyJAXoTlUb7Wi+gQy3EPIq
         lR7Vg5kDea7IFFPFTi9abJ/gegids2kLURKiIqxrktAREBk5OifoYYiVLZqK3gjNnW5v
         3SMVEdhevHy8IsfOdQzvE3r3TkjuXx9BT8pI0eD1z/JPnjkYb1LcjLniKfPle0uzxYv3
         x86dEW5tAVqKa0WC4cXghp+Q0Jj+uS36ZBncySPs9APWmMBGUv8kS6+7wsY0reMlS/90
         ooG0EWdiJ2YiGDUXIalnc12Gmqfx1/j4iRH9Y/afG6mAEG9k162fBb9FljsgDW8hvi4b
         pIdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xyJTWU9b5fco4qOLbXrIOwiVKVypfmh+8Us16UT6fWI=;
        b=HnyTHrr8OhPLwixPya4TPjaLTgzYZCi3uuLwIDwc/Slx4nzEIDrW2oqL9CDHhk61l2
         adnYIcDGQVxXHg9LKTkfigiHFOtKQXBWg6XjjsiAvIPlHZurllqFKVDlGfiAuYUevpQ3
         ufzdrI/bqAKwZUhYXb0rk45oCx4XAqqOulAcY2g/ljvN3JbbXHev+JJznvyK9QHNBuH8
         ZaAP9NM90yrELHGfDhTEv6iPF9mdmdz8qE+5+QjYT51kkzr3kE0qQ+aQJspeUafcZls5
         M0sTj0IvULx+OaxFPvEUTw2qZiGYnSAfxc0+p5MQtWQzf826/pzsvnrkKeZdFfCe+0ge
         GPGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j6si43860121wrn.199.2019.07.23.09.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 09:23:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id DA76168B02; Tue, 23 Jul 2019 18:23:38 +0200 (CEST)
Date: Tue, 23 Jul 2019 18:23:38 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/6] nouveau: remove the block parameter to
 nouveau_range_fault
Message-ID: <20190723162338.GC1655@lst.de>
References: <20190722094426.18563-1-hch@lst.de> <20190722094426.18563-4-hch@lst.de> <20190723145620.GK15331@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723145620.GK15331@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 02:56:24PM +0000, Jason Gunthorpe wrote:
> On Mon, Jul 22, 2019 at 11:44:23AM +0200, Christoph Hellwig wrote:
> > The parameter is always false, so remove it as well as the -EAGAIN
> > handling that can only happen for the non-blocking case.
> 
> ? Did the EAGAIN handling get removed in this patch?

No.  The next revision will remove it.

