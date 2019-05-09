Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB4D7C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A279208C3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E2kz1FMl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A279208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C3406B0003; Thu,  9 May 2019 04:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 074056B0006; Thu,  9 May 2019 04:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA5CD6B0007; Thu,  9 May 2019 04:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id A02056B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 04:31:16 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id z128so1453807wmb.7
        for <linux-mm@kvack.org>; Thu, 09 May 2019 01:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FzWOYssN0isWIIe9zGhm6nETA9v2GV7Jir7OO9+o9Vw=;
        b=I0H4RpihXlFYIQc4feRwpD1sk/OT8ytzUPOcGGH2ZgUaJbSET3skZaLw4fs1jBvGxz
         082oiX6CiN8oeQRk43ZoAnaaRi6tqNqRfllzRct79+BsC19cfSWHr3T0S3vUjq6TPBua
         cXn4XNqyj0X/ifvuiK1JscVg0GYa10k7+SEkoTazD+auTRKqYKzJsIa00flUofgqmRu0
         KV9g/FUQGK4xYqsGpGchKn1JVfaE9bmKtdPioDOIHejfOT3HS3dtBs18CmKod/AoA5cu
         wgVn2gDULoG9qBaF95oItpIFIG+7UAzsAOT5JNq+++8+LUMvKyE8TQLOyrayoZCjmHn6
         sj6g==
X-Gm-Message-State: APjAAAVLjmrH8npGA6kY+8auVsPBpS34aF8Z5Sr6qMjLJ38CqU15rIFa
	rtilXu7tWp1ZN+0iGFmkC7H95iEnfWP9OFko1LTmRoOuBtSZLSc5iaTTMjdSZUb+vr7b8bJ56Yx
	oN/kr6st59oE1Ro4a/V884deWmAO7QYatdRJ+FRpYZ2xKBY5jP65qSnNVTgz0vR8=
X-Received: by 2002:a1c:cb8f:: with SMTP id b137mr1893540wmg.142.1557390676221;
        Thu, 09 May 2019 01:31:16 -0700 (PDT)
X-Received: by 2002:a1c:cb8f:: with SMTP id b137mr1893495wmg.142.1557390675448;
        Thu, 09 May 2019 01:31:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557390675; cv=none;
        d=google.com; s=arc-20160816;
        b=gk1pJVpWTpEBn7CQEQDcKUcKhIQYYFWZ8mbJd9Bd7t6JoTyMKe5vP13EjHGhaEFjZM
         HDIwUzXn8H2jmUKHt3nXNthe0U0Udc5dUY2uB9BhDb81Pe9N6kORtLuSUkN0yFZnFmN8
         8wxDi6KxuJ3K+YYHDRT54ayrG1fZXpWD0+wpxXLn2OMc4gGLOy+aTHOKBT0QL9M+ZYHs
         RCHerOGHwershZCKAMtp5OCkhWOgR+XqgrN70gjZh/YNJNPHtWDd/2JE5KbK29Vm8BrU
         9X/vNJLoMYGquD7ZTZmzm/MsyDYxO1EOy1UmRh51lwJPE4P9r5D2F2kpZOdmS4k6jN9d
         u9xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=FzWOYssN0isWIIe9zGhm6nETA9v2GV7Jir7OO9+o9Vw=;
        b=oJeqaQls4/br7OE+i3qZ3gi6dbEqYomCzxbEngxlbzcfivbg8evbitraHrtLcYrF0X
         WvAjmD0YFoSWOeq1GYUl+KNjOC+8G4Ewcu+lGfsfFo8XS3Xpi5E6FADuSfsS5zxEJy79
         a1uWR10MQbkrnnnBYI7aYAnBMTXMCQopb8GHeh2FIaAUsSYL/jAv9mppKGf5h0E0ZQ+h
         59AaNhwqnL0J9TMP4xfuAUdLgTjvXZKC+9VHGrTrxWaVYAhvbrbV/BP+jfl4fyaGc7pA
         0fpOjXIGS2C4YOol9y5cbDxJGyXMfX8GaVvqsaC42Vz7GdcaHwTBfhv+XK28D612PVPR
         XIWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E2kz1FMl;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p18sor807480wmg.10.2019.05.09.01.31.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 01:31:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E2kz1FMl;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FzWOYssN0isWIIe9zGhm6nETA9v2GV7Jir7OO9+o9Vw=;
        b=E2kz1FMl83tN2ABjW1mJurOeaAAcQShe1pSdN0kxvumUhNTI+TqC+JXIZb1PePIKJJ
         ysk3UkyIsJU1IyF0QX1bzY9ls8u7jx8KohqfGd2WpkooA64l95qf7m/i1PXKKqW34KQF
         NNcpCM/IAQlJ5s4gyXGZ9cMqAAd7CUf1vozzxU8QOI5PMk0lgpQQKZzWT1hz9HGssOvu
         uKSWLGBKVYuEifUSTdaTScT7ZUK/rBVNeKSLxaCEgLJEzr+DuN5HYR3Wm+13avez/Z+N
         IK5ls6J3TdDfsYGUe0WoryVlVbiG8KYRYsN6OokIHADtlhOTcp6Zf1M8DSc7jpHqbyfy
         gN6A==
X-Google-Smtp-Source: APXvYqwbP80+SsW7YO75fRTZDEwGG81tyowfGAEzJg/Pgbxk1mNQT7/K4RNdohJEwe6Atj6WEY8WAQ==
X-Received: by 2002:a7b:c309:: with SMTP id k9mr1995617wmj.45.1557390675018;
        Thu, 09 May 2019 01:31:15 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id x17sm1474400wru.27.2019.05.09.01.31.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 01:31:14 -0700 (PDT)
Date: Thu, 9 May 2019 10:31:11 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, rguenther@suse.de, hjl.tools@gmail.com,
	yang.shi@linux.alibaba.com, mhocko@suse.com, vbabka@suse.cz,
	luto@amacapital.net, x86@kernel.org, akpm@linux-foundation.org,
	linux-mm@kvack.org, stable@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-um@lists.infradead.org,
	benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
	linux-arch@vger.kernel.org, gxt@pku.edu.cn, jdike@addtoit.com,
	richard@nod.at, anton.ivanov@cambridgegreys.com
Subject: Re: [PATCH] [v2] x86/mpx: fix recursive munmap() corruption
Message-ID: <20190509083111.GA75918@gmail.com>
References: <20190419194747.5E1AD6DC@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190419194747.5E1AD6DC@viggo.jf.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> Reported-by: Richard Biener <rguenther@suse.de>
> Reported-by: H.J. Lu <hjl.tools@gmail.com>
> Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: x86@kernel.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: stable@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-um@lists.infradead.org
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: linux-arch@vger.kernel.org
> Cc: Guan Xuetao <gxt@pku.edu.cn>
> Cc: Jeff Dike <jdike@addtoit.com>
> Cc: Richard Weinberger <richard@nod.at>
> Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>

I've also added your:

  Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Because I suppose you intended to sign off on it?

Thanks,

	Ingo

