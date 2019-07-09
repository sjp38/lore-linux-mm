Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D91A6C73C46
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 14:30:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A71222082A
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 14:30:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A71222082A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D58B8E0051; Tue,  9 Jul 2019 10:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 284F48E0032; Tue,  9 Jul 2019 10:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 173EF8E0051; Tue,  9 Jul 2019 10:30:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2CB18E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 10:30:40 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g2so9768343wrq.19
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 07:30:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=P+yRqMXCDdA26EpfFLvp3gRliBzVpds6KzB/NccDKoI=;
        b=Hkj5zg+AQ7BArG9LlUltmj+GTBhfItJ4aD7uNQOgi96V+hTwVaucd0Rhg691rc3Pgu
         /TSaDI7qgHXkmhYQKjJU7XRg/OdK+UMpbtZn06N0+x7W+0xyJu2VQhy6Vgb1ZgYoWyVL
         JuE5eivTD0eg5o7j8eMcLMgBbrACn1rUJhLnsIW+rFoPbwoFzUYQZlM3BmapZSUWDa2V
         UaczDluVHWGOLdGRx+uTxlIFtq6zCKx2pwkbfWeqaxFev2EcsNmWzhQAEB2kr6cIwqNf
         +beevFB7RVuXFH6CXQNHzivcKEChuv+uhMnYRDrGvDwjecTWYHfjF3vlXhtzZeweJo+E
         3S/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXLVbwaL1X0cI3R8Pv7fr2xr5EtAoTWkQ7BdziTNYLrEKApPysT
	tqrHqe6adSb1/+5+2bbTUBTxuI1IQ178lEsJdn3+0UqqNfFj+OZx3MdBNxp2QP8g6Jq0YAA07Hi
	GGaaklhzB1Ky45PTyVEpaeLx77GksuiCsHxOQ3kY+a7+tw72z7cOes8L+OzDPbGtNgw==
X-Received: by 2002:a5d:5607:: with SMTP id l7mr27189184wrv.228.1562682640438;
        Tue, 09 Jul 2019 07:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuQ61gD7ULAvp2Vr5tb8R6KX71sjSs+hdbUvg5r9OfHvy2C8VzYxH6JEKBhL4EAYTjQ9BV
X-Received: by 2002:a5d:5607:: with SMTP id l7mr27189125wrv.228.1562682639656;
        Tue, 09 Jul 2019 07:30:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562682639; cv=none;
        d=google.com; s=arc-20160816;
        b=NVAKAqxekTE0SP7THc/GxlmqssvySXN3k8cbbVz+JceJzutsYcwJzTvJmcQLNz7MYV
         YEgzckpV6DuTw+6LxvKbmfT7mD6cJWQDCpM90RFDC+3nnwa/4r7UkQypdFHGjWjBV3l/
         Unzw0y+ySJyuim5CfamJEe9aE7RYrPuo/2m6LOiyVDNM57cWbJLCI861B8mk7+nBY+HY
         FxuviZBFTIoNXHdsBeFdYDPUE46AyMc2JucKYpFmVhvyGw6spPNzO7+SliqaZLqgjd5o
         vaWsFpnOaTbmFdEYW8F2CnMIC93GQeRTwHrfYIWaAPQ80WwDv/yjWJt1VrW0lZgnGA/P
         HZZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=P+yRqMXCDdA26EpfFLvp3gRliBzVpds6KzB/NccDKoI=;
        b=Pp/mDVbGM90sS7o4ButcEXgQaQHMKal9t4tj4VcrWSro4cuF4lxFAeurnZJCs0d3kG
         n/mQPR9J8HpGB4o2ZHNIjI44T4xZWSgt4chPpsAnWszmsyGZKZZWcX/OOZQc8bkVTnT3
         Xt0fLPwXpBc9PWkllAVOFpBgd6W/I1lyeC5yAW7QdTqJi80u2WtlSD2uLYxjEy9KhEwC
         BBuozcB7RN2lpR3BSZwtHw7k3POYXmLKbavgo4wB4+XPPTTa9jfrkFffpqS67Rph1i5J
         vfzdg5aps++lF+KIgWgeq53IGukDLufX/VVQ0oM3P1gp54xe9JM+CQyC/fXd4K9U9Uc4
         mYrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z15si12545799wrn.280.2019.07.09.07.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 07:30:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id C51FA68B02; Tue,  9 Jul 2019 16:30:38 +0200 (CEST)
Date: Tue, 9 Jul 2019 16:30:38 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
Message-ID: <20190709143038.GA3092@lst.de>
References: <20190703220214.28319-1-hch@lst.de> <20190705123336.GA31543@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190705123336.GA31543@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 05, 2019 at 09:33:36AM -0300, Jason Gunthorpe wrote:
> On Wed, Jul 03, 2019 at 03:02:08PM -0700, Christoph Hellwig wrote:
> > Hi Jérôme, Ben and Jason,
> > 
> > below is a series against the hmm tree which fixes up the mmap_sem
> > locking in nouveau and while at it also removes leftover legacy HMM APIs
> > only used by nouveau.
> 
> As much as I like this series, it won't make it to this merge window,
> sorry.

Note that patch 4 fixes a pretty severe locking bug, and 1-3 is just
preparation for that.  

