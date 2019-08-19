Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D695C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:28:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0365822CEA
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:28:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IwzNiAfh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0365822CEA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A557E6B026B; Mon, 19 Aug 2019 12:28:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A054A6B026C; Mon, 19 Aug 2019 12:28:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F3A56B026D; Mon, 19 Aug 2019 12:28:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0186.hostedemail.com [216.40.44.186])
	by kanga.kvack.org (Postfix) with ESMTP id 703216B026B
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:28:58 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1D6D3180AD801
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:28:58 +0000 (UTC)
X-FDA: 75839711556.15.light16_140b1427fdf48
X-HE-Tag: light16_140b1427fdf48
X-Filterd-Recvd-Size: 2588
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:28:57 +0000 (UTC)
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8C42A22CE3;
	Mon, 19 Aug 2019 16:28:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566232136;
	bh=eGKGObceNP/kBZluizhrqLdVLBQt/wNSMAHMZmxEDOY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=IwzNiAfhnewbiG7/94zFyMyWxOYy2jaAbbx/TiuA7BkmAjNiX30pWMXGbanURYxcl
	 WW3UE+Hgcwaqdc+jhX57DWGiL3zbXF6acU7H8oYCHdK71zo4ewOodc+BlJ8ZyWYmnB
	 a4pYRaJb4GsCKA3HbUTeAqCAYOqpXLBvoRxUl2bU=
Date: Mon, 19 Aug 2019 17:28:51 +0100
From: Will Deacon <will@kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>, akpm@linux-foundation.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Dave P Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v8 1/5] mm: untag user pointers in mmap/munmap/mremap/brk
Message-ID: <20190819162851.tncj4wpwf625ofg6@willie-the-truck>
References: <20190815154403.16473-1-catalin.marinas@arm.com>
 <20190815154403.16473-2-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815154403.16473-2-catalin.marinas@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 04:43:59PM +0100, Catalin Marinas wrote:
> There isn't a good reason to differentiate between the user address
> space layout modification syscalls and the other memory
> permission/attributes ones (e.g. mprotect, madvise) w.r.t. the tagged
> address ABI. Untag the user addresses on entry to these functions.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  mm/mmap.c   | 5 +++++
>  mm/mremap.c | 6 +-----
>  2 files changed, 6 insertions(+), 5 deletions(-)

Acked-by: Will Deacon <will@kernel.org>

Andrew -- please can you pick this patch up? I'll take the rest of the
series via arm64 once we've finished discussing the wording details.

Thanks,

Will

