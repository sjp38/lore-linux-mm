Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 804B9C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:17:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 344002067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:17:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 344002067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B30BF8E0003; Wed, 31 Jul 2019 05:17:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABA2A8E0001; Wed, 31 Jul 2019 05:17:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 981FA8E0003; Wed, 31 Jul 2019 05:17:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 479188E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:17:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so42021452edr.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:17:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MQxmqMlDSeHjs7mKIzY2pIJnS4UKbsyR6XiRmRTURE4=;
        b=nz6Y3KwLSH46qYcVsVPQG8sa/z2S/Svs7w5fK78OR5FpiC8p6vDTyM35NftfC+kOXy
         fl3j1ydnamSA60wbEcYWXGjQstqkHADZehxcGxwKOnnV62KhWqLeUSMT7n+/hzzETW2o
         /Ii40thdG2+89WoC1uK3RCsT49RunCe3YaIQe2Vf9XSHrDoLdcxvZWaM+fLo86mWq0+g
         +XnFtpqRlTOJeqev5/CYgWb/T0oCkmydxe26oEPmpEKXjGLrobd1uG2vhtJBwLnEmqQW
         Q/GXe3RAcP3gz6Sce5uxtqBgKvruWHd3R5srvq/AUnVw2R9DWmL5TDclTiacuw9Q6ZxU
         HT8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWKinDom2cTRuiPknHiRdNnpdK7neVqzARGsVSERCrDhUfUh87+
	VddWfijqz/qYNIDpU52rv2v4NIRGlg/KJM+YL0REVTE5Ukxyy7HMancNQoWH/PGLfyAYl/WqpJ2
	MHqgD/x/mIoy0HtK7PhU9SQvMaJjHsfetiQhmW2Oo0S9jUQkHYP/l4yvzGd6xApaAPw==
X-Received: by 2002:a05:6402:12d2:: with SMTP id k18mr99768560edx.197.1564564651858;
        Wed, 31 Jul 2019 02:17:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws+WUpU5EGyk67dOGpTg8uQLruDhnQrqFmI2eIRc1qGM0J/sxEj74dxdsf8CpdUeisUQo5
X-Received: by 2002:a05:6402:12d2:: with SMTP id k18mr99768521edx.197.1564564651181;
        Wed, 31 Jul 2019 02:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564564651; cv=none;
        d=google.com; s=arc-20160816;
        b=Sg4xUn2csjl+WEw2WVCgGtEV8oqGmCilKdweXUdbZtAo0WEUmZEeCtp14PNfQNOXi9
         vHwPO5SPiwUeh/aO9j/XzTFt3BOCB7gbIl0RtkqMxHX8IGbxzI2y72TptHZ6mpuOt+zP
         99EDKOCon+HghAwCS6vB5TeiSeZwMx6PZIH9oSLbHQGXsZbsYG7UKY8EdH/+MapV1/Pb
         1m+2RGdX6lb25qR4u69lEwXOW/iwfnzicvwKlS4ggC0wzZHR34HLsJSO6hsOm2iWQEQj
         CwPt0RvM6DSVsUjw7UP3tFiSTFQUTeVcce/AwBHWnvpTWacDQLNp2xa/+/nGGn3Bcc19
         MnwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MQxmqMlDSeHjs7mKIzY2pIJnS4UKbsyR6XiRmRTURE4=;
        b=SKWX5vz0Vsas6axZEtK/9Mx0WCkx+L++3XTC2hNpLagk+aOwk+ra561s3xmfuxlG6Z
         vK169T+bYhJpDmrEGzw22Baq8h9BG6tky94qgqGWDwTfJYvZsTxBdj/Oua9I2KS7oFPU
         ITA/nfKAkztYI8dJ0jpVRvy7t6v8GZ6yURLqsXpG8vfVMyH8iPZXNkC3d/Ru3LCXoJMK
         0GuYFgfhFDtRL/HVc9vk6my1++3A8keifcXHa/QH2CP4hwqxReNDFuTPZcT9CdnEzwEA
         tRVzMLrBlCKmJjo0jypTUpwa+9pDT5E1Yqwpy9FsIgqNkqZT9d+0miGD3/FHVaqo/+0E
         fzOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d39si20896915eda.8.2019.07.31.02.17.30
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 02:17:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 34942337;
	Wed, 31 Jul 2019 02:17:30 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2F2E23F71F;
	Wed, 31 Jul 2019 02:17:29 -0700 (PDT)
Date: Wed, 31 Jul 2019 10:17:27 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190731091726.GB63307@arrakis.emea.arm.com>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
 <20190731090653.GD9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731090653.GD9330@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 11:06:53AM +0200, Michal Hocko wrote:
> On Tue 30-07-19 12:57:43, Andrew Morton wrote:
> > On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> > 
> > > Add mempool allocations for struct kmemleak_object and
> > > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > > under memory pressure. Additionally, mask out all the gfp flags passed
> > > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > > 
> > > A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> > > different minimum pool size (defaulting to NR_CPUS * 4).
> > 
> > Why would anyone ever want to alter this?  Is there some particular
> > misbehaviour which this will improve?  If so, what is it?
> 
> I do agree with Andrew here. Can we simply go with no tunning for now
> and only add it based on some real life reports that the auto-tuning is
> not sufficient?

In a first attempt earlier this year, Qian reported that an emergency
pool (subsequently converted to using mempool) with the default pre-fill
does not help under memory pressure:

https://lore.kernel.org/linux-mm/49f77efc-8375-8fc8-aa89-9814bfbfe5bc@lca.pw/

I'm waiting for him to confirm whether the tunable in this patch helps,
otherwise we can look elsewhere, maybe refilling the mempool via other
means than just on free.

In general, not sure we can do much under memory pressure. I'm looking
at adding the kmemleak metadata to the slab itself (though I get some
weird -EEXIST error in kobject_add_internal) but there are still places
where the metadata needs to be allocated directly and, under OOM, this
is prone to failure. I guess we'll have to live with this.

-- 
Catalin

