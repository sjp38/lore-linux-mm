Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F19FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8AF02171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:46:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8AF02171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563968E0003; Thu, 28 Feb 2019 03:46:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EA1D8E0001; Thu, 28 Feb 2019 03:46:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38B0B8E0003; Thu, 28 Feb 2019 03:46:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE7278E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:46:25 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 29so8047327eds.12
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:46:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eMX9Ih1FvXS8dgo3VxjBZxhpd7dSwUYcrErGaIp5/0o=;
        b=o8/wUwofPgKjOfjtlTTBTJOG82yS+dwbz+neRP5vN5w+sFtUGQeMPvEyIZYWimbkxo
         3sdiViqjxrcuvlKL8EvvZb/+UuHMeILqvnLb2PosbLLYOC+hnFmqhY9rPpKP2+zyEDKw
         rhA9I5z8GavRQtW2o1/OOpaxkQzilMNRBY6B5E/LSFZqevVKDwklRDAOJJiTGQuVSNb8
         AYPF+GmiHqWLLSfg+LN0g8MJmjn0OEcNqERmyY+1rtA+g1U4VL6XP4XQM4CfxgN03EMm
         354CtedKA+dYP32xO4UFT78CuareIWbnZHwf3EYKsAt9avI2X8ynlFBjpuXebFpI7FIa
         Ho3A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubvSMQ2AY4515y4vggPEYop457w3+diAQ3364/4tNXYQhZ7pwaa
	ZuAyVJsxFpCx9Ng0US/QBxomt4mUeROry1MHJhlpMFe6/D0opS+6v7LYtDBE2yJBkrSzCJ0HZGn
	PuN+ZjJZRdnchywFXQQxhg4zwUmBYxW3ogPiCnFn9TNAa10TpuKOHs5ha7g6f8Ww=
X-Received: by 2002:a17:906:72c4:: with SMTP id m4mr4607427ejl.214.1551343585393;
        Thu, 28 Feb 2019 00:46:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0HQ22WA8dbLf3o/ETDXl4JNvvwzMceZwcAAizETuldwleL96wg64PSegwdoM+jdE/M4C1
X-Received: by 2002:a17:906:72c4:: with SMTP id m4mr4607368ejl.214.1551343584194;
        Thu, 28 Feb 2019 00:46:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551343584; cv=none;
        d=google.com; s=arc-20160816;
        b=yOGvB7K72kTSNuznKTSbjQ/x/ZrSknUKWcD/mA3RweBhIiFZZzBiUIK558sOPjPJ7g
         upLd2RueUskglxEe7aJVIuE2WPRAN/YnTYs8QsBSwaN5QP08PTsXG4c0CJT1ADRMbSVa
         3AzjuAXnsMp17fMl03F7B2JFxhbatAAcDWDJ6HqRHfHO1QQoxtb2lXuHZAdK8DEClVqo
         mShV3L+e9ZbChumoQ852AfVY72MPQCvxrwSrGsdPUc+VmhCVpe/gDhIj9BF4b4PJFEcv
         PRqKW5nZ16N2tRyZJO8ukYpFd7qLg0u0afhRyonasuzp8Jy1t5yhIXBlI6TF2phQd3he
         LICQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eMX9Ih1FvXS8dgo3VxjBZxhpd7dSwUYcrErGaIp5/0o=;
        b=XLLYfd0K+IBkDrNEdhTO4pFZqElecvP34qutznqctWTkmyTvmIdskKfj72gTM4rwZs
         Rt28siwrq9xdgnPHVMgGED7tiD2rkX/wcSLu6w7YW2rw85PxnyBRQRsGxp5LJF41M0fa
         zK2iOLXPeZV31pRVqv4VNlLZYCO++eDwVDfLZH1bhiAfiUEKye5wdGwkK4Ehlw5Ninva
         qZA2ZXiszp4VmB9FcBj3NO7x4goIWu/z76Thaih6hKHCjOYNHMWA4vO4jWvhBuwpdVIj
         bWQJtGE5PcuyxWwC2/4KJJPZiSwR4cWwtvggSI9VEr5afQJWr/QiwZ3nw3BLnyN3qlQb
         e6AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si2831132ejf.104.2019.02.28.00.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:46:24 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4FB8FAE3B;
	Thu, 28 Feb 2019 08:46:21 +0000 (UTC)
Date: Thu, 28 Feb 2019 09:46:19 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Gabriel Krisman Bertazi <krisman@collabora.com>, linux-mm@kvack.org,
	kernel@collabora.com, gael.portay@collabora.com,
	mike.kravetz@oracle.com, m.szyprowski@samsung.com
Subject: Re: [PATCH 0/6] Improve handling of GFP flags in the CMA allocator
Message-ID: <20190228084619.GT10588@dhcp22.suse.cz>
References: <20190218210715.1066-1-krisman@collabora.com>
 <20190226142941.GA13684@infradead.org>
 <878b80c2-93bc-9ffe-7b2a-6fce97f5bb25@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878b80c2-93bc-9ffe-7b2a-6fce97f5bb25@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-02-19 16:12:30, Laura Abbott wrote:
> On 2/26/19 6:29 AM, Christoph Hellwig wrote:
> > I don't think this is a good idea.  The whole concept of just passing
> > random GFP_ flags to dma_alloc_attrs / dma_alloc_coherent can't work,
> > given that on many architectures we need to set up new page tables
> > to remap the allocated memory, and we can't use arbitrary gfp flags
> > for pte allocations.
> > 
> > So instead of trying to pass them further down again we need to instead
> > work to fix all callers of dma_alloc_attrs / dma_alloc_coherent
> > that don't just pass GFP_KERNEL.
> > 
> 
> What's the expected approach to fix callers? It's not clear how
> you would fix the callers for the case that prompted this series
> (context correctly used GFP_NOIO but it was not passed to
> dma_alloc_coherent)

Use the scope API (memalloc_noio_{save,restore}) at the scope boundary
(lock or other restriction that prohibids IO path recursion) and you do
not have to care about the specific allocation because it will inherit
GFP_IO automagically.

-- 
Michal Hocko
SUSE Labs

