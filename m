Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72B60C468AA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:03:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F7402082F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:03:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F7402082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 870BE6B0003; Fri,  5 Jul 2019 19:03:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FA258E0003; Fri,  5 Jul 2019 19:03:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C17B8E0001; Fri,  5 Jul 2019 19:03:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1923D6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 19:03:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so6165133edm.21
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 16:03:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HJn22kTX9fs8u4CjIrVy4b9kwXMjUE6qdR3oNGZ0s5E=;
        b=o7QonFIrmD1XULz8gByIocURrMhJtLcFcYdk1BOAgT7BzZiVyjsCno8ApXh5quC99m
         AKtjwkq4j/3MBqZ8waUtVtRbPJ1y3HQSE8TXF1pVsNKigoT0aZN05NjcOBxmOg0DjPLe
         aJ0clQvoV33VJuPUSQuU2hZF1LUQjNYvvy5e99i8Ko8EnLcFMVEuKLxeJIiR5L5B3Y9g
         PS6F1vAKgsdL3d6EARrD+7Sxgc/NVuR9gfwTZud/2P0d7hg6Ku0ofYkExm3+WDwXhMbM
         xH+E59JONTpTbK46G5tVpeRBryELEZ2ofnvfGe2NPJ5cUbTsDpcYGJ7TWiDxlhiO4xxj
         oeFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWfDTKlJ3hwrB2m+c6QNH/p8bOvqs2nK5reLuijwJuB1it4VoMl
	ymhYizy1ONFp2OXQLeZt3Nf4BiQVITHKB7rMGtbZz4QdpMEjFl6I7ZMZwJWUhMJqj++SmjTJf3K
	b7YUez51+i46Gm/ROG1V9gFzrj4J4orPx5+kNBAOMu4lz4uQY9sUOS8LuWn1agBR6fw==
X-Received: by 2002:a50:f599:: with SMTP id u25mr7243440edm.195.1562367800584;
        Fri, 05 Jul 2019 16:03:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+AaBvURvODC44zMFPaxmTSL3h07dtifhz1BmeqpLDigMhvzNXZwdIgqhjoMs+IG2TcfZJ
X-Received: by 2002:a50:f599:: with SMTP id u25mr7243390edm.195.1562367799807;
        Fri, 05 Jul 2019 16:03:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562367799; cv=none;
        d=google.com; s=arc-20160816;
        b=Lpcx8cQDkVTgzc7NZXJDwfvCWg6+RYfc+MG0wrOIUa7ZbufxqhIBjtbPAtKmeRoMJd
         QYjyOE/8TYx7AHnD4BTwSxu8JYZQcgQTqK+fHH1xgRFxOJ82JGhvkQaVwTbdBmSbDtA3
         UZOIBG4JylGkp9sw7o0LjdHzgqxbEdua8D7XC1CacNW9Tzyc5Q1ivGq57+lT8yCn9FM4
         XS8B1UjPWezmstBU/CM8KdVphKS86DiS00ZvNzXEfJcaXQzIZ+wJNZFo69jQISqJwcte
         6WC/MmRkm+7yvjoMwv2hmVpUNd2MXa1tC2vi4Zgk+66xyE+YfbOGPiujlKBKhNueZA/6
         /OPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HJn22kTX9fs8u4CjIrVy4b9kwXMjUE6qdR3oNGZ0s5E=;
        b=R291N30zF5RX3RlnDh3GJdcPzzEpFpOXVLU30QE4kbulPiYMdAkyBNCKRVCDXrC0M8
         7MRZlM6eEx0Z/x6NFGvZkotZvNEa1df2D3Fo79ijeIE4SKnhdmqKDEl8YL/P7zGdDyaS
         iPJw/PUVKwVZJyeTfPOiKC9CGfpVtP+Ac0IKbGARu1pXe+ENdBgE5lE+oBgmvBqx8vE8
         VIFAqNjso7MI1UKmwebNVAmMVNaRThaTbrV7FpLj70yP8riE5GV0kNDKJpnCilu9zdFq
         B5uzBlkLofIvibMtjT5Xq7pOumX5biSLDHXXd/b0fpDetWjT/kw7X0owFSWqnq5C6Q2c
         i6TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a15si7705120eds.392.2019.07.05.16.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 16:03:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9284BACB8;
	Fri,  5 Jul 2019 23:03:18 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 6CB3A1E300F; Sat,  6 Jul 2019 01:03:12 +0200 (CEST)
Date: Sat, 6 Jul 2019 01:03:12 +0200
From: Jan Kara <jack@suse.cz>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>, Jan Kara <jack@suse.cz>,
	kirill.shutemov@linux.intel.com, songliubraving@fb.com,
	william.kucharski@oracle.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: kernel BUG at mm/swap_state.c:170!
Message-ID: <20190705230312.GB6485@quack2.suse.cz>
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
 <20190529180931.GI18589@dhcp22.suse.cz>
 <CABXGCsPrk=WJzms_H+-KuwSRqWReRTCSs-GLMDsjUG_-neYP0w@mail.gmail.com>
 <CABXGCsMjDn0VT0DmP6qeuiytce9cNBx8PywpqejiFNVhwd0UGg@mail.gmail.com>
 <ee245af2-a0ae-5c13-6f1f-2418f43d1812@suse.cz>
 <CABXGCsOpj_E7jL9OpMX4wZbMktiF=9WOyeTv1R-W59gFMGC7mw@mail.gmail.com>
 <CABXGCsOizgLhJYUDos+ZVPZ5iV3gDeAcSpgvg-weVchgOsTjcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsOizgLhJYUDos+ZVPZ5iV3gDeAcSpgvg-weVchgOsTjcA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 05-07-19 20:19:48, Mikhail Gavrilov wrote:
> Hey folks.
> Excuse me, is anybody read my previous message?
> 5.2-rc7 is still affected by this issue [the logs in file
> dmesg-5.2rc7-0.1.tar.xz] and I worry that stable 5.2 would be released
> with this bug because there is almost no time left and I didn't see
> the attention to this problem.
> I confirm that reverting commit 5fd4ca2d84b2 on top of the rc7 tag is
> help fix it [the logs in file dmesg-5.2rc7-0.2.tar.xz].
> I am still awaiting any feedback here.

Yeah, I guess revert of 5fd4ca2d84b2 at this point is probably the best we
can do. Let's CC Linus, Andrew, and Greg (Linus is travelling AFAIK so I'm
not sure whether Greg won't do release for him).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

