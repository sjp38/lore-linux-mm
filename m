Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D00FFC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:05:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93BA72085A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:05:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93BA72085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 415B66B0007; Fri, 19 Jul 2019 02:05:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C7EA6B0008; Fri, 19 Jul 2019 02:05:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28F338E0001; Fri, 19 Jul 2019 02:05:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1ED66B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:05:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so21384014edu.19
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:05:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vOoTnd6F2XPLl0MoUhk4CrXXl+XK/ozXVTBnvlJq/0c=;
        b=nABu3VW0FiYv2iBmwm7JwhZRLateLM6/VSVaRbnDc3lEvRe5Q67fjna2o4XcjddnXJ
         QQ7cHEc7UjK+1NohECBQOrNvfI9aH/HXR8kn+u+gZGhPDUBbprjt3jjUpJ8thkCsmDiY
         IJWGnwHPrqocSF7tz2UxEuFtrXJkfABZ8p/RDPwYwHND9CHXlYIZvpg5/dTk1yZuJszY
         26BLhrfWkrkIUO5o3p80kHoyyzgAvsdFmrxls6WXAy0oV6ge6oAW4tFAON7qYydpLHhk
         2P9QtbXUR8MmBvbC3kHoyq7JQW4Xu+5mGd4Z+m0+cx5vOpfkkAJLpxIqqTf0C12oiDzM
         7Sqg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVqygHTEmj6AlFIrkUcwjB2WopMi5B20ThFgS9PUmgPk2w675Es
	//6dsq5v5NLWGS9HcLj9cWzEy2XpHR7sNv51s/2d2Vlgq3xOy73+e6P9uIDLSoRHzu8oi7LbmFp
	yXZwBPI8r6OkypOO5x98z7eFUreIf2LegrGoNpanhTbdcbn2Vb6hcahyvr4hNNuY=
X-Received: by 2002:aa7:c559:: with SMTP id s25mr43844670edr.117.1563516306448;
        Thu, 18 Jul 2019 23:05:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9vY3mfv5f0C0z6IEWo/aZ6NxQ+2bq818suyN+DSUYIAz/uYPc2wCyOHRI0lFx4+ecnd4q
X-Received: by 2002:aa7:c559:: with SMTP id s25mr43844598edr.117.1563516305412;
        Thu, 18 Jul 2019 23:05:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563516305; cv=none;
        d=google.com; s=arc-20160816;
        b=GplJtEg/FMkHM8MGqClF8KuThJXPiL0Ue8FFJkaxyD42M0v4MXH9kQOG0euSJkvaAQ
         TvCOmT/2/SGKbL5o36SLjfZ3qBbUfQGJX5dvU3mpbRaM68tmcrPMbE28yOZQ/LvVZCAx
         3DHP/7um/Qgi5VXQ1EDjg66BPVJY+syBG/c8kaqidh2yOeh/WrQOF0i+ykTvcUNAGF8L
         Cs24psr6qWkjrjPuXGRiL/ZaVOFTI4AAIQhonPojUlS7DlV6KylJBv0voZtg7Vp7RPYA
         tTFLMNpN2jd5bluA4QBKbtilq3EoefzQ+4S5L4IC4VMHn1jLB+32w5N5jNBkIY6bP9GE
         r1fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vOoTnd6F2XPLl0MoUhk4CrXXl+XK/ozXVTBnvlJq/0c=;
        b=g3p6AGu/UHlUnIObdAS52+MXFxa9R+lOuW/qdHSKyJYvF5FxrHFUaLKOrez+wiV5Lq
         WZ+7ifrx6AkwziK+OGZpE1ORFbaqdXnYkS3i+mp0RNmezOhnm2WY08QbW26DJMnXN11e
         xldbDAKvXlNzKw6g1/qnjPrSLwL1M6ogHA5bWoMoXFJ4ZIncUsFjGxN6fR9hfNiJVwcq
         DgeUYiUHwpix11BX+i/MUWHQoPPJtdN5ueZh1NnqCCqpiwBx/9uBuQyGtIm3VL8y8gyM
         fpPj2ppeu9xiBrElt7jY0vLkIESen7jNbIOVNTYUULxpieRGLcjU6qVVq6maCM2Viscy
         YcYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20si487901edy.431.2019.07.18.23.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 23:05:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6FB6CB0B3;
	Fri, 19 Jul 2019 06:05:04 +0000 (UTC)
Date: Fri, 19 Jul 2019 08:05:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
Message-ID: <20190719060502.GG30461@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
 <20190701085144.GJ6376@dhcp22.suse.cz>
 <20190701093640.GA17349@linux>
 <20190701102756.GO6376@dhcp22.suse.cz>
 <d450488d-7a82-f7a9-c8d3-b69a0bca48c6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d450488d-7a82-f7a9-c8d3-b69a0bca48c6@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-07-19 13:10:33, David Hildenbrand wrote:
> On 01.07.19 12:27, Michal Hocko wrote:
> > On Mon 01-07-19 11:36:44, Oscar Salvador wrote:
> >> On Mon, Jul 01, 2019 at 10:51:44AM +0200, Michal Hocko wrote:
> >>> Yeah, we do not allow to offline multi zone (node) ranges so the current
> >>> code seems to be over engineered.
> >>>
> >>> Anyway, I am wondering why do we have to strictly check for already
> >>> removed nodes links. Is the sysfs code going to complain we we try to
> >>> remove again?
> >>
> >> No, sysfs will silently "fail" if the symlink has already been removed.
> >> At least that is what I saw last time I played with it.
> >>
> >> I guess the question is what if sysfs handling changes in the future
> >> and starts dropping warnings when trying to remove a symlink is not there.
> >> Maybe that is unlikely to happen?
> > 
> > And maybe we handle it then rather than have a static allocation that
> > everybody with hotremove configured has to pay for.
> > 
> 
> So what's the suggestion? Dropping the nodemask_t completely and calling
> sysfs_remove_link() on already potentially removed links?

Yes. In a follow up patch.
-- 
Michal Hocko
SUSE Labs

