Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43FDFC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:33:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBC9B21773
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:33:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Zy3xCsAb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBC9B21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92D906B000D; Tue, 23 Apr 2019 12:33:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DD4C6B000E; Tue, 23 Apr 2019 12:33:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F34D6B0266; Tue, 23 Apr 2019 12:33:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA5C6B000D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:33:58 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id n203so4430737ywd.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:33:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TolbT1QPUIdwqm2uGYI4wXP0HSK5nG5glRgtevP7FL0=;
        b=HNZ4cAzATRJoLLa36VMh+oE4IwWs/yCVNZinpuhTJA/bA/XtWhhfN7jHPBQaifNq/5
         GXBWM+CnGyNbBg++i7C5d5+cueIZrIES7bfQhJ1yGRpNgt/pYXOI7xefVDBSwsdz6IHg
         JwAd/TQQDYZ6D8TiUacTjS5BMPdBtNsKyr75cxJoRABMb/36TO96EdIjwoaJxgiYVhd9
         dM7pzrit2A01DjVacAWLuri5LKOAr0nVgd5SLuivx8iu4jEwSxCv9W8QEKvJzP+bQiVU
         evOBHGcMM8k1lL7E3+ejWibVjbpUvbs9Oc2yazWGinhutFUoA1WccwzCME9bMKnVWlz3
         H/nQ==
X-Gm-Message-State: APjAAAXWL3Cx2JYVI2NAoHdLWbM83JcDlbsYyYBOYatC4sj6X5A2pQlD
	zUS88fqqJ9TSXSctgEQO78mxZUqS69g2RKqgzUXD2POBtOqU87O74WVPESkSHyKK/0R/VNyb+yp
	DbT17Bug/rjhzamtOFnV8jRJJ9vWr1xAYXsz2+xvjcnS9TfUtxh//Lw/e0mSpFn4Dsw==
X-Received: by 2002:a25:9784:: with SMTP id i4mr23363762ybo.394.1556037237964;
        Tue, 23 Apr 2019 09:33:57 -0700 (PDT)
X-Received: by 2002:a25:9784:: with SMTP id i4mr23363698ybo.394.1556037237168;
        Tue, 23 Apr 2019 09:33:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037237; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+HhlkAK3VA7WH0DdIglIt/fE/YeQGcShecXGvivV88F3GVAdxgbLS6w1hXQH4fxMI
         6gM1EVH9e3lGW3Ps4ZyrsKwtqKg4sdHOXTeRy8Wc93HNLtCUONuXun8smuHnWeWNKjpu
         SOfODVvmFKriNJ7MaV/L8z1ptc5LHQx2/kix4Ea0X7ixJ0v5mRDKgFSVELDumS4BbX8X
         b5jISP3alwM/UiwN0Wg3Uw9crrBLLbKjyFI9zIUSbnVffEYBVs8peJXx63CeXB1mHhWY
         KeL9TACXwDXlMtfiD1bzhV34dmNcNv4NT9cLw+g4GH7f7oNzwp7FGHxWvilrfFrDwpdf
         HpAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TolbT1QPUIdwqm2uGYI4wXP0HSK5nG5glRgtevP7FL0=;
        b=IkcFECLzIrnsFvS/+HqnQ1eyNGhqBWa7tzjHO6KP/f1jQMnMiTSjyn6JDnFa2z1lqj
         yw3e/vJAKuEAJBadQrLDw6YrGNFPzRFspOA3PMlSJLTVuzrvXVPpIH6BenBAXJEG/ueX
         3K+NLW0tdwRU7XhkstbLeIUzUerpsGd7UZ0lu9OzbutpUAvVN/BlE5LKtRyc0GJ4yG+b
         85QLR6YeCq6dNobpgfOEXWOrF9qUsfS/L8vSIH4iC8CJlZpne4ZOWtwYgrHv2P1aThnI
         f5MzyLJFMHdoUVXsKI5oAL5MPeuShBiTtFzw28U/LFumZkciMGKZHb5ZAphuf76UgwXC
         RcxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Zy3xCsAb;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l27sor7148499ywk.134.2019.04.23.09.33.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 09:33:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Zy3xCsAb;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TolbT1QPUIdwqm2uGYI4wXP0HSK5nG5glRgtevP7FL0=;
        b=Zy3xCsAbKxpewguwrviMi8vLNDRMq7JWV4d2LrBs7AdZ0qPu8Vru/Me+itIS7z2Bav
         m1X0/1VSwX/0bh+dtLvwpsHugeW0KR39mO6d5xBAJuDDf6B8V5WVj0FnrvGbz3oWTkRY
         Ad6+bX9Li0J4jsdfU8QghcGU0wYDrtBFHO2u8bvcv/HlGljEPAECABw7++QGzOETqBqx
         I1yz7fkQ0aE6SgE95sj2L4ZOcceLOIe0SSjjSRn4EVBpoj+OgLDQ2JpsLmT0Pu4p6Q2i
         z+9lDDfJCqKzEwyuXYok9tGjc8GpGSQjVWzSjIhGjQ2XmoxFskOYA4wkQpqr89MGJMpT
         7Jxw==
