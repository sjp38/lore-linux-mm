Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ADE2C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:49:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63FA921913
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:49:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63FA921913
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE1EF6B0003; Tue,  2 Jul 2019 18:49:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E92298E0003; Tue,  2 Jul 2019 18:49:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D809E8E0001; Tue,  2 Jul 2019 18:49:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD6C6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:49:14 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e6so180068wru.3
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:49:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BYQm3LQcEmGXcbXKee4JoOgDQC24PyBaC23jztACUEM=;
        b=dtGhzzdWEFRlK00UJE9weM652LciTZ34n8T6RPHixiOqg3MlkFkS4SvGGr8AoRglyn
         k1N/UqTNfBbpyF+bRkcZ6Q7zdqULNGWx5NQHBd6YOJ6zGsjU/PD9JkfAiyrn8b3Bk54Q
         Agi7JYAXKCIx1/Ht2h9vOfSa9taPSIxzC8Q+CaK2FKwX29B2OqrEJ2/jp3xcIN0Bz152
         FfvrAJvtKgA4S/MJ/GU5q0wCFPkjrGEN/I5atj3MWY5POq5eWSpTKZJ4puKQf253Fvds
         USlLW2EAXXp4+tiIiNgWN05A6PDXh/2HDwMik9wldHYQFUQ2ngqEAn4dr+ycBqazZRB7
         af5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVf5okkaIgIx1YDqGkB3SKxqdddiXT/6VV/r2EdRu1+fdxxPyKM
	zXg2XBiSYJl4OZP2t8gjuGz2njc5zfnzOz4gjTu/1iIUwUYMTtgVBWnwP/spRFRuxNiVhJPDki9
	nhl+UsqEpkVuyqTm5w1KC9C4ckrqCCbOAVZbZ5JgGfizPMg03OHc8cg0mwQFI7NSAow==
X-Received: by 2002:a1c:6c08:: with SMTP id h8mr5068640wmc.62.1562107754151;
        Tue, 02 Jul 2019 15:49:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydDyUa1ZqxaFFcXR8c6fwc71/syd9wXILCE7P3kZ7QxdNwJPf5PxwDIBcZ4CH92H2zbW+V
X-Received: by 2002:a1c:6c08:: with SMTP id h8mr5068615wmc.62.1562107753447;
        Tue, 02 Jul 2019 15:49:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562107753; cv=none;
        d=google.com; s=arc-20160816;
        b=DVpGmSgg+yvL5rx6VFghZ2O3fTu4vXAi4yft7iyZQBUMnxnwj+KSrSHkkH8/AMtsru
         23ZOdVorXDL3JWt5H2d3EECZHbVrMxs7ecrYY28VfeDop+L583WlM0EgoxBzP0UqI5po
         g7cDplDZweKHG5uQ9uFk8QfGMnllVOtbVdziHXiUJm8B1GwNi6bf1L/qb4VStygRwzI7
         0RvhLwq5jhnIEJLkYsf8+5cAhNDVm352R7PiW3Fmx9tqcllOBfkkKJ/ig4FkgsYyTgn1
         Fe8Qwn+1BZWpguzEQIIEWzUJlc+DykGCZgOTFHWG4gyPn27SxjkXq4N0qjJGKIuyeYZO
         pY4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BYQm3LQcEmGXcbXKee4JoOgDQC24PyBaC23jztACUEM=;
        b=RSzfeMi4EkEc2joITRc6SzZGeKmjq3e+C7H7HXhSXvyRB52RKQ+OuaX4HHN3eMo9GX
         G4z6pZ0gZoKKroQXkRQ3gJDhLp07m7lINi6VziBqdq4/SfeHyUa0VKO5smhUr0GiRPgV
         uX5BDYpgXgKgJHYDbfxK42Pl40JMpu0krldi5EeSkOhzvd0VS3Hsz06jUb3d29N4Hw1H
         mmEACB/3BIgE5Cfclp9Co/jLG5JLJtPWCbBOs6E75QkQNgUAQEOfrPI2jGplq39oORWA
         Y49e//IqaFWZEV7ISb0f2iMwC9ROqJDeW64HpTSUKNEtpjh2aNHeSJs505LPY1VZpIT9
         FnAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e13si157116wrv.286.2019.07.02.15.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 15:49:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id CAAB368BFE; Wed,  3 Jul 2019 00:49:12 +0200 (CEST)
Date: Wed, 3 Jul 2019 00:49:12 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>, Christoph Hellwig <hch@lst.de>,
	Jerome Glisse <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Message-ID: <20190702224912.GA24043@lst.de>
References: <20190608001452.7922-1-rcampbell@nvidia.com> <20190702195317.GT31718@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190702195317.GT31718@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 02, 2019 at 07:53:23PM +0000, Jason Gunthorpe wrote:
> > I'm sending this out now since we are updating many of the HMM APIs
> > and I think it will be useful.
> 
> This make so much sense, I'd like to apply this in hmm.git, is there
> any objection?

As this creates a somewhat hairy conflict for amdgpu, wouldn't it be
a better idea to wait a bit and apply it first thing for next merge
window?

