Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40C28C41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:29:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF7FC21951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:29:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="izWsAZA0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF7FC21951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EFDA6B0005; Wed, 24 Jul 2019 11:29:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A1A58E0005; Wed, 24 Jul 2019 11:29:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08FB58E0002; Wed, 24 Jul 2019 11:29:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D848D6B0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:29:02 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c79so39736235qkg.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 08:29:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JQgoJCOESUlvwXLcS69GZd2oa8cw/eE9Wf5RFGROicg=;
        b=aOic5Tb3ZZzTUTGwvvzD/h6MwBKONqiwhrg8b1JvsGQgu/QpbJ00YG/I2DJtHommvf
         bV9KaMldx5QcflvD9tzyivAIiRo5FxJW0rKXECQcj0rI+SWY/f0rDuuQiKBFn8DhYiee
         iTrGTxldNa/yDZ5OT+jz5FZVMCIQhYh8bWms4TUPASPAiufZfJYpop908a1LOm8Bj/9w
         BgXDKSZCMf3PS5iKGg5wbddnKwJg9/EdV7DA2Xs7Cw4vu6XC5wIoLKnVdPP0kE4AGSWe
         z5gIT5S2A/7wtYf/oo93SyxVEbow9xYmOCSvs9xgS0ByFytuq5gvuCvxbBTkp9Zm92we
         WVYg==
X-Gm-Message-State: APjAAAVFRaqMHwBRQmL09v6XSL2F1fFxgdtCLX8EL7qM+RfZA/Ew2mf5
	o4Q5dqIM011hvLeGdFAkyPGU6KQln1EK+RAaFFpzzwS5J2KZTAZ4CD7gCx96Eq/GuKJpYDNSoc1
	9EJ4v5h7nEHpTfluHY0A4ehfTC34Sxovi/CZbumwfIvqLNkAWdZqBYzXOoAp1iuVgVQ==
X-Received: by 2002:a37:6a87:: with SMTP id f129mr54968741qkc.183.1563982142571;
        Wed, 24 Jul 2019 08:29:02 -0700 (PDT)
X-Received: by 2002:a37:6a87:: with SMTP id f129mr54968676qkc.183.1563982141743;
        Wed, 24 Jul 2019 08:29:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563982141; cv=none;
        d=google.com; s=arc-20160816;
        b=ZNEWLRP/f/tPcSRrK0DiIJ+5+3ybguYQm/ebQFmQpZqB30tJS1BhwsIQ+5FqkfpIt7
         HxzfcY9TDTRhVC13aAIHboM3pU3/WmCgcC5X0CqFJudT0tedhbFqlVUfMbaaL2G45Psg
         xpCo7E4BIPHedvUtDnUVyBnK6ELZ2ASgvoOKZCMak6lCCfv7b6JSdxiQ0zoBePd+CDEh
         D7qxDd5M1xWDspp4mdPZ7dLVqmwdddWBT/eRydg9pozDTqoA2U9lvfOb6xJ6bjw/WS0v
         bOK+aESM5nSAeHNgyVeRFapnGwSivIAaoHu1LajKw1Js8NnX/wQCubxhcsPjPLjktviT
         3myQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JQgoJCOESUlvwXLcS69GZd2oa8cw/eE9Wf5RFGROicg=;
        b=ITddlgQwmX1+wOkemvB5Ze0yt78as8TelIUunQJ4KFkQzuzDuVLzOIpQqrGaC/xBwV
         4lufBXAUIdk3qWzH0A2Fe63P7NyPZbgNDoleZ3qze3w99KS27TdihlJfsSzASDAmMUIl
         A7ouGtRQP6pkDRH7b5M2z1noZvU4Cz+/OIAmXSQWJqLkp2AtWawbg1JQz7ey2L6oi1nM
         LRtMFXQonQZ+/46zpyL3FGFGx6BSx5lK2js0R70Ns3Ald2ZQ5apkis6/NtItQNvUvWSJ
         VCCaDhrU925PRDoFJym36xG3PlCe6Fca4IxokWlf8Eltrj4Q69OZ612KAXv+h0GUC3E6
         e4Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=izWsAZA0;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12sor26261853qkm.112.2019.07.24.08.29.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 08:29:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=izWsAZA0;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JQgoJCOESUlvwXLcS69GZd2oa8cw/eE9Wf5RFGROicg=;
        b=izWsAZA0azHmT9wRTbZAVFkqltklhgK1UgHBibwTNSCB9pHei/HARUxzgpAHeSsF/m
         itikD62Pekx0tFI05uHx0UexdgM3+2L65YLZbdB3q01eP7qN18RmfyzsdCsI0TPzA3oD
         8ikRmLbTHiDJODjJai0FM1VuxVkY2EgIQfSipHga+ACdQtczcEarab/NzStLpifIsZfZ
         VoGG4wt3FGsiYOjgZTDrKKE6P73J1yB4htRMrmvGuJR1ctzcx6R3GSgAbbdiBJUcwm19
         kNlyIaCcj1zkdx4nEJCzUKeRvaaGSaXI+TTwtbO8k1V/yineDlWhFJ50b1KGWD6jna0h
         DULg==
