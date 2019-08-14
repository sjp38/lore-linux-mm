Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2299CC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C879E20651
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:01:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pi6KnQed"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C879E20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 525C16B0005; Wed, 14 Aug 2019 17:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AECA6B0006; Wed, 14 Aug 2019 17:01:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39DBD6B0007; Wed, 14 Aug 2019 17:01:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0054.hostedemail.com [216.40.44.54])
	by kanga.kvack.org (Postfix) with ESMTP id 12F376B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:01:31 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 95D508248AA2
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:01:30 +0000 (UTC)
X-FDA: 75822254340.05.grade86_47590b473032b
X-HE-Tag: grade86_47590b473032b
X-Filterd-Recvd-Size: 2923
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:01:30 +0000 (UTC)
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CFD9E20651;
	Wed, 14 Aug 2019 20:56:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565816169;
	bh=/47vrJUcPnKmlW6QGCuX38MeKmclx+u9kcMLBRaqbs4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=pi6KnQedP5wNrNC9WqJkX3iCMipQiegirC5UJ923ryfPZa6rrSPNcrL5FvjWNzJXe
	 uEFWtt5gQsv862Iv7+Ak1EKlQ+6njDmiCuKvxWLGmoM9pJ6Yd4U9QopjJbdgxB9+VC
	 biiBIGKf53FEg32rV49NF8iWU1PTqPGbKbe77Sa0=
Date: Wed, 14 Aug 2019 13:56:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arun KS
 <arunks@codeaurora.org>, Oscar Salvador <osalvador@suse.de>, Michal Hocko
 <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Dan Williams
 <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 4/5] mm/memory_hotplug: Make sure the pfn is aligned
 to the order when onlining
Message-Id: <20190814135608.a449ca5a75cd700e077a8d23@linux-foundation.org>
In-Reply-To: <20190814154109.3448-5-david@redhat.com>
References: <20190814154109.3448-1-david@redhat.com>
	<20190814154109.3448-5-david@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Aug 2019 17:41:08 +0200 David Hildenbrand <david@redhat.com> wrote:

> Commit a9cd410a3d29 ("mm/page_alloc.c: memory hotplug: free pages as higher
> order") assumed that any PFN we get via memory resources is aligned to
> to MAX_ORDER - 1, I am not convinced that is always true. Let's play safe,
> check the alignment and fallback to single pages.
> 
> ...
>
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -646,6 +646,9 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  	 */
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1ul << order) {
>  		order = min(MAX_ORDER - 1, get_order(PFN_PHYS(end_pfn - pfn)));
> +		/* __free_pages_core() wants pfns to be aligned to the order */
> +		if (unlikely(!IS_ALIGNED(pfn, 1ul << order)))
> +			order = 0;
>  		(*online_page_callback)(pfn_to_page(pfn), order);
>  	}

We aren't sure if this occurs, but if it does, we silently handle it.

It seems a reasonable defensive thing to do, but should we add a
WARN_ON_ONCE() so that we get to find out about it?  If we get such a
report then we can remove the WARN_ON_ONCE() and add an illuminating
comment.



