Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4F45C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F5A020643
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:24:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F5A020643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E7046B0007; Tue, 16 Apr 2019 09:24:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38E9E6B0008; Tue, 16 Apr 2019 09:24:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27D306B000A; Tue, 16 Apr 2019 09:24:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7A0C6B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:24:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w27so10944442edb.13
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:24:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=80rje/NZ1BL2NflItziK2YbKGFo9TmtHaUG8P9vySsw=;
        b=eXewebvsZA4vGimbHLURNJtqiva4+ofuRr++P+sPyKF8kieodrhnwsa6Im27ejqDHT
         8lolDvheX8Sdx4S05ZXlqfK9DF2IZbXg6pl47gz46yvsCBRm9SfAm4+W6x2lSXjd8b3L
         otaxguugOQiFrKmzatz5BXvOOUvjjSaTF1gHvSUKMJIVPoX1vhimOUPfGANzoREEAk31
         pQ3TcDEF3t9Sfwv8NEVum2cL4gHFL1AvWACBp47zMjF5CkU64Z2KIhk3tRffxEj8Hu/S
         r2LQjdlA8uXtLYRIUJdpDWuDpmI6jIqJqavCS62mX2Wd6GKnAPv9vgOtta1zL5Z61fFT
         aH9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUnHnRy5380zcUrOtYvIxaltlXyT2ayYw54wHSMDSZltkCJuGoL
	PZLv5jxC30fa+gqbwYDybssjyxkkOaWyu6wwq1ng13s+fmyk78CjE8uO/kOFHvzCBjsn8+FWVnH
	Vq21o6OdbEis8Ril8HBtQ6vu3ko1SHhMm3RgugGZ3Ck0FwWhJR61HG6h2QiHnHUqo4Q==
X-Received: by 2002:a17:906:a841:: with SMTP id dx1mr41697927ejb.99.1555421048437;
        Tue, 16 Apr 2019 06:24:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDiyODonb3xFOry90XM/2ZHhQ6xk2Bwi5hOHzmwEKypWFbo9gaYr5IZoJYwfdCsp3jZ5p2
X-Received: by 2002:a17:906:a841:: with SMTP id dx1mr41697897ejb.99.1555421047667;
        Tue, 16 Apr 2019 06:24:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555421047; cv=none;
        d=google.com; s=arc-20160816;
        b=dQrq8rLtUqDFV4EP9sKoXWbBMb7c4/SqpaputFXD0tg/N7qVcNjjjTEYy1lEsZ/K62
         TTcmHdTwZc7wKDjmyFJyu+9Sg/yEphSiYex1Lxv31rPadNTYYxFrhYgtT1Yg0CwGSGFV
         bX+E9XvRPb13NO3KWoO1cVeX7MtRmfGU7O7JYLwhGpn7qrFhFcUQO+cO26VpV8NWbxwH
         pnoNTUeAp6gCKf/ezW48Y723ecgn3gIVHPCGK1UtG6gb5NDzDXA1XBt7jbGtQ31dZoSu
         7KZDIDvaUUGmEENf8vz1Q9MM6mUijlXHi4oI9VAJFSI8UJ4jUJ29et5hWioPXL74tb56
         dK9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=80rje/NZ1BL2NflItziK2YbKGFo9TmtHaUG8P9vySsw=;
        b=NvzZVku9U91+hPQF3hDMFQOOlO4cuhlmoQbV4d1AFecfEDHOh98MsgNcn8AHmPIizk
         /J6y2xc9Yv1XcO9ZAuKC+0zXUQyN+RNRvdSdeL0xroYABeyJXmmbxleM1c03fqnFXFYb
         eCVj9f1wLYBN6X7LCGUpLO7VTpXkkqGCWRCWmhAT+MSMndb/7CSy8Q6tTch8wcjTZLya
         5gVHabBUTFv3NoucF7BEvbXhZvrQ+okuARtbbxf82iPC9w9JzKUkZEtKnjYbnV/YZXwZ
         tzrGlT8xu2xCtroRef/dgIcpLiVscFD5MIeHlzTchl6wVfpMhWtEOl4bpwE5i3gE1gGp
         rgJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y60si917228eda.23.2019.04.16.06.24.07
        for <linux-mm@kvack.org>;
        Tue, 16 Apr 2019 06:24:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A555015A2;
	Tue, 16 Apr 2019 06:24:06 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7271D3F557;
	Tue, 16 Apr 2019 06:24:05 -0700 (PDT)
Date: Tue, 16 Apr 2019 14:24:02 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vincent Whitchurch <vincent.whitchurch@axis.com>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] kmemleak: fix unused-function warning
Message-ID: <20190416132402.GE28994@arrakis.emea.arm.com>
References: <20190416123148.3502045-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416123148.3502045-1-arnd@arndb.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 02:31:24PM +0200, Arnd Bergmann wrote:
> The only references outside of the #ifdef have been removed,
> so now we get a warning in non-SMP configurations:
> 
> mm/kmemleak.c:1404:13: error: unused function 'scan_large_block' [-Werror,-Wunused-function]
> 
> Add a new #ifdef around it.
> 
> Fixes: 298a32b13208 ("kmemleak: powerpc: skip scanning holes in the .bss section")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