X-Google-Smtp-Source: APXvYqxKi2QLcH3IjvpDTI+hSuWRb995fiJ3mnkWELurbx0D00hm3DWRF/djwMbjIi+ZsrJWjfkkAQ==
X-Received: by 2002:a37:aa10:: with SMTP id t16mr54569419qke.332.1563982141185;
        Wed, 24 Jul 2019 08:29:01 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id j78sm21508733qke.102.2019.07.24.08.28.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 08:29:00 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqJCM-0001tB-LL; Wed, 24 Jul 2019 12:28:58 -0300
Date: Wed, 24 Jul 2019 12:28:58 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724152858.GB28493@ziepe.ca>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724070553.GA2523@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 09:05:53AM +0200, Christoph Hellwig wrote:
> Looks good:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> One comment on a related cleanup:
> 
> >  	list_for_each_entry(mirror, &hmm->mirrors, list) {
> >  		int rc;
> >  
> > -		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> > +		rc = mirror->ops->sync_cpu_device_pagetables(mirror, nrange);
> >  		if (rc) {
> > -			if (WARN_ON(update.blockable || rc != -EAGAIN))
> > +			if (WARN_ON(mmu_notifier_range_blockable(nrange) ||
> > +			    rc != -EAGAIN))
> >  				continue;
> >  			ret = -EAGAIN;
> >  			break;
> 
> This magic handling of error seems odd.  I think we should merge rc and
> ret into one variable and just break out if any error happens instead
> or claiming in the comments -EAGAIN is the only valid error and then
> ignoring all others here.

The WARN_ON is enforcing the rules already commented near
mmuu_notifier_ops.invalidate_start - we could break or continue, it
doesn't much matter how to recover from a broken driver, but since we
did the WARN_ON this should sanitize the ret to EAGAIN or 0

Humm. Actually having looked this some more, I wonder if this is a
problem:

I see in __oom_reap_task_mm():

			if (mmu_notifier_invalidate_range_start_nonblock(&range)) {
				tlb_finish_mmu(&tlb, range.start, range.end);
				ret = false;
				continue;
			}
			unmap_page_range(&tlb, vma, range.start, range.end, NULL);
			mmu_notifier_invalidate_range_end(&range);

Which looks like it creates an unbalanced start/end pairing if any
start returns EAGAIN?

This does not seem OK.. Many users require start/end to be paired to
keep track of their internal locking. Ie for instance hmm breaks
because the hmm->notifiers counter becomes unable to get to 0.

Below is the best idea I've had so far..

Michal, what do you think?

From 53638cd1cb02e65e670c5d4edfd36d067bb48912 Mon Sep 17 00:00:00 2001
From: Jason Gunthorpe <jgg@mellanox.com>
Date: Wed, 24 Jul 2019 12:15:40 -0300
Subject: [PATCH] mm/mmu_notifiers: ensure invalidate_start and invalidate_end
 occur in pairs

Many callers of mmu_notifiers invalidate_range callbacks maintain
locking/counters/etc on a paired basis and have long expected that
invalidate_range start/end are always paired.

The recent change to add non-blocking notifiers breaks this assumption as
an EAGAIN return from any notifier causes all notifiers to get their
invalidate_range_end() skipped.

If there is only a single mmu notifier in the list, this may work OK as
the single subscriber may assume that the end is not called when EAGAIN is
returned, however if there are multiple subcribers then there is no way
for a notifier that succeeds to recover if another in the list triggers
EAGAIN and causes the expected end to be skipped.

Due to the RCU locking we can't reliably generate a subset of the linked
list representing the notifiers already called, so the best option is to
call all notifiers in the start path (even if EAGAIN is detected), and
again in the error path to ensure there is proper pairing.

Users that care about start/end pairing must be (re)written so that an
EAGAIN return from their start method expects the end method to be called.

Since incorect return codes will now cause a functional problem, add a
WARN_ON to detect buggy users.

RFC: Need to audit/fix callers to ensure they order their EAGAIN returns
properly. hmm is OK, ODP is not.

Fixes: 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/mmu_notifier.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index b5670620aea0fc..7d8eca35f1627a 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -176,6 +176,7 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 		if (mn->ops->invalidate_range_start) {
 			int _ret = mn->ops->invalidate_range_start(mn, range);
 			if (_ret) {
+				WARN_ON(mmu_notifier_range_blockable(range) || rc != -EAGAIN);
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 					mn->ops->invalidate_range_start, _ret,
 					!mmu_notifier_range_blockable(range) ? "non-" : "");
@@ -183,6 +184,19 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 			}
 		}
 	}
+
+	if (unlikely(ret)) {
+		/*
+		 * If we hit an -EAGAIN then we have to create a paired
+		 * range_end for the above range_start. Callers must be
+		 * arranged so that they can handle the range_end even if the
+		 * range_start returns EAGAIN.
+		 */
+		hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist)
+			if (mn->ops->invalidate_range_end)
+				mn->ops->invalidate_range_end(mn, range);
+	}
+
 	srcu_read_unlock(&srcu, id);
 
 	return ret;
-- 
2.22.0

