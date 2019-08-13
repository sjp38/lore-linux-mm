Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C294DC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:41:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81A612063F
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:41:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81A612063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D0CD6B0005; Tue, 13 Aug 2019 05:41:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 259C36B0006; Tue, 13 Aug 2019 05:41:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1487C6B0007; Tue, 13 Aug 2019 05:41:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0129.hostedemail.com [216.40.44.129])
	by kanga.kvack.org (Postfix) with ESMTP id E1CBB6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:41:03 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8B3C228DD1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:41:03 +0000 (UTC)
X-FDA: 75816910806.09.drain51_263ad5385453f
X-HE-Tag: drain51_263ad5385453f
X-Filterd-Recvd-Size: 2796
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:41:02 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B882D1570;
	Tue, 13 Aug 2019 02:41:01 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B39863F706;
	Tue, 13 Aug 2019 02:41:00 -0700 (PDT)
Date: Tue, 13 Aug 2019 10:40:58 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v3 0/3] mm: kmemleak: Use a memory pool for kmemleak
 object allocations
Message-ID: <20190813094058.GG62772@arrakis.emea.arm.com>
References: <20190812160642.52134-1-catalin.marinas@arm.com>
 <20190812140730.71dd7f35d568b4d8530f8908@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812140730.71dd7f35d568b4d8530f8908@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 02:07:30PM -0700, Andrew Morton wrote:
> On Mon, 12 Aug 2019 17:06:39 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> 
> > Following the discussions on v2 of this patch(set) [1], this series
> > takes slightly different approach:
> > 
> > - it implements its own simple memory pool that does not rely on the
> >   slab allocator
> > 
> > - drops the early log buffer logic entirely since it can now allocate
> >   metadata from the memory pool directly before kmemleak is fully
> >   initialised
> > 
> > - CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE option is renamed to
> >   CONFIG_DEBUG_KMEMLEAK_MEM_POOL_SIZE
> > 
> > - moves the kmemleak_init() call earlier (mm_init())
> > 
> > - to avoid a separate memory pool for struct scan_area, it makes the
> >   tool robust when such allocations fail as scan areas are rather an
> >   optimisation
> > 
> > [1] http://lkml.kernel.org/r/20190727132334.9184-1-catalin.marinas@arm.com
> 
> Using the term "memory pool" is a little unfortunate, but better than
> using "mempool"!

I agree, it could have been more inspired. What about "metadata pool"
(together with function name updates etc.)? Happy to send a v4.

> The changelog doesn't answer the very first question: why not use
> mempools.  Please send along a paragraph which explains this decision.

I posted one in reply to the patch where the changelog should be
updated.

Thanks.

-- 
Catalin

