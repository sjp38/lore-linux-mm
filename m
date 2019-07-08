Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46C63C606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 18:43:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14E46216FD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 18:43:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14E46216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A94218E0030; Mon,  8 Jul 2019 14:43:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A43128E0027; Mon,  8 Jul 2019 14:43:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 933B18E0030; Mon,  8 Jul 2019 14:43:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 465918E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 14:43:54 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id x2so8546427wru.22
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 11:43:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KPpt+jBXK7qcwKICGb6z1HCTMqPcHpL2PcTKosbX94E=;
        b=iUjHIOI7BHLnNsnHnDL0HNgvTo2kUFtO467YEtuX4Sx5j+KFMlS2NF+ZyxYpXr8yBP
         Cc0d0bRmhbyM4PwS58g7Ju3+6qAmhgwHFZ86Y5MN3LPgNJinXIoF5ELZT908yhjgC8uU
         ERHq1dHUtpc3BKb4/x1ELFVxDjeHAT4zLK8ZKdLMwcKG1JdCUb0Uc3NXGA6eLvIicFni
         5UH5tp07I1FpgocvWDvgzq880LEh7KSV5IKYUvshPjHfjUFlDXNL9P43AYNZjj5MnPeo
         43Chca/GNVRtIR/qM8dZS1Fo6XplYiqE/+XTLMhQySfrc1KC/1ki/S8uHWH1nwkBQfp2
         aRtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUD95k1Pl2OYihaL5cMI/MWmI4BD7jmA/l3qiMdvBfDsU4EBtgM
	FyQmwbaiMU4++i6iKuLb5UMLIj+tnv3iXbF1N31i56KqqYuTWUgYwVuJ/uvLoqNmjh+xYPJm0IW
	5oR/WH7HnKV4CPijMZyk+XKNZQkLFvZCcYrZW6m2vY7ngsUxoLTm5CI770vtmr5crXw==
X-Received: by 2002:a1c:f009:: with SMTP id a9mr17330703wmb.32.1562611433809;
        Mon, 08 Jul 2019 11:43:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyFgkg1U0wkoSU4v3qaOJEMfTkqx+0aPGAXcGY7n9fk7Fw8LoBUjGCeH0wOslvpqwHoNzN
X-Received: by 2002:a1c:f009:: with SMTP id a9mr17330664wmb.32.1562611433007;
        Mon, 08 Jul 2019 11:43:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562611433; cv=none;
        d=google.com; s=arc-20160816;
        b=U6/6IXfDLsEt9FrznSJxNlmLmwWRf3PQyiMkakpqXN2tl8bVE7IZlJ6Wt6wMVgdRuQ
         sEgjm8p+2Cm/6MvYTOCp3lo1HLNrRwDDaxghfezynmHq8CfU8VCRjV22Ra1EPQ8K2dTx
         UsCa5f6D4EnvqW1DVHCDObJdq0q8ZvoFpNnOmB2rXmStZ4At+pstafwUcEJ5FeHEwIRk
         +gqPsJgumva0NL1BBhjkTvdt38tBsPpm4/MyI79bztYnWvT2bf8gJay6VZ7QGc60HvDF
         1ZOkJMlqPrlkZ90af8aVLxECcUcrjwADfgvYFky61tvoCcBnoho4vdmdWapblOlEcRt2
         8NxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KPpt+jBXK7qcwKICGb6z1HCTMqPcHpL2PcTKosbX94E=;
        b=GLtnba79fzRiWh+ZiyYGeQE6ib74gN/o2CLNyK7tbG7KLRZ6MmRUuBKQCc6XfOLtIw
         q4Cf31usYzOhC7SAC7gepdufyVSeUYqf2RhaRCoX3YCOEVlrx0asOOu/8wJ4St01KZxx
         JfmCEynRX6QxzcQZAJKXvEPec6PhIr682XsVnBYSqv9ED5CIblcVDdFvF+nBrr61j7v2
         FZcWWIAvUJW1T2GRRYV7C7ueVLEIdKx4I01AhTZY1rf0meE5MfCERJ6ZUbGSU0vXZIDd
         dAbCde0Sex1eqzIduqHDeXlQySmy8oB7Xsu1DLVRPdHXFFa/CHr/5Xa66vFnNurEeN6Y
         NHQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q9si259190wmd.184.2019.07.08.11.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 11:43:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8C7F2227A81; Mon,  8 Jul 2019 20:43:51 +0200 (CEST)
Date: Mon, 8 Jul 2019 20:43:51 +0200
From: Christoph Hellwig <hch@lst.de>
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
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
Subject: Re: use exact allocation for dma coherent memory
Message-ID: <20190708184351.GA12877@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190701084833.GA22927@lst.de> <74eb9d99-6aa6-d1ad-e66d-6cc9c496b2f3@broadcom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <74eb9d99-6aa6-d1ad-e66d-6cc9c496b2f3@broadcom.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 02, 2019 at 11:48:44AM +0200, Arend Van Spriel wrote:
> You made me look ;-) Actually not touching my drivers so I'm off the hook. 
> However, I was wondering if drivers could know so I decided to look into 
> the DMA-API.txt documentation which currently states:
>
> """
> The flag parameter (dma_alloc_coherent() only) allows the caller to
> specify the ``GFP_`` flags (see kmalloc()) for the allocation (the
> implementation may choose to ignore flags that affect the location of
> the returned memory, like GFP_DMA).
> """
>
> I do expect you are going to change that description as well now that you 
> are going to issue a warning on __GFP_COMP. Maybe include that in patch 
> 15/16 where you introduce that warning.

Yes, that description needs an updated, even without this series.
I'll make sure it is more clear.

