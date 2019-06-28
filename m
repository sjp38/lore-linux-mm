Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 139AAC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:47:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB846214DA
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:47:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB846214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FAF36B0003; Fri, 28 Jun 2019 14:47:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 683F28E0007; Fri, 28 Jun 2019 14:47:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59A0A8E0002; Fri, 28 Jun 2019 14:47:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f79.google.com (mail-ed1-f79.google.com [209.85.208.79])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB7C6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:47:32 -0400 (EDT)
Received: by mail-ed1-f79.google.com with SMTP id a5so10119681edx.12
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:47:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=67zCEsIwbFi2d/a82mDcIwtmGnVo2FTjQezAf5QAnlA=;
        b=T18cd+9DkU0/fNieJba705JuIXU6MWUArskkxv9EQ1jWkMXjvQepgi8pvFt9OO+ifU
         ADTOpA74umKPaOWLQoui2z6KtF8GryDTka2tscyqLUIdQn/rU88vySchtmHzCwmdu1ne
         RmS2I2LB67fmlQJzwTpS1RXZLXBRJcKTuyD/Wrk2Nozi2NU9xHw8NspDbvnrPpvptwgK
         lrBUqgtH7y7e0b67SleuTNsThoDyFwzsO4G2b762qKpEEfQ8wA004iCSVWf/6kXTZj1b
         lgP1YLd6KVeKn6r7c7I0PfQpZ34NQ5G84GFXX7msV2RMAVXnUSX5REqS35SPlfDkisxA
         CfHw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXUOM2EfDHPLU0B9G+dqyXyPYHi2nzFOn1WkRGjx+gYZqwDWryy
	VeEmEj36aO2CsXkXaLSTpGmcnp3upYH0u9As2cq035i7ff4k/5W70hJ+KhEMv2hL/OrCqLnElxh
	gZw87ePGfa0vi7EL9hOWFRdXGfZ6SaNA/mksYSKgFSay5/bvHaWE9pE9AQMOCXBo=
X-Received: by 2002:a50:b839:: with SMTP id j54mr13424520ede.155.1561747651590;
        Fri, 28 Jun 2019 11:47:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3zexnALbPq8xyUoVswgOpVcF7FLmI3sm0WPxIxnANoX9BShe8X5Jk0b7rMUHcWIgsIpr6
X-Received: by 2002:a50:b839:: with SMTP id j54mr13424466ede.155.1561747650892;
        Fri, 28 Jun 2019 11:47:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561747650; cv=none;
        d=google.com; s=arc-20160816;
        b=09g/jFhmYOBFGa2l36YclbCWhDxWTz3nL7yRyD5e8xg/jK8apufJc6yKwWZeVpvDnx
         6oIt+e7PxDbU/G+mRNOzlEhb+uM9gm174S0PxqyKh0t6srUVSVsyjnIHFRyrGhF0ToiA
         Wb3znPF1Rj17IIeQD22GMGEoVFEQZdREVreIJDR7o68MZiPq7o34dDmnx3Z12LIZEc10
         Nz5+SajLr+4ybsxGVJgkmmrw7gkgF/1qm5SDAQlflj16pvV+5j4ifLN6kZcKq2cTwlFl
         FuqB8hWvdwBuedYLUB1A7GpmgtZLQ9LFMHyGXRaEJX8x4AVqfiflHn60/6oa3WVciI7/
         Wjgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=67zCEsIwbFi2d/a82mDcIwtmGnVo2FTjQezAf5QAnlA=;
        b=G5rJ9VCHC9iGRYV6Bl3cryV6kwphojxmdQPI4fYceNzNxSxyBhwg0dD+idg/LsUGft
         PT2/7zV4HQvaEICIp6ux7G8YxxKlnR/HOnKYyKy4LluWYClarWaqZB/eUWdbjqGAPD9h
         7gASTBeQ5fyCfxm5SpthOFNlnuogvZadZVd5OCvnTbGiGw/FyLVTA7etUXpxTMWD/b+3
         2M4bURl0X4PWCGoBdP0BolfjgaQZcztkddblz63s2vgU6UV7wxqI49BkpVMVDW+KzCDP
         DQoGuOerLIxKCV604+P7JrAStL3IyTMmiRSOmKsxvtbtMDkwaTLjGt++qc7IrVYEeZrL
         1ixw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si2609447edc.389.2019.06.28.11.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:47:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0F534AEAF;
	Fri, 28 Jun 2019 18:47:30 +0000 (UTC)
Date: Fri, 28 Jun 2019 20:47:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Juergen Gross <jgross@suse.com>
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: fix regression with deferred struct page init
Message-ID: <20190628184729.GJ2751@dhcp22.suse.cz>
References: <20190620160821.4210-1-jgross@suse.com>
 <20190628151749.GA2880@dhcp22.suse.cz>
 <52a8e6d9-003e-c802-b8ff-327a8c7913a5@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52a8e6d9-003e-c802-b8ff-327a8c7913a5@suse.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 28-06-19 19:38:13, Juergen Gross wrote:
> On 28.06.19 17:17, Michal Hocko wrote:
> > On Thu 20-06-19 18:08:21, Juergen Gross wrote:
> > > Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
> > > instead of doing larger sections") is causing a regression on some
> > > systems when the kernel is booted as Xen dom0.
> > > 
> > > The system will just hang in early boot.
> > > 
> > > Reason is an endless loop in get_page_from_freelist() in case the first
> > > zone looked at has no free memory. deferred_grow_zone() is always
> > 
> > Could you explain how we ended up with the zone having no memory? Is
> > xen "stealing" memblock memory without adding it to memory.reserved?
> > In other words, how do we end up with an empty zone that has non zero
> > end_pfn?
> 
> Why do you think Xen is stealing the memory in an odd way?
> 
> Doesn't deferred_init_mem_pfn_range_in_zone() return false when no free
> memory is found? So exactly if the memory was added to memory.reserved
> that will happen.

You are right. I managed to confuse myself and thought that __next_mem_range
return index to both memblock types. But I am wrong here and it excludes
type_b regions. I should have read the documentation. My bad and sorry
for the confusion.
-- 
Michal Hocko
SUSE Labs

