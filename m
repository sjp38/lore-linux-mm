Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A83A2C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67888233A0
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:41:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="o8UdmRX9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67888233A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF87E6B033B; Thu, 22 Aug 2019 19:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA9B26B0368; Thu, 22 Aug 2019 19:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABF4C6B0369; Thu, 22 Aug 2019 19:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1886B033B
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 19:41:28 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 270E0180AD7C1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:41:28 +0000 (UTC)
X-FDA: 75851687856.09.crime81_29e1255c9c052
X-HE-Tag: crime81_29e1255c9c052
X-Filterd-Recvd-Size: 2942
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:41:27 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 684C121848;
	Thu, 22 Aug 2019 23:41:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566517286;
	bh=YtRCAC6fgsRgJnEx63ur5nyjptr+AEUs6gIrAbXRiQI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=o8UdmRX97TswzWBvjk2gFJF6KO7BY2x+E967bHezsjBUP95XqFclydiiZxQDIWGNS
	 /HK3TqMe1pG0vXyWjTqyWMiN6WOHRQ1slbrz8a4c6qtJJ6NDsk6SdUwK5hdhg43NJH
	 om2HivuzvF1RXZajtMlOuiaXDG6/WAAxgrYZQZQg=
Date: Thu, 22 Aug 2019 16:41:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Will Deacon <will@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Szabolcs Nagy
 <szabolcs.nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Kevin
 Brodsky <kevin.brodsky@arm.com>, Will Deacon <will.deacon@arm.com>, Dave
 Hansen <dave.hansen@intel.com>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Dave P Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v8 1/5] mm: untag user pointers in
 mmap/munmap/mremap/brk
Message-Id: <20190822164125.acfb97de912996b2b9127c61@linux-foundation.org>
In-Reply-To: <20190819162851.tncj4wpwf625ofg6@willie-the-truck>
References: <20190815154403.16473-1-catalin.marinas@arm.com>
	<20190815154403.16473-2-catalin.marinas@arm.com>
	<20190819162851.tncj4wpwf625ofg6@willie-the-truck>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Aug 2019 17:28:51 +0100 Will Deacon <will@kernel.org> wrote:

> On Thu, Aug 15, 2019 at 04:43:59PM +0100, Catalin Marinas wrote:
> > There isn't a good reason to differentiate between the user address
> > space layout modification syscalls and the other memory
> > permission/attributes ones (e.g. mprotect, madvise) w.r.t. the tagged
> > address ABI. Untag the user addresses on entry to these functions.
> > 
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > ---
> >  mm/mmap.c   | 5 +++++
> >  mm/mremap.c | 6 +-----
> >  2 files changed, 6 insertions(+), 5 deletions(-)
> 
> Acked-by: Will Deacon <will@kernel.org>
> 
> Andrew -- please can you pick this patch up? I'll take the rest of the
> series via arm64 once we've finished discussing the wording details.
> 

Sure, I grabbed the patch from the v9 series.

But please feel free to include this in the arm64 tree - I'll autodrop
my copy if this turns up in linux-next.


