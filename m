Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4829BC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10329208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:45:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hNvZT9V5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10329208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E51C6B0005; Thu, 18 Jul 2019 11:45:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 896728E0003; Thu, 18 Jul 2019 11:45:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 761758E0001; Thu, 18 Jul 2019 11:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 575976B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:45:57 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id v3so31300873ios.4
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:45:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=beUSWoZXSEseo18OGM8fyy0fbR5wLVgyQ97N7VlKnlE=;
        b=e9PFodJh7Ck6wwbwBzdrgbFxgTfe8xLrARHcbCbicyaGHgrtqSQpVJmE0p1znG0RQQ
         VuqQBqu1FepiQJDnz5OJQm6IRr/4tAIYCmQ0mveYR6ID9ankkycQtIZ1lIoEpCTwSSl3
         +t9fItzemscHfGxdOuk/jI4FDUxiDAz8z0qaKLxWh4XrdRoh6cb38lhXYxiN/6jSGNGO
         wflJHFIoSfXABlP8aeqc61SZhGXc78CfpTuPu+EpprOCWd3kYyEQ6vQWhC8mclRqV4KK
         QjUYvuKawQT0wKgI8GA99LiFJsyK8ymX+eFhmbqKmBz4emaUIVOFHiuUzwNPneoHVNNo
         B0ZA==
X-Gm-Message-State: APjAAAX3cxq8ZQulaq0ZguCCSsj3o0l6o1XSv2bgDRike+lr4IceyyKa
	CYln8XA4XT8M8DqAyBd5iPRNvvKrLxIqSQhwt/9bKEDvTxcVNkcZcDxlhv/70twX5KP2Me794oq
	h22cNA1lcehPn3xAsqateyeF7JypcSf8HTwMgfx1hJP9S0GeOto4Sw/+JIHl/ahyBtA==
X-Received: by 2002:a6b:ed09:: with SMTP id n9mr41978826iog.153.1563464756688;
        Thu, 18 Jul 2019 08:45:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3EcUHLjUEHnBDf0eNksA8ZuSPv0vk98PUABdVtjsJphUdUO3jZ6mXmn4qsTCZMuAH9Grf
X-Received: by 2002:a6b:ed09:: with SMTP id n9mr41978774iog.153.1563464756066;
        Thu, 18 Jul 2019 08:45:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563464756; cv=none;
        d=google.com; s=arc-20160816;
        b=B9U82yfHgHkmRzSYQe6SyWOHkuGr93ubfdjHxeCNrc9lF0ymsmWV7gMcV1fwU3epSY
         8GJn3fEmHlDvirbArCabKKMkR4oG8YJ/RdLFIOJ8IJux/oo+Spj1xhaiNLkLQJX4+9St
         P/IE1Vr+Qgq/AtVxZF18KIgZwN3WpNHYSdeK4W8AwfRiBZ6uD++OwPIKz7M8fgrh0Ocw
         TpQaD7u8KJjTpyeOer7Ay196xNyHePdnFy7Ipfuyr2RpMnaNlAJcj8FKkQq/lPSVSqMV
         Kavi1/ct4Obcngi/wQmPCikbGqrvyLipesSrirx3epRvxFclLv+mvceTdHSth5Y3Ky1G
         gSMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=beUSWoZXSEseo18OGM8fyy0fbR5wLVgyQ97N7VlKnlE=;
        b=o65EUS/k0YF+UCOm92LNlB3OBfuQQI5FUrB63PMBl879qdElrWChXYub+QxZOW/9ps
         DTPQCIcbPMgZUVaO083KiC+DUwZO8aHIzVMh7P7kW4yst2kGEE8zM2LysWT3c89lDCCZ
         p13G+4BgWt+Cr9P9/k6CamxxvZCXMRg73hJshq3ycWBASuwE2tflx1wFIyg6iRwadKDC
         EypcCusSjRflZ2kYF7sKDoB2fYPnkuG0MPIGUjBBT3z0HtiMz8EeA+TCBnC0u3jVxHC/
         fqf+0bpWfD7hr5BVTUl/K9XM5bdp14WTsULNh4N3QOP5OY/X8iHk5TxfOogmjcwlAcHq
         TdFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=hNvZT9V5;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 4si42543675jai.65.2019.07.18.08.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 18 Jul 2019 08:45:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=hNvZT9V5;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=beUSWoZXSEseo18OGM8fyy0fbR5wLVgyQ97N7VlKnlE=; b=hNvZT9V5N2E+RzxuWYwVvh+QeX
	MlpOSJBgt5+S3mz8iayCbDY5ygRW3i4nxp+0VHq/k7pnAHpxzTs5OMbB96e6AACNwjKc21XMPzIMa
	6Gi5u1n8z1M/TEcQi154M9NJ4N5XAgkbKSTxJPgyFrOCl9G6ayweHrp4mr2wJfUa6MNYWoPTTSYi4
	XhBsHzAbyvYzDPt4Xfip+KrB3kHQb+ghbZuB7qsGHvu7yd1x8FBfAb5bfWnraTbSUP5xWvKjSX2iY
	KGp3ReyEy0xtmA9aqgdK/FpIRExp4j5AizWZMWe/Tl2j8kfNCqalQqGGomtJLwRXbqrbJ5Tte9adr
	3BaTgl6A==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1ho8b4-0004mG-6e; Thu, 18 Jul 2019 15:45:30 +0000
Subject: Re: mmotm 2019-07-17-16-05 uploaded (MTD_HYPERBUS, HBMC_AM654)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 Vignesh Raghavendra <vigneshr@ti.com>, linux-mtd@lists.infradead.org
References: <20190717230610.zvRfipNL4%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <4b510069-5f5d-d079-1a98-de190321a97a@infradead.org>
Date: Thu, 18 Jul 2019 08:45:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717230610.zvRfipNL4%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/17/19 4:06 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-07-17-16-05 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

on x86_64, when CONFIG_OF is not set/enabled:

WARNING: unmet direct dependencies detected for MUX_MMIO
  Depends on [n]: MULTIPLEXER [=y] && (OF [=n] || COMPILE_TEST [=n])
  Selected by [y]:
  - HBMC_AM654 [=y] && MTD [=y] && MTD_HYPERBUS [=y]

due to
config HBMC_AM654
	tristate "HyperBus controller driver for AM65x SoC"
	select MULTIPLEXER
	select MUX_MMIO

Those unprotected selects are lacking something.

-- 
~Randy

