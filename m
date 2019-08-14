Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 444BBC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 22:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D99182064A
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 22:27:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kgdL+2Si"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D99182064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E5126B0003; Wed, 14 Aug 2019 18:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4946B6B0005; Wed, 14 Aug 2019 18:27:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ABF46B0007; Wed, 14 Aug 2019 18:27:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 19E6C6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:27:08 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B7CC5180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:27:07 +0000 (UTC)
X-FDA: 75822470094.24.love22_5b01dd592cb5c
X-HE-Tag: love22_5b01dd592cb5c
X-Filterd-Recvd-Size: 3782
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:27:05 +0000 (UTC)
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 97C652064A;
	Wed, 14 Aug 2019 22:14:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565820888;
	bh=UI7guIwUhxj2d7avxjaE7hMxiiSK2A0bwoAKP8qw2sk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=kgdL+2SiVRNwSW1JH17ZCHCofzHSIpTR4YWsnpsl1DebWSKDpe5dUCISgu8Up/S+V
	 wgHLmG+J9tdZ0hOfZk+W2Gz3gtDTZ1kwYLUSkUSYDNbrgubOrLmnymmaQQqM86LjYb
	 4pgir0WNhhiFRt0JrlAp8mqwek9vmFjP5iLFjw8w=
Date: Wed, 14 Aug 2019 15:14:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, DRI Development
 <dri-devel@lists.freedesktop.org>, Intel Graphics Development
 <intel-gfx@lists.freedesktop.org>, Michal Hocko <mhocko@suse.com>,
 Christian =?ISO-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David
 Rientjes <rientjes@google.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Jason Gunthorpe
 <jgg@ziepe.ca>, Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 1/5] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-Id: <20190814151447.e9ab74f4c7ed4297e39321d1@linux-foundation.org>
In-Reply-To: <20190814202027.18735-2-daniel.vetter@ffwll.ch>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
	<20190814202027.18735-2-daniel.vetter@ffwll.ch>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Aug 2019 22:20:23 +0200 Daniel Vetter <daniel.vetter@ffwll.ch> wrote:

> Just a bit of paranoia, since if we start pushing this deep into
> callchains it's hard to spot all places where an mmu notifier
> implementation might fail when it's not allowed to.
> 
> Inspired by some confusion we had discussing i915 mmu notifiers and
> whether we could use the newly-introduced return value to handle some
> corner cases. Until we realized that these are only for when a task
> has been killed by the oom reaper.
> 
> An alternative approach would be to split the callback into two
> versions, one with the int return value, and the other with void
> return value like in older kernels. But that's a lot more churn for
> fairly little gain I think.
> 
> Summary from the m-l discussion on why we want something at warning
> level: This allows automated tooling in CI to catch bugs without
> humans having to look at everything. If we just upgrade the existing
> pr_info to a pr_warn, then we'll have false positives. And as-is, no
> one will ever spot the problem since it's lost in the massive amounts
> of overall dmesg noise.
> 
> ...
>
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -179,6 +179,8 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  				pr_info("%pS callback failed with %d in %sblockable context.\n",
>  					mn->ops->invalidate_range_start, _ret,
>  					!mmu_notifier_range_blockable(range) ? "non-" : "");
> +				WARN_ON(mmu_notifier_range_blockable(range) ||
> +					ret != -EAGAIN);
>  				ret = _ret;
>  			}
>  		}

A problem with WARN_ON(a || b) is that if it triggers, we don't know
whether it was because of a or because of b.  Or both.  So I'd suggest

	WARN_ON(a);
	WARN_ON(b);


