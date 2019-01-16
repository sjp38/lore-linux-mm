Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C86EC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 07:52:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 198132082F
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 07:52:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netflix.com header.i=@netflix.com header.b="H1yszSmf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 198132082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=netflix.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3CC58E0003; Wed, 16 Jan 2019 02:52:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C4D58E0002; Wed, 16 Jan 2019 02:52:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88CF58E0003; Wed, 16 Jan 2019 02:52:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14D658E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 02:52:41 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id j24-v6so1374998lji.20
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 23:52:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pFDn5ysZInbYYMmQO8U1DXJt9AnYsoBmKkVlkjzfZYM=;
        b=e+b9DvJycprlHlPvCvPrzhegNPYTqRNTL3T0iJps/e5pcVM29MHfeNjsjY+hzDDb4K
         SccIyIeUmjc5rv+7LZq4llgyDg+VJhLDnsd+7YRllxQ5FIK2ZnhOVrW2qa8iWh/vprlG
         40r7B6BkmpAjHxvx74uHppjQq7RMk9z7xFOlU27Se1QO5mcUkFITnER9R2O5ICg5qFWd
         XQOjKys9KkjEimJy51CD5gVwJnye6N1P4oPMQw8e6mhaSm7kFVjVtRVG5w2BDLYRsSo8
         A2MhKHyJvrC1Kn8wtOVqYM7NZEWAof4ap2HYQrl7BwgY6D5KxBqKzuV/HVor7J0apdSW
         +Nhg==
X-Gm-Message-State: AJcUukd1GesyNsfYYIkfob3ocvSlz01hDu9eXCF6EyuaiZ0EOcvEMh+N
	5c8D2dwS9g1U8gcrRHW7jMvcR04Ba/IbTw85bet859322RI1Csge1doocweNPh2GMStY7NyfRq/
	/66OBkCxiuSbq/3rXHG9yJowE7TKnCl298GaHMi5WpgAGxpvFd+5xe0/nFJ9kXqEgTnHcotbAPv
	dulcRT0U5wAGeeqWJfgmE0F8+WA2YHOS43bxIFccLs1+XSmfMy6ev5OUTTCCZrrIrSWm2yE0C6G
	JTtxRHfyQ3C2D/1YVbDqBE8XXxln7WXXneYsSYUpmgOQc8RXqWIDU2H/rNxVvWRrxAGJxxMFQJP
	2DEKvzTBtUAbHtAHnt/Sdg8k+G4AG+z9MluQt+aZ0xMcG/nbCR1XBdgwADCYC6rioRDjpm0Mx0u
	Z
X-Received: by 2002:a2e:80d3:: with SMTP id r19-v6mr5568245ljg.151.1547625160063;
        Tue, 15 Jan 2019 23:52:40 -0800 (PST)
X-Received: by 2002:a2e:80d3:: with SMTP id r19-v6mr5568188ljg.151.1547625158883;
        Tue, 15 Jan 2019 23:52:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547625158; cv=none;
        d=google.com; s=arc-20160816;
        b=wD3qkw7SKBkBWyhR5UVyX0VKfN37aiApOQKlrnPZjdCwMe7X94MTaFwkYAxVmfHkLC
         7jPuDzrbBNdr/hKzJ6sIW3oXfmL7BtUjkWoLFd98ktH8N7BZ1ovM1aTzybjGh11tp02e
         UFtBdl5ChxcXitm3mOQzKsjrJSdL96bP5LFmTu5b56EZuEzxPNMIUetpiGpW2QnCvLvo
         BgEMoTovJgs+xh+Q4j5KjFGPF53AN0BjjUrd/llZzweQ5chSvJ0xQTs9e1nZtqQNS0jQ
         4HnfrDv6bodvv8ENdppqcYd3t0UpKmwahRb4wi6ulHdPShFvQ25b+v25gdCgz058vOI2
         /gjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pFDn5ysZInbYYMmQO8U1DXJt9AnYsoBmKkVlkjzfZYM=;
        b=h/DkpFrvROMKQwBOhAqKc4PsIp70Dn7V5VdDgtBDsIHKSj5vR05EilGG15DCz16yMx
         LLR8RYYdZ0bsB65ztDKc87DyQ4q4Ypxls2plCUOhYDjOnN9LARM65EyQ+H+VJ5VwSyGw
         1oYfMpVwkJsFUbA41iPMuntqi7TdbPxKBT7OOWnFHENYNtJEXCqt3ggEsHR/5wXXBo0/
         fSgLwjGE3O0CZmN+LC7OSAR7rL9baUovLtCpV5N9R60asOBBWAe1l/qj8+u7Ed0f7esZ
         iBbnrPGyYcjmmg/uTWWTUhzddvbOyY07I9VoFpteh4u8RE8qzB+iTNisoQn126oLGNc0
         t8yA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@netflix.com header.s=google header.b=H1yszSmf;
       spf=pass (google.com: domain of joshs@netflix.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joshs@netflix.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=netflix.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor1903994lfi.28.2019.01.15.23.52.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 23:52:38 -0800 (PST)
Received-SPF: pass (google.com: domain of joshs@netflix.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@netflix.com header.s=google header.b=H1yszSmf;
       spf=pass (google.com: domain of joshs@netflix.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joshs@netflix.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=netflix.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=netflix.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pFDn5ysZInbYYMmQO8U1DXJt9AnYsoBmKkVlkjzfZYM=;
        b=H1yszSmfXcQwcHnbLw+bx6wvU0WL5aTIQ5hJu2oppIOt0Vq42K4bSpXfnoXcwBVjR5
         brgret9pUAXqqW05+wgG/+qE3nE97JTVBh5q7kjUf2YxC833ygob19mk+wO+AT5p+O1X
         rTKma5dBUQPuIUephTJAIc2HUx0KSJxDJ8qO0=
X-Google-Smtp-Source: ALg8bN7F/x7ESxZ+Ge+Zcg/ER7Z0sQjuE0YhIxSxPtUPxFp88JF9rcVqkltIzGwukBCHUUfYD/Z2TxbsjIv4qqfbqN0=
X-Received: by 2002:a19:4402:: with SMTP id r2mr5614346lfa.111.1547625158227;
 Tue, 15 Jan 2019 23:52:38 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <20190116063430.GA22938@nautica>
In-Reply-To: <20190116063430.GA22938@nautica>
From: Josh Snyder <joshs@netflix.com>
Date: Tue, 15 Jan 2019 23:52:25 -0800
Message-ID:
 <CA+t-nXTfdo07EBvVo+mu8SRhrVyB=mEPLDQikHfpJue1jALJtQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, 
	Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116075225.7koQzRjpEjMkzgEEDCjY46B6aPhdO6E-Dx6MIqlOE4w@z>

On Tue, Jan 15, 2019 at 10:34 PM Dominique Martinet <asmadeus@codewreck.org>
wrote:
>
> There is a difference with your previous patch though, that used to list no
> page in core when it didn't know; this patch lists pages as in core when it
> refuses to tell. I don't think that's very important, though.

Is there a reason not to return -EPERM in this case?

>
> If anything, the 0400 user-owner file might be a problem in some edge
> case (e.g. if you're preloading git directories, many objects are 0444);
> should we *also* check ownership?...

Yes, this seems valuable. Some databases with immutable files (e.g. git, as
you've mentioned) conceivably operate this way.

Josh

