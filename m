Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D248BC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 22:20:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9399820C01
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 22:20:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="g1gjiaVs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9399820C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 319A46B0006; Tue, 20 Aug 2019 18:20:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C97B6B0007; Tue, 20 Aug 2019 18:20:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DFB36B0008; Tue, 20 Aug 2019 18:20:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0008.hostedemail.com [216.40.44.8])
	by kanga.kvack.org (Postfix) with ESMTP id EC8116B0006
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 18:20:53 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 88E83181AC9AE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 22:20:53 +0000 (UTC)
X-FDA: 75844227186.29.coil80_5ef9442f99c01
X-HE-Tag: coil80_5ef9442f99c01
X-Filterd-Recvd-Size: 3888
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 22:20:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Z6ZVviRtuyf2TUYASfKOwbPfalJnz3NoFwMLit9B6E0=; b=g1gjiaVs4Puj+/mhPMATNXkaR
	jmIWbDo7zqvkJou0f1g3xQOpEFZgfod/Jw1CHF5ZD13xXs+n2SOiCDmUlT5CrcLMUcuqvdcNbhw8Z
	rCgkST4EiwHLwvk12cwyB/XXpG1tQCjq/tjxIYM4GiGGqIr+m8VaAn2s6u8yPBqr/XLZkEZsKrH/W
	AB4UXVg4DI2ItaU0UB7kGsg7xbGoPNSKMc+Qr3CqeBGdxmSzPfoTTGrqG1aVuLP3jAETItkT03aRz
	fYrDVMKXJg7H13nUA04J8WLFC+EOuCHwzAn4bHR4cajke+Cg0IcBGGf6yeihC3UwAgthgggBEJh1H
	rLOuXqtXA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0CUV-0002Ar-Az; Tue, 20 Aug 2019 22:20:35 +0000
Date: Tue, 20 Aug 2019 15:20:35 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Nitin Gupta <nigupta@nvidia.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
	mhocko@suse.com, dan.j.williams@intel.com,
	Yu Zhao <yuzhao@google.com>, Qian Cai <cai@lca.pw>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Roman Gushchin <guro@fb.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Arun KS <arunks@codeaurora.org>,
	Janne Huttunen <janne.huttunen@nokia.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC] mm: Proactive compaction
Message-ID: <20190820222035.GC4949@bombadil.infradead.org>
References: <20190816214413.15006-1-nigupta@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816214413.15006-1-nigupta@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 02:43:30PM -0700, Nitin Gupta wrote:
> Testing done (on x86):
>  - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} = {25, 30}
>  respectively.
>  - Use a test program to fragment memory: the program allocates all memory
>  and then for each 2M aligned section, frees 3/4 of base pages using
>  munmap.
>  - kcompactd0 detects fragmentation for order-9 > extfrag_high and starts
>  compaction till extfrag < extfrag_low for order-9.

Your test program is a good idea, but I worry it may produce
unrealistically optimistic outcomes.  Page cache is readily reclaimable,
so you're setting up a situation where 2MB pages can once again be
produced.

How about this:

One program which creates a file several times the size of memory (or
several files which total the same amount).  Then read the file(s).  Maybe
by mmap(), and just do nice easy sequential accesses.

A second program which causes slab allocations.  eg

for (;;) {
	for (i = 0; i < n * 1000 * 1000; i++) {
		char fname[64];

		sprintf(fname, "/tmp/missing.%d", i);
		open(fname, O_RDWR);
	}
}

The first program should thrash the pagecache, causing pages to
continuously be allocated, reclaimed and freed.  The second will create
millions of dentries, causing the slab allocator to allocate a lot of
order-0 pages which are harder to free.  If you really want to make it
work hard, mix in opening some files whihc actually exist, preventing
the pages which contain those dentries from being evicted.

This feels like it's simulating a more normal workload than your test.
What do you think?

