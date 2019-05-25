Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53614C07542
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 17:06:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C75620879
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 17:06:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="ZvNWnuQZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C75620879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E0A86B0003; Sat, 25 May 2019 13:06:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96A646B0005; Sat, 25 May 2019 13:06:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 859546B0007; Sat, 25 May 2019 13:06:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 208D56B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 13:06:05 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e20so2387164ljg.11
        for <linux-mm@kvack.org>; Sat, 25 May 2019 10:06:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eUnPUEw25xH84DOq6zJ0v6Aw5NodbUsM/I1jFeyU0KM=;
        b=LEb7LESdBma3Uid9zjRuWyRLgWPVp90k+aVG2UwdTvCIcv+4iz6+8c8rvrEUOhitzX
         t4uMAnm7K+sIhxaRsPRIYN5LFKv4EMmqELQn1mFTDhKq48Uqr+X1+POxBPq+dXpU6Pvg
         /bVaHAp5v+2R5Nlb2vJJoOaW13YjMg7siaWgehc4cpJu3YA0GuRlaIz5ovqBnFt49Az1
         H3J+pQobeNVBxzPgGzr74L+1SGuJeIuP0MZaYeh5FsURfphrEG6vHMAJG8+2b3A9QWo4
         9Qu8x0CUx9wI4XtdTuN3QLTYd8ZHF3db8kP23ERPokcj1X59hUX2skfslUi32UWuXsAW
         R6kg==
X-Gm-Message-State: APjAAAWpFvubDVRCWega8F8aE/BLtedQ0QWRLMCXeZYCjg934hpgDQ8N
	SqkPu/aBx3rxoFaRV0s0Os1WdNaFyu/POrR1WQGDSnzgIfJ6oKg/sMMkp6zlD84FrBsGLK0k8Sq
	wn5iQNiVV1enX2jIjWkafgirW6wmaInsgrPCchaSr+9NvLFsZ8SnRyWgsG1/0rhzHsg==
X-Received: by 2002:ac2:4990:: with SMTP id f16mr1934225lfl.93.1558803964295;
        Sat, 25 May 2019 10:06:04 -0700 (PDT)
X-Received: by 2002:ac2:4990:: with SMTP id f16mr1934204lfl.93.1558803963536;
        Sat, 25 May 2019 10:06:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558803963; cv=none;
        d=google.com; s=arc-20160816;
        b=oLo6zHIaOriEDfFIW1HNZ3b41MlL/uoUJnX01SG5lbtLy2YPm7l8ZadhHCE6QgunqQ
         3dcNUbKnRAgunoaLvfO+rLSqlR1pTKQ1MluXZDXOHuxTsWOrsmusJ/cPNUN4hGDfSwo+
         N1r3YmaY5LI1Ierat3LmGOXvKBZEW/qvL6zoXAtkIzfFoBSrdjZ4njggsBEfXJIKbHgA
         Rkh6OtbQk1yN4HvcagBnHomY9wJjUAW+1bRen3+1KRwWuOiu8YZs/mpcKsVCUljuoYvs
         qC1GosucjE2I2wTbYoV6eqEtaSMD+mrpQb1dTmEyKCkq0RQNKhdV+syKL3GjCbFYGN90
         /ueg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eUnPUEw25xH84DOq6zJ0v6Aw5NodbUsM/I1jFeyU0KM=;
        b=MeE/8pzBjD2OAHGR1KVuE3PtXqfuXjF/zE41DKuh/jZxjqxs2deMJbqekwnozsqRm8
         JQ2EnL1IkbHdisQDUnXPgje4JIox/5Pr3p/m2Q9vYGrnHzX7Dc0TBJzluDuZN+rx6TJr
         3z3kfrJdNPRl75WIJS7z0Mm8ORtyfShGCRyyBF80EJ54hv48FjGTLXWgJyGjN354Qj3Q
         yFU7CL5P7huGZrk7t2e7+8JjUbZnE4MeXs8m8VgAqNwpgDkD4udqiU36TSlvo4N7W7gS
         5u0ZlUoJ7/Kerh/Y3cq4Y4p0kAsHpAg4ftHhWc1NLtn3quM0MtL0EugkHiKEb6eQ+L5f
         E/vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ZvNWnuQZ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor1656830lfj.46.2019.05.25.10.06.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 25 May 2019 10:06:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ZvNWnuQZ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eUnPUEw25xH84DOq6zJ0v6Aw5NodbUsM/I1jFeyU0KM=;
        b=ZvNWnuQZMG/SkUan4dFz03SkF+F6NtqRC/Cgx2fb5lXthFpCjyzEbczW/SDraYncIR
         zQgHz3FqW2dkuJzWrU9AHwiQ6MhmEIkM0Uwmoc25goSdoXSqyrERxHA6nnEdyvmvjOcJ
         rQ898QL/9J9sDjvhm9K66P/TQWm9eicsR7EOM=
