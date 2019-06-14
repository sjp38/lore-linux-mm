Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F948C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:20:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EED2920665
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:20:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EED2920665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 769166B000A; Fri, 14 Jun 2019 06:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71A266B000D; Fri, 14 Jun 2019 06:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 608DC6B000E; Fri, 14 Jun 2019 06:20:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 258166B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:20:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c1so3048322edi.20
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 03:20:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ODEh8aow4oyQdEZ9PoXUE34A3m0yP0+DRw6w0TZMciM=;
        b=f73ICSzIYYOYxrSxK36uH0XnuaAVvYdEs3yNnG3pNC1r37bpgpkZq2BRFG1shoYiK8
         /FNSxfomcsYm7+9WqPPMp283V77ALEQDaYsaiW5uuDDFnrDFssHza8TjcylfViDPE9Qc
         kI4dmzB7Axllvji2ex1bPN6jXgpU2y1bDi+5JVlKazntmlDufcoYrTbAp+cm6OAB1cZw
         pRHcuOli/YagKwh2eQShmhw0LhHCX2Z9THK3XW3mf61j1t5TIXxeH0cMXqa7q6fsbJ4G
         Cf4V2MqabYa/gAbcmPeDTgx7fDn+1UBSrqYRmdAhqKbpMlJek/+k7/5Iqfxm3y4jnUdb
         2GLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAXHFPNJKuCH7WVtMFbh63jYD42bB0HAwzp5mIyIfWU8s+OSwqsk
	eJ7KXPkq1zxUtO8ld8XNeiI0L5ukTedHvFmpKklHl7a0plMOMh9S86GPJ/AS62DbUW/XWxvJcDu
	vCMJGxa2721dNejgzDV3bHnkNBccUpBalcGbmhW4DSTZ3hlo0Q6gC3VPVHDGUABZK7w==
X-Received: by 2002:a17:907:2130:: with SMTP id qo16mr4694665ejb.235.1560507622582;
        Fri, 14 Jun 2019 03:20:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSGv2NNK+OoB5H6RD18tQC0VoJtaBwHkvhUiwHzUpBX0KLPVK5hgRRp44Y4SlywWlLbh4y
X-Received: by 2002:a17:907:2130:: with SMTP id qo16mr4694595ejb.235.1560507621570;
        Fri, 14 Jun 2019 03:20:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560507621; cv=none;
        d=google.com; s=arc-20160816;
        b=sqmCm98AvxoI2A5n9rhJ6dEjMbihabHUEvfABKDbF1/uBNr9N3WY0tMP1G/1zueB26
         RE7XL/07FvMKR+i1b/pksNb03tbVcSPUUNvSvsaZITSPJNLb+GtVz32sqMnhxLKU/WcY
         04/Z+OuOsUN9i6a/PeMuRTfZ0NXT+3peL9XrhYg8aME0EpWRRIqAuYk+72UWciHkroEL
         52L7/MhcIEdnWuPcPu1Sdnbc1RZGvhtrIqJlOSHgM6PoycU1UuKrXzRCgH7SZBzsQxu3
         C/40/IoxyoS4qh0EJZuyNrH4hB+HxVPbKpc03UirNJZrkfZ+XrIHiHC3URWK7XkvsLAD
         9mmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ODEh8aow4oyQdEZ9PoXUE34A3m0yP0+DRw6w0TZMciM=;
        b=rOkxUEhncyEkb/1Z98/58MeG+fVxYaqvI/KbEVRMbZn7psPG3xJsqoYed23waEaZpt
         gn3L7mcaI1WbSat8uY/d0kjq2hIuzUR6eK5tkEXqmH4r4/r0IPLlGARbV2BFM4g4//dm
         fHhtz7UR2/hkSiZ9SPMyljU/G2+S0cUzx9m8fdE5bwX4grMlY6QXS7ikj99/wDg7vYS8
         yreE9bsFRjtRew3tZKWgBssziPkAv36gKTXymtFRiO7OyyPy6LQBGjpprqMMPRHpaQIG
         0+esSZS7WP223JHyX8jQCiSk01Ix1kV72ovQ7zS50CQHqbWeI240XmH6xoAjffTRWrZj
         nEVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f11si1628909edb.356.2019.06.14.03.20.21
        for <linux-mm@kvack.org>;
        Fri, 14 Jun 2019 03:20:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7FADF3EF;
	Fri, 14 Jun 2019 03:20:20 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6D72D3F246;
	Fri, 14 Jun 2019 03:22:03 -0700 (PDT)
Date: Fri, 14 Jun 2019 11:20:17 +0100
From: Will Deacon <will.deacon@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
Message-ID: <20190614102017.GC10659@fuggles.cambridge.arm.com>
References: <1560461641.5154.19.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560461641.5154.19.camel@lca.pw>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003862, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Qian,

On Thu, Jun 13, 2019 at 05:34:01PM -0400, Qian Cai wrote:
> LTP hugemmap05 test case [1] could not exit itself properly and then degrade the
> system performance on arm64 with linux-next (next-20190613). The bisection so
> far indicates,
> 
> BAD:  30bafbc357f1 Merge remote-tracking branch 'arm64/for-next/core'
> GOOD: 0c3d124a3043 Merge remote-tracking branch 'arm64-fixes/for-next/fixes'

Did you finish the bisection in the end? Also, what config are you using
(you usually have something fairly esoteric ;)?

Thanks,

Will

