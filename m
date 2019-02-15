Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 800B3C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:05:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 204B5218FF
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:05:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 204B5218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 655448E0002; Fri, 15 Feb 2019 09:05:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62C138E0001; Fri, 15 Feb 2019 09:05:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 541C38E0002; Fri, 15 Feb 2019 09:05:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 150BE8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:05:48 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u19so3928730eds.12
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:05:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hEx274L9lmJ95s0ZI5HNDjvigXT2uyoUzRh3+DUA0yM=;
        b=lV9E6PA9Q4Z2T6kddR6PwNeXrGpNvqpHj5DgPythPkaYBatEc+2R6891hBWj3ZKPKE
         iSda39TBL26/nDTg2X3I6VMXmkBg386pCeu1waIqyZy+4RPAOaUgxHLyEbdWaa86Lp0F
         lkFg04tcovK5g+0oSTBedRn5OkiN/1hhUPU/D7KompF73F4mcRZpP8yay98934eCp+yA
         5wxDdxdvhzcCaDT52nNq9Ynqp08qf5asmxZUdvEWcocyniOjN7dPaAQEBE8z+yBZH84j
         Ne5FLxdzHP7andD0e93U34sni2D+hBQ9lBelf0Rsx1/QjYCLJLI5uYgtx5Yci0kbbekJ
         RZxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuY9nMOe7hddw2Fb/4r6LSvF3jJkXO0vq3cqqfeKQsmmJtVmsjrQ
	aQsYwsrrdQLqM2NsKSar0W2TKu9OOlBYmbQ2WQ7hjdZk+gwqy7XF6+o95s+F3N9wL7UTatJDmJH
	RGyFoSchz8AzvM20a6IgdSt6SsCzZfVilATQyFp+zXkZpdsxRg2gu2bTqS0EyQ+7wnw==
X-Received: by 2002:a50:af63:: with SMTP id g90mr7860777edd.21.1550239547483;
        Fri, 15 Feb 2019 06:05:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZZrJV80hIhU8sWBP/Yan1cFzF7ea2ZuNMaRv1rjSAo+k1Ic4ECFj8OkQ8kmmw7+veNKriU
X-Received: by 2002:a50:af63:: with SMTP id g90mr7860728edd.21.1550239546634;
        Fri, 15 Feb 2019 06:05:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550239546; cv=none;
        d=google.com; s=arc-20160816;
        b=Eog2M1S5UOJ+nBAjIoCwN49P3z8CkYAdEKJcczwGl1LJC0tY5c+bcXmYlr1I7vDULg
         N9tmBZAFhGp6nYQX2pFbLj9e91RqWIrlVC+JyihssJGARmzeogYhhF1Jjzl0Ih6VGU4+
         XBlXORnKXHQCcHX55633WMn6XV0WLffk8M+Yt+12Oz6cwfTX6qjxpQKazB6rqxNirFWP
         V/AUT3o66drj8zQGdYmrImVMWTHCRSmAVUakjDZK2hjOe1/8YPCQ8HxDNP4Kylnub5KZ
         WaP1UIXjSRIBZz3Is2UX35iaDWZ4xjwMJXF/9LWihN1PY/Imqwzp7fyfDGMTwlWjgCBq
         r5bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hEx274L9lmJ95s0ZI5HNDjvigXT2uyoUzRh3+DUA0yM=;
        b=bIX5oBx+VU1KvUo8WCv5Ok9vUKYEA1Bc57AOV8i5WCLAiLlosdF+HZmE8IxXkrVCl+
         Fb9mMdfFBRGBuELHOyEVUP+AnRwfIrKCNAY9qZeE4VdVh25evpA4i15JD5ki5kux5ljW
         69N9aEt+GVSBP95yh5wQ+B5JWwViUKNOGRi5BhZwo+j7dF0D/CET84oChLwS+AbM3N7A
         kSF6jtgXykFbD98Ta3t2py0csj3MQrmyPjSmV1PD/hPAT2NO+AO6ktXmkBn1I6lkIBUB
         gULGEjxt1Jx4Zl6TT96us7e5iIdmuJ463FhaihiIYWdP6YhpCuv0qZN7DXcyMW+3nxna
         JGdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q10si88442edd.257.2019.02.15.06.05.46
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 06:05:46 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8AAA1A78;
	Fri, 15 Feb 2019 06:05:45 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DC6EC3F575;
	Fri, 15 Feb 2019 06:05:42 -0800 (PST)
Date: Fri, 15 Feb 2019 14:05:40 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>
Subject: Re: [PATCH 3/5] kmemleak: account for tagged pointers when
 calculating pointer range
Message-ID: <20190215140539.GD100037@arrakis.emea.arm.com>
References: <cover.1549921721.git.andreyknvl@google.com>
 <df99854703d906040a7a898ac892167e3ffe90d9.1549921721.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df99854703d906040a7a898ac892167e3ffe90d9.1549921721.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:59:52PM +0100, Andrey Konovalov wrote:
> kmemleak keeps two global variables, min_addr and max_addr, which store
> the range of valid (encountered by kmemleak) pointer values, which it
> later uses to speed up pointer lookup when scanning blocks.
> 
> With tagged pointers this range will get bigger than it needs to be.
> This patch makes kmemleak untag pointers before saving them to min_addr
> and max_addr and when performing a lookup.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

