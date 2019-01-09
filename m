Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1337C43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 18:26:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E93A214C6
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 18:26:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="S25Z8OJ1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E93A214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 283118E00A0; Wed,  9 Jan 2019 13:26:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20B098E0038; Wed,  9 Jan 2019 13:26:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 122968E00A0; Wed,  9 Jan 2019 13:26:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 972DE8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 13:26:04 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id 2-v6so2042533ljs.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 10:26:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iYHo4BDWkQuib5zX71OSEA0OVBabwksHuuT/CZTIf4w=;
        b=gkjiwyH+tiCZwDNq9OhJraIA5Pd40DdI/QR65Bt80ZB4vSxeqM33aVVig+xs1Iz30w
         I4mfx8ohKZ/GsIzixVaOCk69kRmFizK+MHhov/HsKc629TR1LlbGcDKJfRhO00AlZsn8
         3X8Og6ch3CtElDJnwmktt4sBb0NZLrqgPJz3GeXBnAk6ErPo/ZgbPq82NU3ddQKff8/b
         7m2Fr2/kBbJ6dnkWb91795UrnrVwXXtQRzWqszJY1fT4jQLjtc0WSJfA41IVp2YY14ug
         66jWhmSJ40LzA5iQzlxtTZkZ+kByGNjC6tXhNdsn3ZwRkC8KHG7Gs7RbyLqBw3o43DXD
         IiTg==
X-Gm-Message-State: AJcUukdsquezZLKev8YjW5PtkaMdi3bexTUojOLSDdtQZxo7qFXWjACJ
	xf8Ves/rAqsOlxGkWQqLsA3wFtBFR6Wok92nItUYp1eRtPHa2Jxz1uK6BCacd5xEDSH0H5Bk3KU
	kuMgH11oNGOgj9Dhe/seqhEetSZFrtAbrmoo0EsPpCwUjWGbVaGxTnCJGcp2xeF75b/cNryiCJY
	iBTI9Rxz3/kyUNG0q3SxBTpdGdIpcf8B1YB+R5SGjO30eZ4Xqc3Ti9tt3S0kBnKvBCKtokl7oxW
	JqOT39nxCYNk4VhC4ictAg8pouJddyeRX/5KI/SUWS+BdXG4Qj/rPhDH3UMRbL4mXZ8rywK/xoS
	KNruLy0Z7g4QI2uJKv3bAubaz6FaOQs5kEmMgyB8ARstUKFKf1MlRJ0KuBPPy2no21aEYY5oLWn
	f
X-Received: by 2002:a2e:9ad0:: with SMTP id p16-v6mr4475634ljj.102.1547058363818;
        Wed, 09 Jan 2019 10:26:03 -0800 (PST)
X-Received: by 2002:a2e:9ad0:: with SMTP id p16-v6mr4475603ljj.102.1547058362753;
        Wed, 09 Jan 2019 10:26:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547058362; cv=none;
        d=google.com; s=arc-20160816;
        b=aY0HxIqaR0PC/fWUbegl74/jRHKfmO/ZkTuDQVpgnhDhsxCMJAL99zuaVSxFtkBaGY
         9XjhOeJK0z/63lSn7Y3SlMUqHfc+oWBBAMSi+RlN1pptMjZvl6tUEoihqDBqe2VpkpJt
         vDRJFQyC3N3w8ewEr4OeV+KePDVp19FILf1K7eIuiYm03yuR5ggv6aNFoGMymNjMBv9V
         KUuvPldF//ue/mtzo+FT08s/baVNxTrYt7jXseAbkfZnuEXuUxp6GSlW9FSHn719t2bF
         I29MOOCbsFmRrFTLq3as528mxfZJb5BYikTFLFrgzZQa/kjPhPjiv9GZp9ffSo6nCWgO
         UAYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iYHo4BDWkQuib5zX71OSEA0OVBabwksHuuT/CZTIf4w=;
        b=uS4VXZ+jyRSrU/rKFlgMlA52jiAO2tXtw/jQ2CF4TPrlgNShhwFEUtIM3f36dIdzdj
         T+rqoddhcvXhW6fhMu3TDZ50M+nYgpXKCTdAvMLw+PeSZLU9PP+msAWMxZ744yJKv9ww
         hzbuhk9T4uwIweW4W/mzwz2TQR8KwVCqSXqzhpdpKEwXzrI5qo1jddLQ0kTIdw+DtiIT
         HieoLwMBxoIFn+8fmmd3cyjoEuLDgBTxbEk8gy3A3Zu/tNUbU4ivXDGQKrvM6UMk5a63
         o3CUZ9U8Ces0Y7zYPoMZcKdcVC6iI2Shu3HA4J0TCKEW82TcY3A52DjQwAp+/7pEce+l
         V6tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=S25Z8OJ1;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22-v6sor42303303ljd.6.2019.01.09.10.26.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 10:26:02 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=S25Z8OJ1;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iYHo4BDWkQuib5zX71OSEA0OVBabwksHuuT/CZTIf4w=;
        b=S25Z8OJ1pX0QKsZYg/M0fXk3w3bXm7xAcOnQjDOREYBiQR8iMYf6faROB/7DN+39Fr
         CCHlM8Jo6MDQYsdV25OSIoh3iQT+GmLbIADo8OGLR2nu4DxhnWCrlN2q9+chgfDv5I+K
         CRUqm5AcGPUNJI+0aaNtaQLg9O32BM1sMYLWo=
X-Google-Smtp-Source: ALg8bN6TUt1QLAkxbNyZu1jy6sE2SBdHSKn/Ws+b5sy2oHzCpMPPwr/1I9lEpW3LTdFuuYER3d8UeA==
X-Received: by 2002:a2e:a289:: with SMTP id k9-v6mr4030292lja.24.1547058361572;
        Wed, 09 Jan 2019 10:26:01 -0800 (PST)
Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com. [209.85.167.54])
        by smtp.gmail.com with ESMTPSA id 11sm13967940lfq.89.2019.01.09.10.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 10:26:00 -0800 (PST)
Received: by mail-lf1-f54.google.com with SMTP id i26so6404529lfc.0
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 10:26:00 -0800 (PST)
X-Received: by 2002:a19:982:: with SMTP id 124mr3883924lfj.138.1547058359888;
 Wed, 09 Jan 2019 10:25:59 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
In-Reply-To: <20190109043906.GF27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 9 Jan 2019 10:25:43 -0800
X-Gmail-Original-Message-ID: <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
Message-ID:
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109182543.CYAIHce_lQFiEkiPYD7HhdR2KsTGFhxIEoUhkYJU2YY@z>

On Tue, Jan 8, 2019 at 8:39 PM Dave Chinner <david@fromorbit.com> wrote:
>
> FWIW, I just realised that the easiest, most reliable way to
> invalidate the page cache over a file range is simply to do a
> O_DIRECT read on it.

If that's the case, that's actually an O_DIRECT bug.

It should only invalidate the caches on write.

On reads, it wants to either _flush_ any direct caches before the
read, or just take the data from the caches. At no point is
"invalidate" a valid model.

Of course, I'm not in the least bit shocked if O_DIRECT is buggy like
this. But looking at least at the ext4 routine, the read just does

        ret = filemap_write_and_wait_range(mapping, iocb->ki_pos,

and I don't see any invalidation.

Having read access to a file absolutely should *not* mean that you can
flush caches on it. That's a write op.

Any filesystem that invalidates the caches on read is utterly buggy.

Can you actually point to such a thing? Let's get that fixed, because
it's completely wrong regardless of this whole mincore issue.

               Linus

