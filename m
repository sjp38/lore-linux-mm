Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68863C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:16:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DC8524137
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:16:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bwKrSUcA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DC8524137
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF8AA6B026A; Wed, 29 May 2019 16:16:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B815C6B026D; Wed, 29 May 2019 16:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FAFB6B026E; Wed, 29 May 2019 16:16:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67D3E6B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 16:16:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u7so2712848pfh.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 13:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=byH71jcEnWiZocWjFrPDlTMOE7pd8EPRHoYGyukaY04=;
        b=rQUmzbaw+NrRH/TXRkI99jsTUTdBWJcCBvosXM9NaifzqMjXbiRuzIGsZpu+XduECu
         l/4njZupPrhEkwUamx4IJKsLQkMdisELll8oPwB2Cik88oqtJN+xvNiPqOnoI8Bqv3ne
         OxS+1LJjAgE6AVTBgrRVZd9XWIm/0//Rryf7AlfVwyRq/n5pAjQWo/KLLQHOj0PD/Bsg
         UiVFyD/tG5QgBRDGNDHJf4N1nuHPy+7CXoTkN1poVLP8PPDJ0jJFe9fZPYtSaLkDDbyt
         LsHqRa6VsZJMLDFFJtXeBuG2S/PxiooMtEjnWIyUtvsxMKKy4WqdqJoHNmwUztJHPGzy
         GFHg==
X-Gm-Message-State: APjAAAUKk97VS49tyXHFqGGkXTGAKSzcFUz7+WbkXTWqd297nYU9ClfV
	7QjyXS5huQr8knVS/KnkdqV4767OmpyWI7tI7mZiJpIluw9aIij3GM2+CuBbB+++D7YIey9g3ik
	20z5OuGdS7l/xjgGuVBEl5UBlsrprgJTIRKYcNZsE8CFZV+vO4x1Oi6jeF90HVGcxUQ==
X-Received: by 2002:a65:6559:: with SMTP id a25mr39994244pgw.33.1559160978083;
        Wed, 29 May 2019 13:16:18 -0700 (PDT)
X-Received: by 2002:a65:6559:: with SMTP id a25mr39994217pgw.33.1559160977467;
        Wed, 29 May 2019 13:16:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559160977; cv=none;
        d=google.com; s=arc-20160816;
        b=vPYC7D4QkF1gVWo0KCFA5NVcHZYyt2x2wxYm/HwLBmcBEDj8rUePRDfdcQvZ8S/dfJ
         DyWIqIQTrAv2a7mi6DLlCJCUIqhjK9MbAaj2lMSC93SUHFKJAaIpBmFgGOaBoQAkMJ6s
         lbSaqdAIXA3iw2WQkSl4iDB/zQ0x2xXCh4b19uQL9Ms4lIuBV7EGBjUWZ+x/TY/KNDde
         g3gGEAhHeMcrQ4HnVkX5FRgR/eAR6ccBndAc2cu5El0AZpo9nUQELV0t0blLWtjAwHei
         h5ivcCIz/08nGgepktCDlBCs209VWyu6pBoM45Qe4CDNdhzjCfzwE8k+R4vNNAqadSOU
         zJrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=byH71jcEnWiZocWjFrPDlTMOE7pd8EPRHoYGyukaY04=;
        b=JX++H9w+OBNA+D1HgI0n6eWiOi4QQI608SXJniGBKaSgcKimzTvQavTlmWpxdEiGn1
         ZAOz/QpeSCAGqb0Q8j6DUtZT2P7Slk/rKSmZRUE3kOLgye4TDr667rQh2pghQV56sOmw
         LqMFibNzPC9wdzIuaSrBoEurf27Wucvbs/6sw2jZb9F9rBvYxcJuqfvp41qv6uUzHF+A
         Dv2b1tM/ZjU6DmdQ+SHlBzU8ZT6ry2Xx151d0Wiw8+KItYcMfJFofdR0ivM56xjTnAQ6
         WFqfQ9MOBok6AMJ93FZW3Iska0+wWthOwKXn4qlLzENQrcmZp+4gN21ngx6e1RugBVmQ
         bT0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bwKrSUcA;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor789639pfn.7.2019.05.29.13.16.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 13:16:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bwKrSUcA;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=byH71jcEnWiZocWjFrPDlTMOE7pd8EPRHoYGyukaY04=;
        b=bwKrSUcAFY5li8JHROxevBRkVdZvfftmbN2jvX4D8l/n4Q/b0ePv+zprqpG2KluSLn
         rSYJBFUhtygfnfgM4xMNPYR/Vp/NGpVKFovwEIHmtk8emThGP6iRNZH+rg7exn2dW3QV
         qTeu7YoFimL+W4CSITeRLNxas0G8YpYTWwbHw=
X-Google-Smtp-Source: APXvYqwOtLbXvQF12v2iQzcTzlTPHXYwr/VbPiH/+9zX0lzSfnaAmA5ZoEnSGfNESsFHQ7AnnjhQoA==
X-Received: by 2002:a63:f44b:: with SMTP id p11mr139393871pgk.225.1559160971649;
        Wed, 29 May 2019 13:16:11 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id u6sm227693pgm.22.2019.05.29.13.16.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 13:16:10 -0700 (PDT)
Date: Wed, 29 May 2019 13:16:09 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 00/14] Provide generic top-down mmap layout functions
Message-ID: <201905291313.1E6BD2DFB@keescook>
References: <20190526134746.9315-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:32AM -0400, Alexandre Ghiti wrote:
> This series introduces generic functions to make top-down mmap layout
> easily accessible to architectures, in particular riscv which was
> the initial goal of this series.
> The generic implementation was taken from arm64 and used successively
> by arm, mips and finally riscv.

As I've mentioned before, I think this is really great. Making this
common has long been on my TODO list. Thank you for the work! (I've sent
separate review emails for individual patches where my ack wasn't
already present...)

>   - There is no common API to determine if a process is 32b, so I came up with
>     !IS_ENABLED(CONFIG_64BIT) || is_compat_task() in [PATCH v4 12/14].

Do we need a common helper for this idiom? (Note that I don't think it's
worth blocking the series for this.)

-Kees

-- 
Kees Cook

