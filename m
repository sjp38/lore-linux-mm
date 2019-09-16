Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2DA3C4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 12:38:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C36D214D9
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 12:38:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="MSya7p2w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C36D214D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAC466B0005; Mon, 16 Sep 2019 08:38:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A36A86B0006; Mon, 16 Sep 2019 08:38:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FD876B0007; Mon, 16 Sep 2019 08:38:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0088.hostedemail.com [216.40.44.88])
	by kanga.kvack.org (Postfix) with ESMTP id 686DE6B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 08:38:44 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id F2DA7181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 12:38:43 +0000 (UTC)
X-FDA: 75940737768.02.hand63_4c2620b3c6863
X-HE-Tag: hand63_4c2620b3c6863
X-Filterd-Recvd-Size: 4713
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 12:38:43 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id y135so7256792wmc.1
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:38:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IiRM+xKsPPNK785AJHQsNvEaX+ovm8iVciZ5WRWgrGo=;
        b=MSya7p2w88scUXvlz98XKL839WdwgzcdR4e2c1DXE4eOQlRenBDSNNLPDRs0IBHpyK
         QN8EbT057HBSioqhR9FYeO0Kzf/hShNdk2kw542WUi50aQmeioCsaZx88eXedEeRTIT2
         dEKaZ48m4fdmYRxVbnMGpxN38KOvJC0NWuGoEmPYUK4W1bYYktiL1iud1/mJ3IDDt+Ti
         X3LT0yXq5unvXzHMeEH/7s4j1UwqOD1/S7MkM/DnOm2/lmtchE0TwQMiMyP8gADA/H6b
         CcqZZOuKH+QSi4QB0YKHaLZr5zqRyf5BBcyrLdCGN6ng9Yzsen3x3+elBxwh6Z+OpK0e
         K+mw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=IiRM+xKsPPNK785AJHQsNvEaX+ovm8iVciZ5WRWgrGo=;
        b=sE6mmiprCrYk6o+d6ZdLQN6Ed118HqLAcXdxLiR1edV1cztTxjoRAZIcu/iI8WkBE4
         r8UcfWYBFiEwHa33a1cN77KqNIOIz9wa0ggYNor9XYtxEOmNDNFMhFQLO3t2DQhTX0I2
         X9TZsnmgF0X2xeVbNhUDEip52/ChpLhVYAKUKXiwFV7fxHX0t9xfzfPI7WxrGZqFDJhK
         chCrJlAVsxLyZGeufSs00iM8bucuWkat7mgeOFXbFSZYMuCA3U/V4/L/kd75bsRA7SnU
         NdTHF51gvJPNQV6+BBbDWze1SV2NNEjYdsUPNHE5uhAPdUplue9NCzKpD6ML6t6c/lGs
         BXLg==
X-Gm-Message-State: APjAAAW539eUcPfsbQpcJyfojQ2ys4gur72EtolVbKu5BT1E/EQDS2UH
	GxuyuU9aRRlfFlxc2emmNGm2ng==
X-Google-Smtp-Source: APXvYqz2RN/K97dd9WIaMIXyQ8k7wcTOQ5AtOTodcCyzrtMA1lfpcmF3AAoV82XONyqEDdGcS7KH9Q==
X-Received: by 2002:a1c:e008:: with SMTP id x8mr13412322wmg.85.1568637521851;
        Mon, 16 Sep 2019 05:38:41 -0700 (PDT)
Received: from localhost (p4FC6B710.dip0.t-ipconnect.de. [79.198.183.16])
        by smtp.gmail.com with ESMTPSA id m16sm10785101wml.11.2019.09.16.05.38.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 05:38:41 -0700 (PDT)
Date: Mon, 16 Sep 2019 14:38:40 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH RFC 04/14] mm: vmstat: convert slab vmstat counter to
 bytes
Message-ID: <20190916123840.GA29985@cmpxchg.org>
References: <20190905214553.1643060-1-guro@fb.com>
 <20190905214553.1643060-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905214553.1643060-5-guro@fb.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 02:45:48PM -0700, Roman Gushchin wrote:
> In order to prepare for per-object slab memory accounting,
> convert NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE vmstat
> items to bytes.
> 
> To make sure that these vmstats are in bytes, rename them
> to NR_SLAB_RECLAIMABLE_B and NR_SLAB_UNRECLAIMABLE_B (similar to
> NR_KERNEL_STACK_KB).
> 
> The size of slab memory shouldn't exceed 4Gb on 32-bit machines,
> so it will fit into atomic_long_t we use for vmstats.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Maybe a crazy idea, but instead of mixing bytes and pages, would it be
difficult to account all vmstat items in bytes internally? And provide
two general apis, byte and page based, to update and query the counts,
instead of tying the unit it to individual items?

The vmstat_item_in_bytes() conditional shifting is pretty awkward in
code that has a recent history littered with subtle breakages.

The translation helper node_page_state_pages() will yield garbage if
used with the page-based counters, which is another easy to misuse
interface.

We already have many places that multiply with PAGE_SIZE to get the
stats in bytes or kb units.

And _B/_KB suffixes are kinda clunky.

The stats use atomic_long_t, so switching to atomic64_t doesn't make a
difference on 64-bit and is backward compatible with 32-bit.

The per-cpu batch size you have to raise from s8 either way.

It seems to me that would make the code and API a lot simpler and
easier to use / harder to misuse.

