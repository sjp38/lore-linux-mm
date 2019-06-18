Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A4B5C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 06:54:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0254E20673
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 06:54:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="oBvX088a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0254E20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 926296B0003; Tue, 18 Jun 2019 02:54:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D9758E0003; Tue, 18 Jun 2019 02:54:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C4F78E0001; Tue, 18 Jun 2019 02:54:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46EF66B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:54:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y5so8645019pfb.20
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 23:54:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CJNJ5IXvAErjWakSbjVW0/qa4cRl1dbfK+XVrWxhxVw=;
        b=Ov3jO+hWQAqsXUkXPwco0IX2ZNaklw4lOIGuoxPNpmxcW7fAzh/0xoBuv7geEnJ+fB
         PdBlC/9DKDhHbexEwa4f8dFjhjBipWw9FLG2f1cAYBG5XfcpV6Rd5bwP2NERkMOiO5km
         NqZzZ2cjzyC5KL4n9AZIGa0fy8MTvKT8aODsE4Prdj5GCsAMkfFH3YSFOKTPGOreWmSr
         rE8VnFFiHz/sAV9/PoiyJp9zKElsyyWg3I9TMFV0E3Ii/uP1N+y7toLfwBe27dtOhtbz
         1fV2zzJTVivdATg1X5nakdfGcJWoJCNHTrh7X8HLJtY7Mqtsy/Cz25AyhhB652wl6Hlg
         r+gA==
X-Gm-Message-State: APjAAAVVUnivuDMuGc+XR74lW4m4TdFehT/jGBXqw8aMFENIx697zMpW
	alWJbsKWbcENJ3iJkDaDk37VQdpHZNy/11fiMgr4LSSHruxXW15KR8qnkFvIWkaZB/thfmFcs5/
	NCETImHXsXZOLVJN5EjPTVit+9O0V6Ge4TGvUs58s3nMlbpq2Jz83NzyoPr8vGIYKrw==
X-Received: by 2002:a17:902:b591:: with SMTP id a17mr51043408pls.96.1560840862907;
        Mon, 17 Jun 2019 23:54:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy1BAPUTqx73TQkQffpJqaqbChTr9OP8XPwUD9IKt7I/qsQZ+gWBFBTBxx6wff2zAIO1Rr
