Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7D5CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8522B206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:21:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8522B206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BB8D8E0033; Thu,  1 Aug 2019 12:21:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 392C68E0001; Thu,  1 Aug 2019 12:21:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 282688E0033; Thu,  1 Aug 2019 12:21:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE8478E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:21:54 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b14so35675320wrn.8
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:21:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=76PW5JJ4lt9H7RUWHYmu1eEKuJz7CiNTz2yMSYWClnk=;
        b=UqmfIpEXP4XDqgHo+8MlEbUicgJGXo7ZfPcpIvRVEB1e7ioUXa4AwkgenuGsTp26zV
         kV+E/j3Bl/XELK4xI5p9ost5dUeRodnKJpZ71xrnW780pKziqTBDU6ztQ5o/DppyS2JX
         j/rvd7RT/CtS4AdcuZD0853qATcHqMbxNME33PqP/6mXerLsg5m5bXuguwvDcoe4nGmW
         RIed5fYBAdV/6X7mPYxdlCKKZvuV4thcCycKLzNGSJvvMFa1XbHA+wLKC1GGqHXFYgLN
         XzOPB6zMNCTf+ZL4BXBH4hmifVNljQ5hIxmnPdDyj2Qsry9D4DSjG+GdMgnc0lpnSdFO
         0mhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXn9AIPLttG3sFfl65ju6MuRfInJkwbmOX5KjfdD25Hff2Owbt+
	3ZHfaJP0qAvcRSH3w4ydxUc9UEEYPUaCI3mjVT48md4MPk7miDx9xFtsNSDHx3zs9/eSEbibIJC
	2YtDKOWjegt6syZg7bpsPr7MIV06XGM4fngX9aj1O8xk3UZjmdgJhY0fXpv76qH4t4A==
X-Received: by 2002:a05:600c:291:: with SMTP id 17mr114660601wmk.32.1564676514397;
        Thu, 01 Aug 2019 09:21:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeI9hHg6wRl3lHJKef3j8VDIKJtjfGgc0Ci2F5PmPGHG5dKWmAzIqTqNd2E5oluq7+yhOM
X-Received: by 2002:a05:600c:291:: with SMTP id 17mr114660556wmk.32.1564676513554;
        Thu, 01 Aug 2019 09:21:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564676513; cv=none;
        d=google.com; s=arc-20160816;
        b=rbe0zoZUCyZ/xnu+S/F0nNZo9MvcQfal0H7ioE1tIgPo2EapQ1cMqJjxDA0Qa25zhs
         lECCck2ucW/VAu0zxQNXvoOkxdjX/D7C7qVLJ7iID+qlwMmHoaCBD7idaeTrpLn/ESPf
         jzfFbrh4g9maebQV/LWC5ysQ+z2fdU38jO0N+Gu8Yl40lIykuZsUKSGd+OLZCbPpY/iY
         Ep6Uc77AZuefwpk42SokxCdMKvChhccLIvyOeFCwk1fzB+Pd+n03AQHjXy4o3uwYD4d0
         E3BNwQu4kz0O61yVG/B1jTC49J+kPcwyDckxUBF/zJFkRKQcIZ6VKHZQasyKMKWhSxcA
         Ka6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=76PW5JJ4lt9H7RUWHYmu1eEKuJz7CiNTz2yMSYWClnk=;
        b=r2XGaP2eoGRsMf9W9vINo2NTSXdJ4Pji6HgMDh3b+SkccJaxJVRyrqdVw83UDlf7iH
         6d7wVAvE6nEak9xZ6XiPBqym2f2QC9STPsi3PUIyOADY7CvxfC7Or5b+83IwRXs9GGPv
         55cCe1unzwOBqgr/ByjVEeznrAyGYNJq8+y4aBi2UktbB5TiLxS51p/SAHxO6lt1tq14
         IbwKBVQP7gz3/2zYTXRB8CQTn34x9mUTFACRKqrC6IAcrnvAYN0n+HsYDKochAuQRM46
         7jlgFipDmSjBXyhhVP+hscPF7EF2htkoBXVU12NXaZve5VmD2hm5pngVsrfGkQinUdEM
         g42g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b10si65822215wrp.105.2019.08.01.09.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:21:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A955168AFE; Thu,  1 Aug 2019 18:21:48 +0200 (CEST)
Date: Thu, 1 Aug 2019 18:21:47 +0200
From: Christoph Hellwig <hch@lst.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org,
	hch@lst.de, linux-xfs@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] iomap: Support large pages
Message-ID: <20190801162147.GB25871@lst.de>
References: <20190731171734.21601-1-willy@infradead.org> <20190731171734.21601-2-willy@infradead.org> <20190731230315.GJ7777@dread.disaster.area> <20190801035955.GI4700@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801035955.GI4700@bombadil.infradead.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 08:59:55PM -0700, Matthew Wilcox wrote:
> -       nbits = BITS_TO_LONGS(page_size(page) / SECTOR_SIZE);
> -       iop = kmalloc(struct_size(iop, uptodate, nbits),
> -                       GFP_NOFS | __GFP_NOFAIL);
> -       atomic_set(&iop->read_count, 0);
> -       atomic_set(&iop->write_count, 0);
> -       bitmap_zero(iop->uptodate, nbits);
> +       n = BITS_TO_LONGS(page_size(page) >> inode->i_blkbits);
> +       iop = kmalloc(struct_size(iop, uptodate, n),
> +                       GFP_NOFS | __GFP_NOFAIL | __GFP_ZERO);

I am really worried about potential very large GFP_NOFS | __GFP_NOFAIL
allocations here.  And thinking about this a bit more while walking
at the beach I wonder if a better option is to just allocate one
iomap per tail page if needed rather than blowing the head page one
up.  We'd still always use the read_count and write_count in the
head page, but the bitmaps in the tail pages, which should be pretty
easily doable.

Note that we'll also need to do another optimization first that I
skipped in the initial iomap writeback path work:  We only really need
an iomap if the blocksize is smaller than the page and there actually
is an extent boundary inside that page.  If a (small or huge) page is
backed by a single extent we can skip the whole iomap thing.  That is at
least for now, because I have a series adding optional t10 protection
information tuples (8 bytes per 512 bytes of data) to the end of
the iomap, which would grow it quite a bit for the PI case, and would
make also allocating the updatodate bit dynamically uglies (but not
impossible).

Note that we'll also need to remove the line that limits the iomap
allocation size in iomap_begin to 1024 times the page size to a better
chance at contiguous allocations for huge page faults and generally
avoid pointless roundtrips to the allocator.  It might or might be
time to revisit that limit in general, not just for huge pages.

