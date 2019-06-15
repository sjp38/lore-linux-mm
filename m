Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC0E1C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:20:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD502184B
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:20:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r+pPrVqA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD502184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 493CD6B0005; Sat, 15 Jun 2019 12:20:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 444368E0002; Sat, 15 Jun 2019 12:20:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3324F8E0001; Sat, 15 Jun 2019 12:20:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 100436B0005
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 12:20:09 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g56so5070142qte.4
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:20:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eX2SsF5NLCHpL5vWayCPj5W8iQ02n38k3DDKs0RQPsc=;
        b=Vox+0eb6vamboDd/tX1EIGw6Ly6ktbAtLoSHIFZCuOwubijmtSMdQBTiIwX6080mEz
         ZDTNvXCIIp/QxeUkEuCGp52IlxSMdSWS4d/FieLA13Wh1fcKzRQGwSVkHJKr/IXYtfdT
         0/2iWTULoh3l+cOTLshUzI5lrjhzZ6Qs3ZMDBx3nrJGdXVCWNwbD7e5DtF8KMLVqqCEP
         +6IqGFvYJIoQ/j6RvVlbP7iuSKtEixcZBNkOAsxyY8kj76rOytYdQ+6MaHv9SZxEk8JV
         qGEvD4Qq2PE/TPciMRt+1xF6pvyLks58y9M1lUIYF+GyU53DzYXb6KbqSMlfXySyU/za
         SUGg==
X-Gm-Message-State: APjAAAU0q2R3TBGZ1tAqSx0iY7/rrrtNt7uLWyrfWY1Lai0EGtMOIrgb
	/ViKE6d0t9K1m70u5revr5LuZ56rbzyuzKA/Rrhovy2j6RB0rIGMSRhMlGrBL5bMmAx2RRfvXwF
	XCFMfPFQQMJGKYsogzRNBUdv16cxzV964QEWFE7rldRrSvZsxpBNdyXqCh+A1Fgc=
X-Received: by 2002:ac8:3742:: with SMTP id p2mr78164402qtb.121.1560615608800;
        Sat, 15 Jun 2019 09:20:08 -0700 (PDT)
X-Received: by 2002:ac8:3742:: with SMTP id p2mr78164368qtb.121.1560615608351;
        Sat, 15 Jun 2019 09:20:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560615608; cv=none;
        d=google.com; s=arc-20160816;
        b=0X+M33YYObmu4are2/+3h+qe+aZiRE6K+921wvjaVQbc1D8Vk014fXFAJPgxkCEnHi
         bxuIRLWz7aUwYFWv3YEj557ie+Rq/BTXBV9pTEuba8ys6Te6bK8FWYkqeY6T1pr1y6KP
         itFvXrgPfWnIozDF97pwDneJw78G7d/vywi1PG2QNKgX6RDAQYoN63x6EW5jUdmV3ckx
         J6N17E7Mzpqe7WhY22DzewvaYQ/LaXBSSCwSbIPa6103TBp61V4wkyghxEwiuB9dPqBM
         jz5JKriAxH+gJ0KJuzpiHFjiB4XB7FjY0GtDxcXo9OEbSILKHRSVW/PJ0rc6vgdhdgdB
         4VJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=eX2SsF5NLCHpL5vWayCPj5W8iQ02n38k3DDKs0RQPsc=;
        b=eu8npNDeJSRWq4HQn/65bhJ3ZwOxcI1baVvgwxlFq21Q98uDN4uGfK21cW8qqx7j4b
         3x0APVwIUnqxoIShJylMyuGCr0X6NiOPuVTRLNwQIqgYr/I2k73SdPpOIpBB+829hKPQ
         pX6XIq6DaiRitc3HMCmAiiSQwJDe6866tvRVP/jP0V9oeBkQ7R7d3oBmnNedk2piScQL
         QHay6hcwkqEVaNasu2b9xLqyCmIyPAahueAFW8pbOUx4RnlbHDaittroFu9u+2hFCTGW
         CMR+5WNB2OfY1/x+yBsXFxgKwFgyYOsiAoIgxdxn8O9bkw47c5rd+z9zS0Zd8WFPJ5Yc
         W6jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r+pPrVqA;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g15sor9465433qtc.63.2019.06.15.09.20.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 09:20:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r+pPrVqA;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eX2SsF5NLCHpL5vWayCPj5W8iQ02n38k3DDKs0RQPsc=;
        b=r+pPrVqAooiurT+r/1q1YOmCwatUD8JpCV7NTTno22ito/5zCfh0NLhl4iMS76Apur
         od3597crTGgH49Iea/iv0Hn+0dlF/nDVBakGN4yUlzBbBCV7oNn3R/Bmj4uooW+AvzSq
         CoDrMHiPzNMxHFiIA2AVcMJEvoDu3Sre8J0jWQfHXmstDyO/JzqBUfsw3itDzLJSBcrs
         ygygJfj+TtVYs+wlFzjkcpQDIS/nIKFEb6axYc6x/QK0djwkF2fCJNAc/y61BV3vka5B
         8mAN5LXYOY+ViRwZe6TnrbIBxANgmaxXVVIjq7dZoY1LghPPCg6/kI93rpDyZAqEeGiF
         eErw==
X-Google-Smtp-Source: APXvYqzYKArsrn7PLBHxWCNzaRPRtCR+Ia5hnnBaEJfJot7DPD4U31BQXQuIuLwjHEBGGLC6yj+Wdw==
X-Received: by 2002:ac8:1e15:: with SMTP id n21mr59570805qtl.20.1560615607770;
        Sat, 15 Jun 2019 09:20:07 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::673a])
        by smtp.gmail.com with ESMTPSA id 5sm3807720qkr.68.2019.06.15.09.20.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 09:20:06 -0700 (PDT)
Date: Sat, 15 Jun 2019 09:20:04 -0700
From: Tejun Heo <tj@kernel.org>
To: Xi Ruoyao <xry111@mengyan1223.wang>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	dschatzberg@fb.com
Subject: Re: [PATCH RFC] mm: memcontrol: add cgroup v2 interface to read
 memory watermark
Message-ID: <20190615162004.GG657710@devbig004.ftw2.facebook.com>
References: <0f1be041f8de95603753ffe989bd25069efa13bb.camel@mengyan1223.wang>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0f1be041f8de95603753ffe989bd25069efa13bb.camel@mengyan1223.wang>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 04:20:04PM +0800, Xi Ruoyao wrote:
> Introduce a control file memory.watermark showing the watermark
> consumption of the cgroup and its descendants, in bytes.
> 
> Signed-off-by: Xi Ruoyao <xry111@mengyan1223.wang>

Memory usage w/o pressure metric isn't all that useful and reporting
just the historical maximum of memory.current can be outright
misleading.  The use case of determining maximum amount of required
memory is legit but it needs to maintain sustained positive pressure
while taking measurements.  There are efforts on this front, so let's
not merge this one for now.

Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

