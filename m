Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7A06C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:49:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A4132070B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:49:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A4132070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1ED56B0007; Wed,  5 Jun 2019 08:49:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA8216B000A; Wed,  5 Jun 2019 08:49:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C48966B000D; Wed,  5 Jun 2019 08:49:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 884FD6B0007
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 08:49:00 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a21so5555417edt.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 05:49:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UJ95E3Ifkh3uhWkD7ogH+OQDFci9mfttbW9enGbaaKE=;
        b=UMFe1ozy0gsAPUiH4fMeWmSyyGs3cbAe9tCbdj0cJIuv/WkkH7Xf0Fo9dXjDN01ZlV
         rbIdnq8v7HM/J7hQ452yySQgo9YCSECr4s5qilRqyvcRz6TVqj2qWsPvHIyrkQ8VSxIw
         J6Ooea8EUp5pXsnjvqBkKlkdneZch9hJ+EPccqvKejf3k1HQPsGBTvQQvwtWkb+dESck
         dB7bfczfydwA8RhRiOoNiMo4a3ww/7OMt+Q1MBmzoI7d8YhA4m/981CEMClwpPQVYcIx
         MTRl3rb17hkA4J+hYX+TyiJC7bYt6lvskLcoSx4SBcC20vS8qogzxm1UN/PJzVUyWZlu
         EJuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVXfl2xMq1pXsr2ccugchLHs4KrN4wLrvOB60p/+eVFysfFKtnB
	MQu1Ewmkdl6A2aSuaHuBjBlavjiFtB2lrm3ZynTkqahRF97XXP1GQOU/pR1UZhj5VBcJQabvrWH
	sSru3I33ZzJFvaSmf7RpzjFpYkx56eAa1EsqCrv+E/zL/i9PRZUBMCprJDgw3YR1v/g==
X-Received: by 2002:a50:d791:: with SMTP id w17mr42186532edi.223.1559738940124;
        Wed, 05 Jun 2019 05:49:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAH36jJbbXJp4lxNjN7UFH+cTZV/l/9CbY7VRSa31F1o0VsiLGGQU++7DtR1PUs9sPAMHI
X-Received: by 2002:a50:d791:: with SMTP id w17mr42186468edi.223.1559738939323;
        Wed, 05 Jun 2019 05:48:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559738939; cv=none;
        d=google.com; s=arc-20160816;
        b=GkHvfqYHe4JhiLLMEgIZ0OCw0Ka5+YkdQO8ulLrDCmvfnTKYWX+CVXKv3+9U84O2p5
         gz0qyOrz2anTZndNmcjYegAXEq6wY5aL2QbhxGo6/qtou6fEJlDkbK9aiVYAeLxIhA7Z
         DpU1mL2POpAVIDEKMUqHPQRA6JtGkxSE0kzKqVPcbT1mbEb9YobzgORkh8YKZyjErVm7
         DKX5ox56xcuN1TyyB3FD7AmR2HJrWmnlN4aM3du3Q3nY73FEnOuZp9ray70099P3I/oS
         p2B7yZiCgS8op5WU8LnbqXBdt8FvnW43GqDqtRHz1kZYbPY3bsiX5GrSzXePHms/RO4+
         zJiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UJ95E3Ifkh3uhWkD7ogH+OQDFci9mfttbW9enGbaaKE=;
        b=FTmze5RPiFDVa2Nlkw/UEgVMxUVhpHMbgtsYlmBf04RDN6c7HnmfYSXTX9lxV7WZrj
         kKRLk91ByQ7PMmSom370lGn2Pg9LlvbaXGfclPZE3rWJio+gqaR0T6KYfB+tKFNjfIK5
         NzHTSUqhr4VKRCl4rfhNzlA5z7Kx8cxFMHx+qrj+CAfgoiyzEnxTtLmm3Ahi60mzayRz
         zLkJwTi15re4XbEtc+1UWDG6cMu3Q1ERfDkagGsZWq6mMc15GtqrAP3chjKba42St7kO
         rO9/6tF0yqzdPLOWzohytx0f015RS0Z4WdZkCHu4cELi+xrq9qbSLCA9nZqbefnpYEla
         Eh+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp14.blacknight.com (outbound-smtp14.blacknight.com. [46.22.139.231])
        by mx.google.com with ESMTPS id k24si4646577ejz.188.2019.06.05.05.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 05:48:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) client-ip=46.22.139.231;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp14.blacknight.com (Postfix) with ESMTPS id D8F851C2AC1
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 13:48:58 +0100 (IST)
Received: (qmail 29552 invoked from network); 5 Jun 2019 12:48:58 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 5 Jun 2019 12:48:58 -0000
Date: Wed, 5 Jun 2019 13:48:57 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: balducci@units.it
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer
 dereference under stress (possibly related to
 https://lkml.org/lkml/2019/5/24/292 ?)
Message-ID: <20190605124857.GB4626@techsingularity.net>
References: <20190604110510.GA4626@techsingularity.net>
 <11510.1559738359@dschgrazlin2.units.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <11510.1559738359@dschgrazlin2.units.it>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:38:55PM +0200, balducci@units.it wrote:
> hello
> 
> > Sorry, I was on holidays and only playing catchup now. Does this happen
> > to trigger with 5.2-rc3? I ask because there were other fixes in there
> > with stable cc'd that have not been picked up yet. They are a poor match
> > for this particular bug but it would be nice to confirm.
> 
> I have built v5.2-rc3 from git (stable/linux-stable.git) and tested it
> against firefox-67.0.1 build: no joy. 
> 
> I'm going to upload the kernel log and the config I used for v5.2-rc3
> (there were a couple of new opts) to bugzilla, if that can help
> 

Yes, that would be helpful. Thanks.

-- 
Mel Gorman
SUSE Labs