X-Google-Smtp-Source: APXvYqzwuoTmK+684P5Y2ZLYHRyTWGyhsverUUcK6RFxGc/neN2UQUq+8G3LDMwE9SwLmKrLmLnUqg==
X-Received: by 2002:ac2:5626:: with SMTP id b6mr29024183lff.82.1558803962376;
        Sat, 25 May 2019 10:06:02 -0700 (PDT)
Received: from mail-lf1-f43.google.com (mail-lf1-f43.google.com. [209.85.167.43])
        by smtp.gmail.com with ESMTPSA id k3sm1179347ljj.73.2019.05.25.10.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 10:06:01 -0700 (PDT)
Received: by mail-lf1-f43.google.com with SMTP id c17so9294004lfi.2
        for <linux-mm@kvack.org>; Sat, 25 May 2019 10:06:01 -0700 (PDT)
X-Received: by 2002:ac2:59c9:: with SMTP id x9mr629669lfn.52.1558803961013;
 Sat, 25 May 2019 10:06:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190525133203.25853-1-hch@lst.de> <20190525133203.25853-5-hch@lst.de>
In-Reply-To: <20190525133203.25853-5-hch@lst.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 25 May 2019 10:05:45 -0700
X-Gmail-Original-Message-ID: <CAHk-=wg-KDU9Gp8NGTAffEO2Vh6F_xA4SE9=PCOMYamnEj0D4w@mail.gmail.com>
Message-ID: <CAHk-=wg-KDU9Gp8NGTAffEO2Vh6F_xA4SE9=PCOMYamnEj0D4w@mail.gmail.com>
Subject: Re: [PATCH 4/6] mm: add a gup_fixup_start_addr hook
To: Christoph Hellwig <hch@lst.de>, Khalid Aziz <khalid.aziz@oracle.com>
Cc: Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mips@vger.kernel.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ Adding Khalid, who added the sparc64 code ]

On Sat, May 25, 2019 at 6:32 AM Christoph Hellwig <hch@lst.de> wrote:
>
> This will allow sparc64 to override its ADI tags for
> get_user_pages and get_user_pages_fast.  I have no idea why this
> is not required for plain old get_user_pages, but it keeps the
> existing sparc64 behavior.

This is actually generic. ARM64 has tagged pointers too. Right now the
system call interfaces are all supposed to mask off the tags, but
there's been noise about having the kernel understand them.

That said:

> +#ifndef gup_fixup_start_addr
> +#define gup_fixup_start_addr(start)    (start)
> +#endif

I'd rather name this much more specifically (ie make it very much
about "clean up pointer tags") and I'm also not clear on why sparc64
actually wants this. I thought the sparc64 rules were the same as the
(current) arm64 rules: any addresses passed to the kernel have to be
the non-tagged ones.

As you say, nothing *else* in the kernel does that address cleanup,
why should get_user_pages_fast() do it?

David? Khalid? Why does sparc64 actually need this? It looks like the
generic get_user_pages() doesn't do it.

                Linus

