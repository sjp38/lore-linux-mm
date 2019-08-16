Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35FD1C3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:19:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7F512171F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kbat1qAe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7F512171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8082B6B0006; Fri, 16 Aug 2019 13:19:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B9866B0007; Fri, 16 Aug 2019 13:19:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A85A6B000A; Fri, 16 Aug 2019 13:19:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 469CC6B0006
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:19:07 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DA49D1A4DC
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:19:06 +0000 (UTC)
X-FDA: 75828951492.22.dogs01_89b5a0e23b644
X-HE-Tag: dogs01_89b5a0e23b644
X-Filterd-Recvd-Size: 5852
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:19:06 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id k13so6830205qtm.12
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:19:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=aAuJkx3tYtzzL6W59IWOcvDtZCZIe1mJoCimZUlEFnw=;
        b=kbat1qAeKGkrmhubzeBSEX8UlXXey9lnVfQ/Vx0g766LW7GP2lpryQR7t+0vkFRRGb
         Jbg7BZUZkb7DQaUs/r2IBK+ejH2xzPCnmBv1XUEwYR4RJushKgYjcaKQFI1RQe5rxK2u
         iur/yAF+59Yi7khOcb0j1JRo9YgGqPOFo6YmToQ8a2GmkZUYQJzcSUeijq+xHVelXCf1
         SOBFkRoNZd6kH5Ae3nP7KGtraL7KLomnzgXBrJ+y2e8mrPRSpM/Bdc74HMV39ga4awdz
         VMW6PcO2Z8gNJRCIQXyLtl+PzOxTnwGROhY174YQjkrcOzSPj7hlg9pNW9UlEhadULXM
         hQ+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=aAuJkx3tYtzzL6W59IWOcvDtZCZIe1mJoCimZUlEFnw=;
        b=YVVSizXR/Njzif2j/fzdcL7siu0evGtg4iHD70mISCqw8byoh+m8sHhMFw+NlKPoXg
         so7MhxFPpt24gTJIKQkw0VN+V/cBAAH1FvwYujU3a4HzfCmwlMqN8sEGE23ZC30BRluF
         COm5vewfkp+wCgvYaK9/LdpqYsrxSJaLiv9gvbjbX/jNInHvMIo8km5FMoHFbiCODjTr
         YSJJ58PXAnV9JLiXnrSfOgYctgUmEYz6W4aAwu33ACWrmaF7JP2JwToUmQMJep24hYK/
         o5jlsadxKWv1NFgSY198/Gva2sGFwMm0YB59RtjtYp9nQWQZTfS/TnvNmfrU8Zkfur0V
         HB/Q==
X-Gm-Message-State: APjAAAUAZPLrkeIk284LU7KUTS8rB9dhQBVd5LvTFIU2L89b8BsSQL+b
	qclUb7ZbOK3do199Lquf23xZAg==
X-Google-Smtp-Source: APXvYqwT9qpP8xS/SEWzOUT0qxlqBNBY2XPEKDcBsyQzLY2w+EuruYBh4SnhqRD+DeiOPjnm58LqcA==
X-Received: by 2002:ac8:450c:: with SMTP id q12mr9723027qtn.298.1565975945646;
        Fri, 16 Aug 2019 10:19:05 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f133sm3160880qke.62.2019.08.16.10.19.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 10:19:05 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyfsW-0000pk-Hu; Fri, 16 Aug 2019 14:19:04 -0300
Date: Fri, 16 Aug 2019 14:19:04 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	David Rientjes <rientjes@google.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 1/5] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20190816171904.GA3166@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-2-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190814202027.18735-2-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:20:23PM +0200, Daniel Vetter wrote:
> Just a bit of paranoia, since if we start pushing this deep into
> callchains it's hard to spot all places where an mmu notifier
> implementation might fail when it's not allowed to.
>=20
> Inspired by some confusion we had discussing i915 mmu notifiers and
> whether we could use the newly-introduced return value to handle some
> corner cases. Until we realized that these are only for when a task
> has been killed by the oom reaper.
>=20
> An alternative approach would be to split the callback into two
> versions, one with the int return value, and the other with void
> return value like in older kernels. But that's a lot more churn for
> fairly little gain I think.
>=20
> Summary from the m-l discussion on why we want something at warning
> level: This allows automated tooling in CI to catch bugs without
> humans having to look at everything. If we just upgrade the existing
> pr_info to a pr_warn, then we'll have false positives. And as-is, no
> one will ever spot the problem since it's lost in the massive amounts
> of overall dmesg noise.
>=20
> v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> the problematic case (Michal Hocko).
>=20
> v3: Rebase on top of Glisse's arg rework.
>=20
> v4: More rebase on top of Glisse reworking everything.
>=20
> v5: Fixup rebase damage and also catch failures !=3D EAGAIN for
> !blockable (Jason). Also go back to WARN_ON as requested by Jason, so
> automatic checkers can easily catch bugs by setting panic_on_warn.
>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> ---
>  mm/mmu_notifier.c | 2 ++
>  1 file changed, 2 insertions(+)

Applied to hmm.git, thanks

Jason

