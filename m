Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E960FC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B71C52187F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:00:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B71C52187F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48A706B0007; Thu,  8 Aug 2019 03:00:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43AF86B0008; Thu,  8 Aug 2019 03:00:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 303786B000A; Thu,  8 Aug 2019 03:00:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEC226B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:00:06 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b67so1413324wmd.0
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:00:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GdyI6jRUHulfTu/R0/Do4ibTZZ+yRgVgvKN+upP0+Zk=;
        b=qk3cIvvYTG7h42kA0H38ttVxdiIk4DV9ySaOn1pikLwn8M++CC4ntMgjwGttIY7MEG
         jy15rnbBnED/UARzNZ+fm9TBwZ5AR8LiLUPooZUQ0WU1YFfa/92ar8hIwKXjdEI3V3+q
         R76v1PnovLO82XlpNBxHp6XATOu9LhhxL2qt+BMy7jM94yiw8HH4WNkm+qeH4d/ptaH0
         Qd0NVyXrAOs8dr4h+9i78/oiqKnrUxmKi98pQbZXM7ra8RhYdEYVxUgAb5iwdl62Higj
         ZEkNd7vygB+NoEOxpTGRRPAiUU/uwZINDacEc9le0tVl87Pfgpwgll9CvpK5BUArF5Wi
         nvVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVlo5dycpBCc+VFgZh8m0CEnXsxWuIAvNFPwFoSerKBQxqTmAhZ
	rBip+rgPNqM4CMvfda7U92COjaq7beol4UYlYZoPe57Y0neaCRObZzRvayDMfpN+CJPygjtkzH9
	wf1wCEc7qQzFFj7SDdlqg4cGXgD3Iia0nEWeerb0YcB15iFcegEJf3udC5qaHfWCWKw==
X-Received: by 2002:adf:e8c2:: with SMTP id k2mr14565747wrn.198.1565247606517;
        Thu, 08 Aug 2019 00:00:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2nC46x4aHRGvKDYjVmsS11Ofi942XTYFqYNR89J043UrMACa8816vM01euwCm1keSTC3B
X-Received: by 2002:adf:e8c2:: with SMTP id k2mr14565691wrn.198.1565247605917;
        Thu, 08 Aug 2019 00:00:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565247605; cv=none;
        d=google.com; s=arc-20160816;
        b=sVf028KHCxv75YUf3qE7dLxaH10ZXmSsYCSgT4iuu9Z9n0YWuhlQFUvQ58r4cJLBML
         ag6hRUJelOlylYJ2db9e/qHau/u2zYFuGRkCRtxpFTCE3OxL4EuboxAgay3xl31Xotsj
         kYU4wxi4hJcJWXiJcvcCKb8+2b2Rez0aTj5MDNr+Ozjdh1IWcyxq4PPzZNbY3dvx4NoB
         BPWZ+IrQqwAQbfj3tpM9UbrnSQ62FfespbGbmWX0x/gFjiVKeMr7LVTlmUQ22APIB5Oy
         HvnhQxwmpK3mEyVc2WmLKZzVPKa0sWo0zkzQq3O72GRiAwD7QWzKrxoVvf9DsrlpyC7j
         IoHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GdyI6jRUHulfTu/R0/Do4ibTZZ+yRgVgvKN+upP0+Zk=;
        b=AR4djK6cX+e7eFqvDN2UaKuBj3exiEOc3jxGGXlDjBrkhq2Pe6qRukludA2tMbWL/c
         RG4LTAVNCILz/WZDf/I/U4KbCMIq5SA3yhA9YyD6YghHdNwJeGdJcUkah3/eedCmthti
         BsshTKRtXZxGYhVpfJ6ib9OOkKppM8TdCvS2C+a3OARJsiWXo0ElV8AzkYtA4dIfEN0V
         5YzpWkW/W+ea6HJ9EHEb5Aq6SCBHeDP1yKJhTRUc3g/HKWNQa4ebxdLuwkyX7254h8+R
         eCsh2YaGRmPhV+XN3pLq/VbSb0AK+p63pTX+WpqBIGOVZCVunq8Xyf/cZ8tYLtq7TyXr
         RUsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v20si1005162wmc.131.2019.08.08.00.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 00:00:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9DA2C68AEF; Thu,  8 Aug 2019 09:00:03 +0200 (CEST)
Date: Thu, 8 Aug 2019 09:00:02 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/mmn: prevent unpaired invalidate_start and
 invalidate_end with non-blocking
Message-ID: <20190808070002.GB29382@lst.de>
References: <20190807191627.GA3008@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807191627.GA3008@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This looks like a pretty big hammer, but probably about the best we can
do until locking moves to common code..

