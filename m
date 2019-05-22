Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 439EDC46460
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:52:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B77020644
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:52:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B77020644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD85B6B0005; Wed, 22 May 2019 11:52:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A61386B0006; Wed, 22 May 2019 11:52:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99E396B0007; Wed, 22 May 2019 11:52:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF226B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:52:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r20so4241150edp.17
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:52:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XLzRWgLbBe93oQpLgkZhBHP+ykq1C/psi4eOGmmtMTw=;
        b=e+clGOkuMtAebTmHJULu8+L6uuIAVmlb6aHk/M6Rui5YyCl2IMGmcESr92/VBsbcDj
         r+FVNrQgjMbCMoiC3kTfvUcam3gW2/wzPiNDpqgpmx4o59+/aPyhAuELxUUrRgqrLwPl
         hOXdVAQpFXFgTmcHQxkQ/qBVE/b0+/ZMWmvZqRquP2Klbeg3kwsKhwlJWdn8T1Sgg+v9
         mdC5Vx9XFMvqUdTzXTg1q9wfqsk9UmijW6tK2lIdv2vx+1yWLu7JaiprZgW2FZgUGX1U
         xRQKQYzW0BObBWe1dWjTGc9RJUYbxoOc1u4bnCT0QhHGtVvgBZbYQoU5ci7MzGO9a9nE
         Hkbw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW1Fz2XrPVc+95j9LliVd11XvjJ3ygXIAsPRIBTKxPncwO8lx5c
	WcLrWlaUYwiFLv0GIl2fBAADhHIa7hC3PRA5lHpOXtv9ub/nQCwWzjYgYNB7cfjJDFPPFnx1Qog
	Uk56PLzDcb8mjtK9DnQm1jIq94vDN6gKcu2FaCGfjhKdV4XocZkVEumAbH1O6s14=
X-Received: by 2002:a50:abe5:: with SMTP id u92mr86164323edc.164.1558540342918;
        Wed, 22 May 2019 08:52:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/XyYLJEL44LQOcd6eQqcP42a3wCIzlr+X56hvUZIGZa94wIVEKLvpZyHCgIXc1Je4Yla+
X-Received: by 2002:a50:abe5:: with SMTP id u92mr86164255edc.164.1558540342288;
        Wed, 22 May 2019 08:52:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558540342; cv=none;
        d=google.com; s=arc-20160816;
        b=bECU/kF5si3T/z8IWbSZHhPNhRid/F4s/d8QBApStF+BDKQbmdLvx0KZL5RSpuEI3I
         cyJOPDHwQHuwIoxWd6+XquYC3znrwZUTxCvmVtZ4gXhesMCPGk4WlrpDeTAyGJc2ckGg
         4oGG2w2gZ3RKopY0+nxJdOnpeJzVgjsEvyVGyniizlesp9DS1RyllpCps1d5dPbPNXou
         HalpkjIopNcH3Cr60+nxWQxtK3xgF37yfP3MKQDquYGYEUsaWDRec6ErCJNpOgAsdYAk
         um0N48HpbWT8BBu1H7I3PJzeP6nFghhMSC/mX8hI5lRz+LaB40X2Aq/ZNxrrzL8Abxmm
         ytPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XLzRWgLbBe93oQpLgkZhBHP+ykq1C/psi4eOGmmtMTw=;
        b=oT1IMDCliOxS1P1chOzHBV3+4DvNhikQNDAx6s+UpC95QQb+AG6K6DjgIr6KQda73J
         DZjg4I3l2JP4KgeugZ6ABKIYrgVJfaEXMl9fpTUNwsTNiD3QU5CEZuMP6rxajIXGVWRD
         noGEly17GzkqKOAcphUcSwY5lFks5FAUVjEfKKcBmDq4F4j3Fesci5mgMMXmpV89r6Lw
         MIFeqH/FtCqCXkU/LBfQZkBRStfTBXGwInuY36lX9Ro9t16p7+4TmKtrhXNWBGlAOwe4
         WPXVzCbYOtyLENjsQWf0q/DCZRw+tWm6N6sKFZghnFxCzFLLzdxVgPCQFmKuPb3dgSWt
         rVMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c62si9332727edd.451.2019.05.22.08.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 08:52:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77824AEE2;
	Wed, 22 May 2019 15:52:21 +0000 (UTC)
Date: Wed, 22 May 2019 17:52:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] proc/meminfo: add MemKernel counter
Message-ID: <20190522155220.GB4374@dhcp22.suse.cz>
References: <155853600919.381.8172097084053782598.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155853600919.381.8172097084053782598.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 22-05-19 17:40:09, Konstantin Khlebnikov wrote:
> Some kinds of kernel allocations are not accounted or not show in meminfo.
> For example vmalloc allocations are tracked but overall size is not shown
> for performance reasons. There is no information about network buffers.
> 
> In most cases detailed statistics is not required. At first place we need
> information about overall kernel memory usage regardless of its structure.
> 
> This patch estimates kernel memory usage by subtracting known sizes of
> free, anonymous, hugetlb and caches from total memory size: MemKernel =
> MemTotal - MemFree - Buffers - Cached - SwapCached - AnonPages - Hugetlb.

Why do we need to export something that can be calculated in the
userspace trivially? Also is this really something the number really
meaningful? Say you have a driver that exports memory to the userspace
via mmap but that memory is not accounted. Is this really a kernel
memory?

-- 
Michal Hocko
SUSE Labs

