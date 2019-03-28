Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD836C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:28:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73D72206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:28:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73D72206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 121866B0003; Thu, 28 Mar 2019 11:28:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CF2F6B0006; Thu, 28 Mar 2019 11:28:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F29B36B000A; Thu, 28 Mar 2019 11:28:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A03146B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:28:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y17so8268361edd.20
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:28:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Qyy0dg+GGykPNWVJczBv8HjIGW1yOXc1I8qgIZQA33A=;
        b=p2ZKZZ7BonxH+CivdaXmuGGk4SUgmGufJkYqcW0Thp3WSi8uREAEBKWvVtxUH0i8mE
         gR9mzPcSa8txIxTT0BV71lQKvZmQj8Cg0MV9oknm8PEJmBnXELDeeeZaDurbH0rOilFP
         YibycnTelHysOmGaqauSsy1FD/XVMiMA4E41miKOyfhQZJkj2CwI6D66mAqSfbAKnoPi
         F+2L9jpDyRWS13iyF7ZK4n2xYtG/4mA90e0N06pAPfcMp7KPynNqtflDkiWAjjZXWWAa
         q0wmpvMlcGAyl9/5MYan2jtW4C0FW3BfBKLnnmaqehgrGqh3YtuCJefrzMzDP3yzBS3P
         SAtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXArQPZk8IjVS7j3uifpYMrX6ku0XHo2K3zykj10g2t3ptTNY2n
	ByD1npxfDYmIXxPjZYwV5I8L1tclU4Urm5BNYp2IeDT8MAr+quAFwveGGdPvSctF3X7MT6TNWJz
	KO9EtjkSZoUnTCssWxfhxWT/3W9FltZ1PPs7qCNwEZ1XGL3YKmtcOlpfHOpjOZlLMJg==
X-Received: by 2002:a50:c251:: with SMTP id t17mr29147201edf.179.1553786937224;
        Thu, 28 Mar 2019 08:28:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzssMzZGXEZofDeokNbw9hAMfUsvsOxwo2rQt9lChfO9nwB1x4azRCmZmZ8rI2KO5tRk8Eu
X-Received: by 2002:a50:c251:: with SMTP id t17mr29147138edf.179.1553786936245;
        Thu, 28 Mar 2019 08:28:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786936; cv=none;
        d=google.com; s=arc-20160816;
        b=TcpfdoUbO77GMyYYy223DQBOs2sfmw2D6yzy3WmKnRsx5yv/wFdZv2jGn7EKFh2tAA
         lZCsAMjKeQ2T8hpQzOAy1ehq97LodQ5HwLx2h6keQhiXgJsL539q/8m4RmzIsmT1Iibh
         1Pu61sN32GgPggioGNa5gH52F2JIOTBcIGqr0eg7WKrF50+Ruz5MJbLACPDWKgP4a/d4
         W//GTdxSu+KDwyF2NS08Zu7kTos480lmsmtCOrQD0I1g5RtvPLZ+t709F+OUKRcolDRO
         sRutYGlgMtvu99b7y9RrcK1VfKxoPAlNO35IcczQcS7C6MFmMTYCjh/TsiGE/3LibHk3
         952Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Qyy0dg+GGykPNWVJczBv8HjIGW1yOXc1I8qgIZQA33A=;
        b=C/yb3gkxBI1+NpCOsb/Hsl0fQ2tKRph1Uq9Se6kX9xAalYBUe8oDZPuMOcI9lWkUJH
         hwZIWUo95EKn189mBqyBYB3WH4MZkSeESDidCtMUnt3DOlwa+OIa0YG0MlHnubkCavtg
         IYFWxI4G7voJ6mFdDbWyxZCzI01exieNRi4SBPvGp9qzO84lPffGEU3X3MfAz4jKEM6H
         8lsJ660s8RdVfMcW80M/mHDnY0ZBHVlvit6LpIX/gYbnhCFOoRpqs9FCTWPkhb5iq6v+
         1F5NAkzH02amNRvdUqWaUS49Uc/qOMHliAf3OeDjjEs6Hp4y18KsMzod0pKZ74e3xCY8
         8NkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i24si4039793edg.154.2019.03.28.08.28.55
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:28:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4430015AB;
	Thu, 28 Mar 2019 08:28:55 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 29F433F557;
	Thu, 28 Mar 2019 08:28:53 -0700 (PDT)
Date: Thu, 28 Mar 2019 15:28:50 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Pekka Enberg <penberg@iki.fi>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, cl@linux.com,
	mhocko@kernel.org, willy@infradead.org, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190328152850.GE10283@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
 <c49208bf-b658-1d4e-a57e-8ca58c69afb1@iki.fi>
 <20190328103020.GA10283@arrakis.emea.arm.com>
 <8e88b618-e774-de81-ca99-a8ee89f60b5a@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8e88b618-e774-de81-ca99-a8ee89f60b5a@iki.fi>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 01:50:29PM +0200, Pekka Enberg wrote:
> On 27/03/2019 2.59, Qian Cai wrote:
> > > > Unless there is a brave soul to reimplement the kmemleak to embed it's
> > > > metadata into the tracked memory itself in a foreseeable future, this
> > > > provides a good balance between enabling kmemleak in a low-memory
> > > > situation and not introducing too much hackiness into the existing
> > > > code for now.
> 
> On Thu, Mar 28, 2019 at 08:05:31AM +0200, Pekka Enberg wrote:
> > > Unfortunately I am not that brave soul, but I'm wondering what the
> > > complication here is? It shouldn't be too hard to teach calculate_sizes() in
> > > SLUB about a new SLAB_KMEMLEAK flag that reserves spaces for the metadata.
> 
> On 28/03/2019 12.30, Catalin Marinas wrote:> I don't think it's the
> calculate_sizes() that's the hard part. The way
> > kmemleak is designed assumes that the metadata has a longer lifespan
> > than the slab object it is tracking (and refcounted via
> > get_object/put_object()). We'd have to replace some of the
> > rcu_read_(un)lock() regions with a full kmemleak_lock together with a
> > few more tweaks to allow the release of kmemleak_lock during memory
> > scanning (which can take minutes; so it needs to be safe w.r.t. metadata
> > freeing, currently relying on a deferred RCU freeing).
> 
> Right.
> 
> I think SLUB already supports delaying object freeing because of KASAN (see
> the slab_free_freelist_hook() function) so the issue with metadata outliving
> object is solvable (although will consume more memory).

Thanks. That's definitely an area to investigate.

> I can't say I remember enough details from kmemleak to comment on the
> locking complications you point out, though.

They are not too bad, I'd just need some quiet couple of days to go
through them (which I don't have at the moment).

-- 
Catalin

