Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0DE7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:57:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 590CC218B0
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:57:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="n/tRt296"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 590CC218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F52D6B0003; Wed, 20 Mar 2019 16:57:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A41A6B0006; Wed, 20 Mar 2019 16:57:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED3D16B0007; Wed, 20 Mar 2019 16:57:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF68A6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:57:28 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b6so4874440ywd.23
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:57:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7TKyPat2diHfhv30jcYBziI63YFmk+7ZB7yCGURrsOk=;
        b=GRqSo7nZ6hJm8TyhATTLyy7oM4Iz81PF4e7MAvRuBHfRubXgUMi4usElpRW6Bo5rn5
         5w1K4SH3Vgi2/KfOTlS1IOWzPd7e2URPzzC9xs6fyMT+p7KWyqW7LHwsSq9ZCIgiWHTQ
         8Ks/rlGarjpVrGDbopO2UfLl5rQs5D8jgxY4wOScxFJXns4KA5YCT1danLxlpLyzLXYZ
         KwNPrsHHnRYtYEKrg3bzfh9KV+z0HhcooXrSQtV6KxxkJ651nBe/1k12dzTJ8Vf/I2qW
         ByP7jItZOiByfrjAIA7qi60qNhcpiiAXTYoZrBIhCmzcvYrwlLFNKFXQAkMMPxmDzjVq
         ou9A==
X-Gm-Message-State: APjAAAWKoES4/QQurZBMzPdDWa+pNZKpAdZ8d7pF0ZRIxaLZx4hCJuM9
	BbvPb75iaCymYyVpnM03hZuxtCltVYN+wedV28Oemhe06OOjQGsEx/0dGjCCoYKXLOkhc1mqI4r
	F1PkpD9rtntET85kqK/nFD97aY1AJvgykqYFuWm34ltaVVCW/oZiVc6KjHio73VJcsQ==
X-Received: by 2002:a25:7c06:: with SMTP id x6mr8693465ybc.387.1553115448574;
        Wed, 20 Mar 2019 13:57:28 -0700 (PDT)
X-Received: by 2002:a25:7c06:: with SMTP id x6mr8693431ybc.387.1553115447848;
        Wed, 20 Mar 2019 13:57:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553115447; cv=none;
        d=google.com; s=arc-20160816;
        b=nKe0rV7m5rt7swRir35xWwLb2HvtevoJuQwwdlcKz00hcxJf2AFNng+7koPQ3R9pzG
         gRSJF+wVnOAIkp7yjGba8k0tGgZG5eU4rkT95lMUEbwQT+/WiCqgepZjtyy30Uhs5EQ5
         2eELijQs3uyRJNlA+GV0seJuSix0AugI5wkoJ+w8KaGEldCndConGEpfEkGGm+gbZu70
         a5DdYuQloVKlayZTBlkIlQYRZlqhUSQgC6hxtulTy00wvEgiXZKg+BOEzjFoLwIy1Lgc
         d/4Me/mNgLAn+oCNL4TCR1OuwuPR32cSY6FJKbaec23r/s10TNGCAwYfv+WTJbCCp7Et
         TRaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7TKyPat2diHfhv30jcYBziI63YFmk+7ZB7yCGURrsOk=;
        b=dEJjExPoWc9b9/rSMwVUC44yc8GvB4myK6p7sZPRrqWYQJSXQOg2i4JKo2DekMeukd
         86f5mvr7xQudEiY6+dywSebZFFaqVGnS3/Wze01XJNQs3YkCct0rPOOq6HfrgU/MzxpE
         Ps3hwjArPR1YD18Kv2va7HYznZ1caugsfopIAyrtfeKHvc1pOsvKv9vIuNcqTm6PEKoe
         fg5tR7YUW00gT+IVtISnGwBmhQX8UvwotpCeOvrPDeeJbesDZt3B6lqL/E41Og8hJJ8N
         F2zO3CuzYdWqi8nV63QF0aUc1Gd0AgNBoFsrtf15+DMW0HxoQ3aSyOAFgqqBYedrS5Rs
         dOjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="n/tRt296";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 130sor1055443ywm.161.2019.03.20.13.57.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:57:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="n/tRt296";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7TKyPat2diHfhv30jcYBziI63YFmk+7ZB7yCGURrsOk=;
        b=n/tRt29629ySiX3AtuVlLNum1FJJFphZldMMdvbBJx3fBa56guOATGv7CDMkOuBIjc
         lzEk19RcZMpmyKktO8DEh7EwfhTBzl7o9eU0Dnrr5jS4Aaxpqsgj8GpD9CobgAurX7Lm
         jTxmvqZHeXYvEMnn0BCfStSfCjOKIrILFOF43AXJGjAl3Tx/DKnYj2mDeAG4or7XFeZx
         ToNeHbOIFyEwmFGYilxIy66E3+V0mVcRKqxsVdDKARJBx8Lv5Pno2YySaSBM8WEB6JSY
         Zey6IfsC58wGD+Wb1AoP1n+c6OLPw6xLrTGc2fFbfv5kfQaLcwxo95kPNMrGXjaf287S
         FLhg==
X-Google-Smtp-Source: APXvYqwOKUtGkLTUXQ0H0uuntHFrKcjih1M7U3TDMxpi3QF4joDAtykhux/4NWNJEPzjdQNr2cYchQ==
X-Received: by 2002:a81:5d8b:: with SMTP id r133mr110177ywb.361.1553115447491;
        Wed, 20 Mar 2019 13:57:27 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:b52c])
        by smtp.gmail.com with ESMTPSA id x12sm1578123ywj.76.2019.03.20.13.57.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 13:57:26 -0700 (PDT)
Date: Wed, 20 Mar 2019 16:57:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v6 3/7] psi: rename psi fields in preparation for psi
 trigger addition
Message-ID: <20190320205725.GB19382@cmpxchg.org>
References: <20190319235619.260832-1-surenb@google.com>
 <20190319235619.260832-4-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319235619.260832-4-surenb@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 04:56:15PM -0700, Suren Baghdasaryan wrote:
> Renaming psi_group structure member fields used for calculating psi totals
> and averages for clear distinction between them and trigger-related fields
> that will be added next.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

