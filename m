Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBFDFC169C4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:11:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7117521473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:11:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="hOYO2xLY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7117521473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC0EF8E0008; Tue, 29 Jan 2019 20:11:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E71798E0001; Tue, 29 Jan 2019 20:11:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D60458E0008; Tue, 29 Jan 2019 20:11:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6710D8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:11:51 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id u17so1880814lfl.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:11:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rVg1DkhTRpDzsxVe6PPpbK2hIaaQRGR4zKTiUpSI67o=;
        b=YrUXXa+PFa/bBkP8JNlMuHwkYImOc32RIuxmUU49FCwnS18dHDWsQXLvtGruYvZT7t
         Mjv0aWaxDfeBfxD45uzoM49eHtDc2Q28cdor9rXq1qeUh+JLRwttv6ESeAeLvQ7yyoKs
         hhVqAYxbLgUV0ERN6KU7DpxeZ3iXhq/yfCcyUr76swA9mj0pnDeh/fyvAYAzPa6DjP08
         1ypS69E5+zE+xdBKhF7+9pvC+jxvk2TntxhTo1xYbPdNJJU/y2HfEime2xWP0fA3/d0a
         aFv8HlUe2xAOwgQy1jt9/V8/ozLzaiFukCJJe5VEZ/JLRKqULozxlxrowiJ2vck+nxlt
         erlA==
X-Gm-Message-State: AJcUukdHAL5O+jU1XbwTbRskNx3A8NaoubetaWrwLm/W+Wq9owVx/mdR
	ExDP5B79sfiZBGsmFH0hXUmEQE8K/wc5r60Z6hkMnXdwfQ/qScTQzHUSSb2Sypyz3CUogoC3aze
	ewtmov9rA/AGVXssrocOPSWBaXG4vCk7CqAYj3bOe2XzdnG801X34Qqg/8dPysEQylDX0feua71
	6mcV0zSkTp/0pzVERvTyG++vkpvhb2Xhm7vUdDhEL5BD4x7tvZJXVvLsPbcJ45G/hAILFpMlWIl
	OcmU4Ba9VCmjkQSDn2x8Aj6WyZj5DY0fhaM7BOc0NcMSvfu4tAq4XCzKCcxxYBVB7WOZZplpuic
	NXZ71Y0VrXwqgJpEArzinuFAv/AjeXnQRFfHZFDTKMwE+U5ANzwgmmR+bxC02hFF2vCf3cSE1Zc
	T
X-Received: by 2002:ac2:4215:: with SMTP id y21mr23344896lfh.6.1548810710439;
        Tue, 29 Jan 2019 17:11:50 -0800 (PST)
