Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADD4DC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77BD1214AE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:51:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77BD1214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0CC76B0008; Wed, 24 Jul 2019 02:51:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E96188E0003; Wed, 24 Jul 2019 02:51:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36F48E0002; Wed, 24 Jul 2019 02:51:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85DA46B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:51:48 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b67so14107886wmd.0
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:51:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gngCecV7WjLyNPhRBdXWgOJiVdOGsSnio12VPlIEw78=;
        b=oV1/qE09B2Bsc3p/n3mM9ABXHmj3WceNRuWaNjQrWTQ6JWGY1CU42ObpJtvtIVXq4x
         TpM7SfBEycfA3+tsWUp++k4jxAiryjZOBqNlXjDEQ/kg/8Jyd4JzCUZpobMTeSNoFzTy
         LxvSqg6pkZa/xlFCR5W+xfolRRKHJXVJkaRv6s4ZM3nCDuUZAThUaW1dmkyxHQ5gMUo0
         4h+58xULBnMVk78CKrDOUO2cLbwdyAaC7NP1wFDg1MZ6A47LqCbSv+yVSuS1sbQMsFAo
         owuWXAiuDHbZtLM2YoyfDWOn1Wm1AFnQLUp3gxPTQYG0HcNnOf6g5zZIFAP3lnjBZfk4
         DAXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV7iocX8kjpvgg3LY0zWUzHHS4wrZgxIVrrxCwZChV/1GvTjovb
	p/kpoNS9lFp8Cl6s+67zsKRPcr+gYV7iZOHg3UgYGS8z9zV+vGV9vOi4wI/Cu+qoWpBCBV1Gvqf
	E8TU8z3XG92IccSyV39OxEcLBmYBP6/Lf2eQeEjqd+S9Mo7qpQHfl42EmIf7CvLILjw==
X-Received: by 2002:adf:fdcc:: with SMTP id i12mr5700308wrs.88.1563951108056;
        Tue, 23 Jul 2019 23:51:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiawCgRujmL2k5SGcMxlAEeCpDpgMCw3dUZeMkB3cL0Nd6y+sKNYX4OMU+4LrNpIQdqyGB
X-Received: by 2002:adf:fdcc:: with SMTP id i12mr5700219wrs.88.1563951107332;
        Tue, 23 Jul 2019 23:51:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951107; cv=none;
        d=google.com; s=arc-20160816;
        b=yPbPH8XgOvD4tgKHb9G8u1iOji0voEtYcLbn0KzTbn8KlJpLVWcBNuIrWAxn7iSrpH
         kU586b2Ha7d19eo8DOio9Dq4edrZprC/q/XAVwvQ261kXc8bIVBZvqffeyr3V301rAJi
         PVbPU6WAb/3xswmRHcIcv058WcaFIwR0qiPBxKKx0s/GlXnaXfWudTNa1ydHCHEZ5Fbz
         EdCp/7ytSamtNRjjk5BnXGpVg7Atfq6W/mT5M4v/cT24RIY/g2qFsQEygOjtCUxQzKHN
         eVwZl7aW8xwyGwBhqB7YJiBJF2KAxdulkk8nwMPmU3bPUeZCqgjRfYl81ROOURoczpNF
         6ygg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gngCecV7WjLyNPhRBdXWgOJiVdOGsSnio12VPlIEw78=;
        b=HSrQ72BnaaoyqkPJzDRlbPNFOPjXCOFfpxEqn6BfFjixBC05hz4UA91mdBZ2eTHclA
         jY+jqUArPfqB3pyGuonH6j184VvGTSb9Rs7vlIHQ3k70WHm/hoV4gGdrfk7HKkI49A/T
         eD+fhJiOm4oAFMKN/Rr1KcAKhhAmSfLzsJuppblNbSeDeJMp4fRSznqPTYpK12p+TvMT
         K+rboumsBaRwA9LXU/sPPDYMASW17nYRxad79U2s/5J6uVfrSyy88061QyusPYaMMEgb
         1ayeqTbSf3A+Um6boLb0gwO7auzvKo6j9tV+U1y269t25dAQFUa1IztNc6KqkFmynxxs
         ezEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j3si44760436wrs.215.2019.07.23.23.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 23:51:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6DD4768B02; Wed, 24 Jul 2019 08:51:46 +0200 (CEST)
Date: Wed, 24 Jul 2019 08:51:46 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] mm/hmm: make full use of walk_page_range()
Message-ID: <20190724065146.GA2061@lst.de>
References: <20190723233016.26403-1-rcampbell@nvidia.com> <20190723233016.26403-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723233016.26403-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 04:30:16PM -0700, Ralph Campbell wrote:
> hmm_range_snapshot() and hmm_range_fault() both call find_vma() and
> walk_page_range() in a loop. This is unnecessary duplication since
> walk_page_range() calls find_vma() in a loop already.
> Simplify hmm_range_snapshot() and hmm_range_fault() by defining a
> walk_test() callback function to filter unhandled vmas.

I like the approach a lot!

But we really need to sort out the duplication between hmm_range_fault
and hmm_range_snapshot first, as they are basically the same code.  I
have patches here:

http://git.infradead.org/users/hch/misc.git/commitdiff/a34ccd30ee8a8a3111d9e91711c12901ed7dea74

http://git.infradead.org/users/hch/misc.git/commitdiff/81f442ebac7170815af7770a1efa9c4ab662137e

That being said we don't really have any users for the snapshot mode
or non-blocking faults, and I don't see any in the immediate pipeline
either.  It might actually be a better idea to just kill that stuff off
for now until we have a user, as code without users is per definition
untested and will just bitrot and break.

> +	const unsigned long device_vma = VM_IO | VM_PFNMAP | VM_MIXEDMAP;
> +	struct hmm_vma_walk *hmm_vma_walk = walk->private;
> +	struct hmm_range *range = hmm_vma_walk->range;
> +	struct vm_area_struct *vma = walk->vma;
> +
> +	/* If range is no longer valid, force retry. */
> +	if (!range->valid)
> +		return -EBUSY;
> +
> +	if (vma->vm_flags & device_vma)

Can we just kill off this odd device_vma variable?

	if (vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP))

and maybe add a comment on why we are skipping them (because they
don't have struct page backing I guess..)

