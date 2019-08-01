Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4D9EC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:04:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E37E2089E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:04:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E37E2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F5AB8E0003; Thu,  1 Aug 2019 03:04:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E208E0001; Thu,  1 Aug 2019 03:04:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFB908E0003; Thu,  1 Aug 2019 03:04:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD8538E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:04:42 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id s19so13502122wmc.7
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:04:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3clYCnNYU4HaHYWLJ+6h1QfI9wy6Hc0Q5FPuwmUb55k=;
        b=E2hl9jSP3rsoW8eleSKVUVGD3+0VRYL6ZTIK0tkg0ap426o7u9IuZ5ST3JqhvXu2av
         4lJa7I+et4veOfcRDWKKH5mvi+F87II1EhtdIsJAyUJV9VHPtIdTQ9NbdFKdj6klAtLX
         RvWqHuwt0/l9aK+yXhWCDZPN8PbNXxnm+HyXfZdRkePhfhB9nPVK0WN3YVKtzBpwaQ71
         h/bvaY9Dse3eNj0LRcAma28jwcDGTjDjrfdAh+6zOuOjxTTcAi0ZeR4u184sKzkOUSFs
         ZJnk1BcOfVjzJft83V5v5B6KP0WdriYvZEUBgej38j+9xybS2OZwb90vENxARC+VmVFV
         Aonw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAU8f1FmXWeU51HtUBNO42wft7hSFsh6aymlZWNf/jMxu1cnQ7bX
	cFsUMGCh6EfNkUJW3A2u8d83bF34I37q1ID7+yElfOGh7Q5z8hGMcv421ooBJFC9m8xJb9BSJv4
	/GaE0W/uwtvyZoHyaNPs18yqE5aTe3kBccq86vrMIrasFCQu0QIwV6Z0P28g3tpMc0A==
X-Received: by 2002:a7b:c4c1:: with SMTP id g1mr19825888wmk.14.1564643082318;
        Thu, 01 Aug 2019 00:04:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhhEWrlU2NZkDQ/KBgDFGpxrJ2eDpVjFco3c2upkn/Ib++/mWHBrYaSmI8AZ8Ofpzcs3W8
X-Received: by 2002:a7b:c4c1:: with SMTP id g1mr19825776wmk.14.1564643081315;
        Thu, 01 Aug 2019 00:04:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564643081; cv=none;
        d=google.com; s=arc-20160816;
        b=Fm4acfbEkx9RXq+xI9O93711s2vpsEsEx9L2bM1GDAy0S5lkeDNMIp/G0FhotjogeD
         EwauG8dBOAy8JMJf9BtdLi00gxNdEyQyNooid0AMXbywSh15ABLr97RVJHWe2PWB727J
         t3HZH6bJ/sMej3EffAnB4dh7pORoZs1CnBNnzZc4S3wj0k6Xr9Db3biJOYQaR2BLKh4e
         4ezvrF621FIDo7TJ2D8cHBAc5XV418No8M9K2YnOkaTJqUwkkohN0tPfweWXzyKgBc9M
         0ctsqm/psMIttLIqdXIA2OiGLOBgBulanaW6LMJl3FAENQWVE+hriNhTSd8YfSLomiT0
         cD1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3clYCnNYU4HaHYWLJ+6h1QfI9wy6Hc0Q5FPuwmUb55k=;
        b=ZQhrx8/EiLptjl3WdDshBPCz1GQX1L2aJvJ7tKo1h8vgW0GG2h9hnL4vISDXx5l8fz
         DClV4PiviczifDkIUISU4qaLYPR+9QvoDzoOzcnz3zw/4c+Je968z14NqBcyrIXX8cQJ
         0klg6Z+TpfdAYHjWNNqWQHMB0A1u6k3IaN0IqwDIFQypVzjEYhHThU1yxBPeCxQurb6J
         CmSL0gBDT4luED+oW6pOUwzZg64mI50HK36whudfua/lgDSWGHHTGPkmIFLZYspsO0ZB
         5rNlaHrS+XUrgL/gpzTiaVMq8Wq6DK24Au4SQZZtzlcGT/qUfwlkvo+OufE31zAFF6qM
         2YlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r14si33754768wrx.72.2019.08.01.00.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:04:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D24CC68AFE; Thu,  1 Aug 2019 09:04:38 +0200 (CEST)
Date: Thu, 1 Aug 2019 09:04:38 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 13/13] mm: allow HMM_MIRROR on all architectures with
 MMU
Message-ID: <20190801070438.GC15404@lst.de>
References: <20190730055203.28467-1-hch@lst.de> <20190730055203.28467-14-hch@lst.de> <20190730180346.GR24038@mellanox.com> <20190730180452.GS24038@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730180452.GS24038@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 06:04:56PM +0000, Jason Gunthorpe wrote:
> Oh, can we make this into a non-user selectable option now? 
> 
> ie have the drivers that use the API select it?

Sure, I'll throw in another patch for that.