X-Received: by 2002:ac2:4215:: with SMTP id y21mr23344866lfh.6.1548810709500;
        Tue, 29 Jan 2019 17:11:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548810709; cv=none;
        d=google.com; s=arc-20160816;
        b=i0i9tgzoJ/hIJmo1ld2xd4ddFv5+cSC1Fex9VokTEwK+nMDsJjbCdn+zm4eow+ZbSy
         xkyEvTIbFNoQAHecFwgHGE/dw1Rg1EMhJAHAAirZr9MYY0JSDGgw2sC8hdrq0Q/TRtWX
         umoY2Xx76Zr2x3RdOpMaLQ1ZqjeFfNZ+8xewaCSSPeQXXjKKKmqxb6MgKMSccnnRf1mt
         3qCTRYTF223Vg8yNaapUYtUun/TDwl6DVxUtDxgm8v9AMmGDfenv+hCDkBRZTnRhQCwD
         Lnd4iDZ/9LHbCZ/8XOtynDg0zWR4qoPgykn546UYe9kvQw7+3yZE6B/2We01Pqc5NwpM
         UeWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rVg1DkhTRpDzsxVe6PPpbK2hIaaQRGR4zKTiUpSI67o=;
        b=j9z3U1c47Tl3jvhBQjOMB/sC2eCuLbEcLfWCTz1xrdZFxZ96tfgPWsdAuCwINwfyss
         ELQz9F563pXmxXpZyjyfbKR409ZJEX2J+tZ2f7c6jNQOwpn9kz8E+Fq4Zu7loJvhPZsA
         NEoqMauxsgU2nVTmsTR+h7L9tk3ubtIj24FpMlx0Co4ojE4wNyWcmyoSht5gz4hbMRGj
         iOgQo76Qb9GBE66j0lOr8wg675h/f31Hom9iFneMxF7tAYoxhgGg+z0WVMQRdENHfela
         t4Rbef6xim+0PlSX3/i6byy7Pd4tXn0XrOFjYe3fCTrUUs7KU8AQdAPJ9XBq5a3Lp8ff
         ziNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=hOYO2xLY;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22-v6sor23060ljd.6.2019.01.29.17.11.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 17:11:49 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=hOYO2xLY;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rVg1DkhTRpDzsxVe6PPpbK2hIaaQRGR4zKTiUpSI67o=;
        b=hOYO2xLYkLtgmVRFyK7PZjA1LX2+mOnjF5ONXJX8cZcKmVF2Fm0ask+Si+2TVQkZ3h
         qNWQQ85X2EYleDJmHXhSJ662GMwZg7xMCzIiOLrSXJNbRPbeNeR0ZEqsSkdBbakWy7vm
         6MUmV9KW9tdTANx0skK5iP8liJ27rdYPXABug=
X-Google-Smtp-Source: ALg8bN5bNDdpuuJttL3hbsysSoOmZMhl2u+fbuH85c+ErCvvZfN/6bsy3UycPjJ8/JEQht9cVdGQFg==
X-Received: by 2002:a2e:9ad9:: with SMTP id p25-v6mr23060569ljj.189.1548810708287;
        Tue, 29 Jan 2019 17:11:48 -0800 (PST)
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com. [209.85.167.41])
        by smtp.gmail.com with ESMTPSA id h12-v6sm1199ljb.80.2019.01.29.17.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 17:11:47 -0800 (PST)
Received: by mail-lf1-f41.google.com with SMTP id f5so16082199lfc.13
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:11:47 -0800 (PST)
X-Received: by 2002:ac2:5309:: with SMTP id c9mr21531353lfh.149.1548810706770;
 Tue, 29 Jan 2019 17:11:46 -0800 (PST)
MIME-Version: 1.0
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp> <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
In-Reply-To: <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Jan 2019 17:11:30 -0800
X-Gmail-Original-Message-ID: <CAHk-=widebSUzbugcLS2txfucxDNOGWFbWBWVseAmxrdypDBrg@mail.gmail.com>
Message-ID: <CAHk-=widebSUzbugcLS2txfucxDNOGWFbWBWVseAmxrdypDBrg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Yang Shi <shy828301@gmail.com>, 
	Jiufei Xue <jiufei.xue@linux.alibaba.com>, Linux MM <linux-mm@kvack.org>, 
	joseph.qi@linux.alibaba.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 5:01 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> >
> >     - * Context: Any context except NMI.
> >     + * Context: Either preemptible task context or not-NMI interrupt.
>
> Whereabouts in the vfree() path can the kernel sleep?

Note that it's not necessarily about *sleeping*.

One thing that vfree() really fundamentally should do is to flush
TLB's. And you must not do a cross-TLB flush with interrupts disabled.

NOTE! Right now, I think we do lazy TLB flushing, so the flush
actually is delayed until the vmalloc() when the address rolls around
in the vmalloc address space. But there really are very real and
obvious reasons why we might want to do it at vfree time.

So I'd honestly be a whole lot happier with vmalloc/vfree being
process context only. Or at least with with interrupts enabled (so
swirq/BH context would be fine, but an actual interrupt not so).

Again, this is not about sleeping. But the end result is almost the
same: we really should strive to not do vfree() in interrupt context.

                Linus

