Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FF3DC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:49:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2AC42133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:49:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2AC42133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 195B76B0007; Fri, 14 Jun 2019 10:49:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11F476B0008; Fri, 14 Jun 2019 10:49:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F01A16B000A; Fri, 14 Jun 2019 10:49:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B6FFD6B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:49:27 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id y130so709660wmg.1
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:49:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mYwejnkx7tIy/hoHoGqrY/4MGqFx1knqqZSdVOLvNc4=;
        b=B04osW1mTx4du/oN4lkUc3OoO+5OFomu7Zy/n8kBSsUsxu8v8+M+ICsPE1iaiDNM/X
         r6ESWErk5ymjGAtIgI8o4LhIsUlx+hbjxMU7SrC/YAPDND2aPKYldAAGSrncOSeh8FYX
         /0pws0gtEqCQcMvgFKH1KgcSdZfPa3S8jSdcTj3LVyBLto/rgVMd/6Ok4fgvsrrV3eqg
         rJn3MpXxaF6YDxXOJgGPnCW6aqdZsvwNxIH4rGO6XHwcgC3/uCt/trNXBDYVckJvuqTD
         fIAlP5pYMZrFalvr4bdcCsZ4IsMds7iHJl/LGrzIZP3kmbpU1KWOOuUI3m0/8djiDEgC
         2sFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWI7MPx+V8ve0JwYYNopC85Npi5MvEVC+/OkkmSZMPY/HQuvq+M
	7uShturPVD3Du213x5+Eq3V0qYlm9f6Eo0Wmfk8QtO6WA6AkUwxAMSx9b1a34swqe5C4YRtTg0w
	MEIQ3NMt65DBC1+dqbIWO2nKDUrOu4rNx8yk+oPvSZ9p1y9q1QLOKJLfTxguZW6u9Mw==
X-Received: by 2002:a7b:c144:: with SMTP id z4mr8736121wmi.50.1560523767342;
        Fri, 14 Jun 2019 07:49:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrA34+MdUhftrGB0mTux/k6gN4QQabf8p93UNHWpe7swx92sEpEbeWk6/inm0oUCjmnl2C
X-Received: by 2002:a7b:c144:: with SMTP id z4mr8736075wmi.50.1560523766359;
        Fri, 14 Jun 2019 07:49:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560523766; cv=none;
        d=google.com; s=arc-20160816;
        b=KWu8ng7qdwQzFx+5fKM10+Rq43K09EuKa9n7Eh76MirYnAB3s6BEuYaDkAO2mzHqhi
         XHmrH9csd/y2p+IOWOvJ+Gbgiko7afvlX3HIOWGbMLbUga0C11Dug+j4Cv/iYEnuCWdf
         DOZnFdFKdfL/8bk12+X0XndmjTaMsaYmbuiJTv4geo8Altp5iO6hHDcc6wVyDN0Drfah
         /MKxvkYgzUN4JOSIzfnQqP8RJjmOulR8a7FYzQva+vtG/V+9ZbOhg0qPpIHqY27EDVg2
         EISBPVIPyQkGgATw2Drvxummc6svrNAx7jtAeRjEKWEKifa3JD8V5QgAErvLqkjAaWnN
         7iBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mYwejnkx7tIy/hoHoGqrY/4MGqFx1knqqZSdVOLvNc4=;
        b=QRbrXf1iURIh+50pwsMrP4GH7Tqis3qewtE+M7K8TBvilqRVhvPaCW0BXUXjlwEuab
         rtQhP7VRe7GzfXFxvMcnGMFzDI999uOMDlim8dbhZfaGR5ztRPwgcSFqE+AzG1fyrob1
         yh2yr8CxZcycEld8amlaoeJmK7cIFhRPOS6cio+2XMgOPviBIQ3lIfXGDqEWp4pvKXvx
         nM0KUUMO+0KPEiHR48g5GKJexyY7JZU8OCgj+s1SsSW0H5Plh7DZW71ECSSYKFa4m9dS
         h4CZbb8shZchMaFw6ixc5noSmX6AyYzqvcGyB04E87K6Sj+C8EhtR7jvyoz2w5DqdqZF
         XWEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n3si2138532wmh.26.2019.06.14.07.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 07:49:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id C373F68AFE; Fri, 14 Jun 2019 16:48:57 +0200 (CEST)
Date: Fri, 14 Jun 2019 16:48:57 +0200
From: Christoph Hellwig <hch@lst.de>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: [PATCH 12/16] staging/comedi: mark as broken
Message-ID: <20190614144857.GA9088@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190614134726.3827-13-hch@lst.de> <20190614140239.GA7234@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614140239.GA7234@kroah.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 04:02:39PM +0200, Greg KH wrote:
> Perhaps a hint as to how we can fix this up?  This is the first time
> I've heard of the comedi code not handling dma properly.

It can be fixed by:

 a) never calling virt_to_page (or vmalloc_to_page for that matter)
    on dma allocation
 b) never remapping dma allocation with conflicting cache modes
    (no remapping should be doable after a) anyway).