X-Google-Smtp-Source: APXvYqznF4m0j7Zo/Q+sgV8dYXrLO4V1jSMU20hi8stbYk/B4mddDnDfxPsLIWo96QXu5O4I68JSdBxCm2dJirsVV+0=
X-Received: by 2002:a0d:f804:: with SMTP id i4mr21943699ywf.345.1556037236450;
 Tue, 23 Apr 2019 09:33:56 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
 <20190423155827.GR18914@techsingularity.net>
In-Reply-To: <20190423155827.GR18914@techsingularity.net>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 23 Apr 2019 09:33:44 -0700
Message-ID: <CALvZod7-_RgMiA-X2MdmrizWiPf3L4CtJdcbCFWiy9ZDFEc+Sw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
To: Mel Gorman <mgorman@techsingularity.net>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, 
	Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 8:58 AM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> On Tue, Apr 23, 2019 at 08:30:46AM -0700, Shakeel Butt wrote:
> > Though this is quite late, I still want to propose a topic for
> > discussion during LSFMM'19 which I think will be beneficial for Linux
> > users in general but particularly the data center users running a
> > range of different workloads and want to reduce the memory cost.
> >
> > Topic: Proactive Memory Reclaim
> >
> > Motivation/Problem: Memory overcommit is most commonly used technique
> > to reduce the cost of memory by large infrastructure owners. However
> > memory overcommit can adversely impact the performance of latency
> > sensitive applications by triggering direct memory reclaim. Direct
> > reclaim is unpredictable and disastrous for latency sensitive
> > applications.
> >
> > Solution: Proactively reclaim memory from the system to drastically
> > reduce the occurrences of direct reclaim. Target cold memory to keep
> > the refault rate of the applications acceptable (i.e. no impact on the
> > performance).
> >
> > Challenges:
> > 1. Tracking cold memory efficiently.
> > 2. Lack of infrastructure to reclaim specific memory.
> >
> > Details: Existing "Idle Page Tracking" allows tracking cold memory on
> > a system but it becomes prohibitively expensive as the machine size
> > grows. Also there is no way from the user space to reclaim a specific
> > 'cold' page. I want to present our implementation of cold memory
> > tracking and reclaim. The aim is to make it more generally beneficial
> > to lot more users and upstream it.
> >
>
> Why is this not partially addressed by tuning vm.watermark_scale_factor?

We want to have more control on exactly which memory pages to reclaim.
The definition of cold memory can be very job specific. With kswapd,
that is not possible.

> As for a specific cold page, why not mmap the page in question,
> msync(MS_SYNC) and call madvise(MADV_DONTNEED)? It may not be perfect in
> all cases admittedly.
>

Wouldn't this throw away the anon memory? We want to swapout that. In
our production we actually only target swapbacked memory due to very
low page fault cost from zswap.

Shakeel