X-Received: by 2002:a17:902:b591:: with SMTP id a17mr51043377pls.96.1560840862286;
        Mon, 17 Jun 2019 23:54:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560840862; cv=none;
        d=google.com; s=arc-20160816;
        b=tzgvc+q2pt9epdi/MkKEf6CQv8n8xW6IbK2JWsZzM/LYWoBaRelprgiCPrdt0hAWvl
         XOgfxP4dNVxAFkq23BjwHgLLOW6jB7wt58Kwno+thY1A/vqgC/xOGbLjCVZAnTHETxa6
         Vq77rNhC/9f9M7mgeAQgs50qbhezZyZH0F6nRpV89SmI3FTyUpRHV1kg3Fu/EwI+AoY+
         mBiFnGeTz1Jm6mthtG9fMz5xYN4e3LzULeJhZ558l0HitKBDDE3zZpkKwhczTrtP1eq3
         jlNaFF8mY4Z7r3UrSejMU8RPpmHQm1PiUTYtDBmdw72JsLycXs/69kqxCft+9WvpTWAA
         XsDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CJNJ5IXvAErjWakSbjVW0/qa4cRl1dbfK+XVrWxhxVw=;
        b=n02y/1GQH0vHd8soIgSsgRiFg3QQxYQ6eqUqDR7OjO/ymZvQ23zjJ3MEiKuJSzQn99
         YYkIsQxYphX+uRvF8pONUn702TPNr1+/x3h9RC8/VcUT6Z+nnbLIRNfmZ76mSzSYr7X/
         pc/TA+mxKyWJxOFV1oBFniwXYxOyomifaVma9sq0C59mnHt3Lj5WUwT7eFGYqlUvB8/w
         KNwvhDIp5RciEn3iVjN7cyDAAZhW6tfVY/eQGQgE4VvCby/QjvmnkXtcP+9NpgYKA7Dp
         cks2gbFM9ZAzaakHj3mr/hhx2TyTORmlpIWBuS9kj7SU2diQzeZhQe2FSG+VMhXeidga
         4w5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oBvX088a;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k10si13316930pgc.9.2019.06.17.23.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 23:54:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oBvX088a;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from brain-police (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AB0AB20665;
	Tue, 18 Jun 2019 06:54:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560840861;
	bh=h6KCEecYqvEUsVXMGsOj14p5VeuD+CI26MOesVKK8tw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=oBvX088a/fOuuObjn7+ntF6Kq5hoY2/4Hpn4C9r/FHAPQ18VfSrKIN6FL5H8J8wzc
	 BBR26SXGwC+04hPIj6pp4cWe3SMe5tW99SFutH5DZAbPe6caLBBE0uSV5X3hETFvma
	 RU/jAfOdqr0dwXiPJhdVASX8az+JIm0olJ4+olBE=
Date: Tue, 18 Jun 2019 07:54:15 +0100
From: Will Deacon <will@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Qian Cai <cai@lca.pw>, akpm@linux-foundation.org,
	Roman Gushchin <guro@fb.com>, catalin.marinas@arm.com,
	linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org,
	vdavydov.dev@gmail.com, hannes@cmpxchg.org, cgroups@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Message-ID: <20190618065414.GA15875@brain-police>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
 <20190611100348.GB26409@lakrids.cambridge.arm.com>
 <20190613121100.GB25164@rapoport-lnx>
 <20190617151252.GF16810@rapoport-lnx>
 <20190617163630.GH30800@fuggles.cambridge.arm.com>
 <20190618061259.GB15497@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618061259.GB15497@rapoport-lnx>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 09:12:59AM +0300, Mike Rapoport wrote:
> On Mon, Jun 17, 2019 at 05:36:30PM +0100, Will Deacon wrote:
> > On Mon, Jun 17, 2019 at 06:12:52PM +0300, Mike Rapoport wrote:
> > > Andrew, can you please add the patch below as an incremental fix?
> > > 
> > > With this the arm64::pgd_alloc() should be in the right shape.
> > > 
> > > 
> > > From 1c1ef0bc04c655689c6c527bd03b140251399d87 Mon Sep 17 00:00:00 2001
> > > From: Mike Rapoport <rppt@linux.ibm.com>
> > > Date: Mon, 17 Jun 2019 17:37:43 +0300
> > > Subject: [PATCH] arm64/mm: don't initialize pgd_cache twice
> > > 
> > > When PGD_SIZE != PAGE_SIZE, arm64 uses kmem_cache for allocation of PGD
> > > memory. That cache was initialized twice: first through
> > > pgtable_cache_init() alias and then as an override for weak
> > > pgd_cache_init().
> > > 
> > > After enabling accounting for the PGD memory, this created a confusion for
> > > memcg and slub sysfs code which resulted in the following errors:
> > > 
> > > [   90.608597] kobject_add_internal failed for pgd_cache(13:init.scope) (error: -2 parent: cgroup)
> > > [   90.678007] kobject_add_internal failed for pgd_cache(13:init.scope) (error: -2 parent: cgroup)
> > > [   90.713260] kobject_add_internal failed for pgd_cache(21:systemd-tmpfiles-setup.service) (error: -2 parent: cgroup)
> > > 
> > > Removing the alias from pgtable_cache_init() and keeping the only pgd_cache
> > > initialization in pgd_cache_init() resolves the problem and allows
> > > accounting of PGD memory.
> > > 
> > > Reported-by: Qian Cai <cai@lca.pw>
> > > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > > ---
> > >  arch/arm64/include/asm/pgtable.h | 3 +--
> > >  arch/arm64/mm/pgd.c              | 5 +----
> > >  2 files changed, 2 insertions(+), 6 deletions(-)
> > 
> > Looks like this actually fixes caa841360134 ("x86/mm: Initialize PGD cache
> > during mm initialization") due to an unlucky naming conflict!
> > 
> > In which case, I'd actually prefer to take this fix asap via the arm64
> > tree. Is that ok?
> 
> I suppose so, it just won't apply as is. Would you like a patch against the
> current upstream?

Yes, please. I'm assuming it's a straightforward change (please shout if it
isn't).

Will

