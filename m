Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7220C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:31:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A06D120663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:31:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A06D120663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49F808E0009; Wed, 26 Jun 2019 08:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44EA88E0005; Wed, 26 Jun 2019 08:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3169B8E0009; Wed, 26 Jun 2019 08:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED54C8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:31:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c27so3030343edn.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:31:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z4x81rLPNP/st3SgcWee8UQGPYqgJQlKQGNzV8oN/jQ=;
        b=bUulfNvsByWsC2a1PRTYy/BkLahkdLePMBHAZb8NwUEbnFHgcVl2QR0dYyN/rO7Xmk
         oBizEy40DD8BkUwvBRszghdZhhsi4kL8Enz6O3KTq36+OU9MJsPhmPSwuWyV1hvxct22
         sKVdozgcpr76exj8G/ivluFv1eWzu1e8oZhHBqhtb0plAH2NDKuibK2TIn5xHH1q45s9
         lrxKbBCWLKw95k3PSqSTXZx6PBhxmh9xLyyuHqt5+VourJ/Ra64MnZzFL/hA+Z7g7Jb2
         319fUx+6kVgxoRdtiayU/sxXr35IB13R2/sQ5E7jXak39nB0H/PN0f/aj7SVlfD1SlOC
         Udnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAW3+lurv55J5jpoRkz3rPtzMQFvjyrGTrPoKqwaM257fDCGoWQ8
	oVugl7Bs8Y06uKRI0g1x2JyuWYmot9zNGbw4DD4RO30/B7xrGhl+TLkVXezD7HOhv6uRHVf0C2v
	aJ7z4f56HgG+O0aGz2C/NFDic6j+C0G0GZJMclOmVS2iB+Pph1fpHxHZhSHpHerAk4w==
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr5001579edb.304.1561552305548;
        Wed, 26 Jun 2019 05:31:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUDYC7ByIIW/sUk+FUY5XaIbCu0bnSQeFv3fR7yXK9T5pU1vnasAGhx52gVpQE5eGrZbNu
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr5001505edb.304.1561552304834;
        Wed, 26 Jun 2019 05:31:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552304; cv=none;
        d=google.com; s=arc-20160816;
        b=neb/u4pm0jDK9y6nJqhnPpYeoSRN/jJevMHBaYQMMWfenDzBRvvvU/scsL21ni/ue+
         OSSeWryAxMkddM1fyh1SlDZJaIQ7ygSoXpdoAwto4SuxjBHeZzc2Jk5hBle1SNPVN3Q6
         oUipuJAcCL6M8G/JE/JlOf36YJFWYgrG/Oi5ajWaIOHduIDaen16/NxJef05ruIzBzPo
         2w//1yvWZTPaUrrhMJPeVvlHsqzuURbdBrnWaOyejYUmNBZALuAX8NmEYxJ1s0W3tXYK
         ZvlcICnQ5nEmnPSi7wP4N5QatBF09v+PrglkM+whY7uwzYKRDJN6mS/Pu0NQS2WPaUf4
         x1Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z4x81rLPNP/st3SgcWee8UQGPYqgJQlKQGNzV8oN/jQ=;
        b=WUyCqhjYLov82RzqAvHwDMQJUHIh7mDCSFZ1UQPRh8n4YZtOb+VX3smFcd68ph2IoZ
         CPWk+vOnzWpPF/c0AiMANz8Ory0oXp/f9rLwIOaUNdHU2d3XPq3IUyQT5zZjqtSxY4kp
         9nwIUTlxQHLKN8IQl9rhwuFY6hlx/QIoZ4ghOOaUgNwSrtRxzIpWTJsw6x1PPiMbm21R
         eHuQo4Cx8BBlvynI7qxVcKzYKgE8RrzSKC2o8k/hLGTQThXW28fsmu78jkAJv4BXTzGB
         29kkxVr1dhXUNwGIfK8AMPEC5FuEFwx7BoNY+7SAqQ+YrK4RJGslxjIfX/4XrMHoe+kL
         En1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e54si2952546eda.324.2019.06.26.05.31.44
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 05:31:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F2E41D6E;
	Wed, 26 Jun 2019 05:31:43 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 82E143F718;
	Wed, 26 Jun 2019 05:31:42 -0700 (PDT)
Date: Wed, 26 Jun 2019 13:31:40 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Robin Murphy <robin.murphy@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Jason Gunthorpe <jgg@mellanox.com>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Message-ID: <20190626123139.GB20635@lakrids.cambridge.arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <20190626073533.GA24199@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626073533.GA24199@infradead.org>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 12:35:33AM -0700, Christoph Hellwig wrote:
> Robin, Andrew:

As a heads-up, Robin is currently on holiday, so this is all down to
Andrew's preference.

> I have a series for the hmm tree, which touches the section size
> bits, and remove device public memory support.
> 
> It might be best if we include this series in the hmm tree as well
> to avoid conflicts.  Is it ok to include the rebase version of at least
> the cleanup part (which looks like it is not required for the actual
> arm64 support) in the hmm tree to avoid conflicts?

Per the cover letter, the arm64 patch has a build dependency on the
others, so that might require a stable brnach for the common prefix.

Thanks,
Mark.

