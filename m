Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 561B2C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:37:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C67A2742A
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:37:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C67A2742A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A8406B0269; Mon,  3 Jun 2019 13:37:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9310C6B0271; Mon,  3 Jun 2019 13:37:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F9F06B0273; Mon,  3 Jun 2019 13:37:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45BF66B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:37:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k15so27553362eda.6
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:37:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TIyZYmgplqqc5cxh9Px84y0P1YBJ2Y1NOZOA7imnXLg=;
        b=g4uAL+J+R7JIiO4C4mUTxFlw4WR0vWAzB4xMkE5JMGow/z9hfFpaHPu55sh31wxT/8
         DP/wFLoPjhEQH1QwGR/1RSDA32XgBlsbb00wMc7Q6gn+SjL9jBF9QzIHSopTwIu0Vp1i
         bEsYp3ATWXtdYzZ63z7cuzwf3GaVlzwh7esOABNGLeSH0XEVugvvG9Wu3l7aaQvPQHwF
         qMgR0jR/tGiT+JIZ14cXXAdpcA76dJRH7m7lOhqkCtX8ye/WKeOcJ9u0EFJ9njF5D9RF
         NXZMe73OsDOmyW+DLIMU0RjgVc0/HDDO6B7KGxD1m2rYrQPhs7kR2TkelckgAoOIunSV
         3vzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUyqmF4ZGjuQQb/zABcWYiJ/1gQsQbD9Qxv4+VanLy0M8NSukbH
	0eZenMw8NaElG8IwD7pUQcv4+9Ee73ffCZoJFdXaQgZYSM79BrtPWpg6p3RQ5uIVomLP96n5K4J
	mZSR4h79u6CPNJxYj5sTg3EAeIcogV3e79O8WA49Yn1X63KVD1tzzAsEPlkl0bBxuUA==
X-Received: by 2002:a17:906:491b:: with SMTP id b27mr25100477ejq.234.1559583439853;
        Mon, 03 Jun 2019 10:37:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/3akrZvSViOpRWTyHlnvGSGGIZFtQBb//wWJHgfPDmoxOCwIyd3cnFY8OzMwbjdAI/GYS
X-Received: by 2002:a17:906:491b:: with SMTP id b27mr25100418ejq.234.1559583439144;
        Mon, 03 Jun 2019 10:37:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559583439; cv=none;
        d=google.com; s=arc-20160816;
        b=YeEyR5XHVPj24a9fnUjYMqD00FbuRFPe/sw5SLjhfE4GKK/43JPTSGf19jQwDXJWIE
         oM8M63NGCQRdwrbkobzY3iT0+onSOSbqPNoZQYcuBvYa9xUzAbiPSAh34a+lVVuzU4cS
         5uyA3VW/VcCKCNQNFVmMOR86I/cre1T8aYqkTTDbpGY2NxmcbAyEmEjiRpPUmhPEu1bw
         jWJRxZzH6vIlTUO9goUzmABgNnNlPF/YwYfRLIgoxtpeAyJkDjhmuIsRqPuTFUE6WbHI
         jFO99eKJQhq8j0L2Rsjs8IRYS1Fxe+O2KNWuwG2b8q+j8YlPqmAAFb7GWQQGjJach/sM
         BXMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TIyZYmgplqqc5cxh9Px84y0P1YBJ2Y1NOZOA7imnXLg=;
        b=ENW7eP/bBK0pEoZYKBBdl7tmsKHMIqTnwKwIUnDKbEE2IKH6ByD4ygk5Ptz8dyx0r0
         b2jKOp2N+aDOIBaAt5JLSNsmjD2VtSEg9tmAn5seNg/kkLaiJr4dqLmhObeLz/z7shmG
         PTV46SQ30qOqGoykBJrGSWJ7gYwWALuTRXvQdovaJU+2fIF7T6Jm8LTQWCArlEsveAKR
         ETSJAFQPoUKpiE2Fvv6iHmjp2N0HQH44QRcoukKeI+dJu6fEYpdCwJy/gBlK0RcKu8Bt
         MAcz1mpN81XIezMwwplOacqG4i0KV91bSMx8aKlBM5T2Zw+sizGJC5n3imu6i16eHY0+
         TEvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f10si6412197edd.87.2019.06.03.10.37.18
        for <linux-mm@kvack.org>;
        Mon, 03 Jun 2019 10:37:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0F68280D;
	Mon,  3 Jun 2019 10:37:18 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EC8823F5AF;
	Mon,  3 Jun 2019 10:37:14 -0700 (PDT)
Date: Mon, 3 Jun 2019 18:37:12 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 03/14] arm64: Consider stack randomization for mmap
 base only when necessary
Message-ID: <20190603173712.GJ63283@arrakis.emea.arm.com>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-4-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-4-alex@ghiti.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:35AM -0400, Alexandre Ghiti wrote:
> Do not offset mmap base address because of stack randomization if
> current task does not want randomization.
> Note that x86 already implements this behaviour.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

