Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B19EC468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:42:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C70C420820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:42:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C70C420820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A8846B0010; Mon, 10 Jun 2019 01:42:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 458C06B0266; Mon, 10 Jun 2019 01:42:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 348736B0269; Mon, 10 Jun 2019 01:42:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D39806B0010
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:42:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so6372950eds.14
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 22:42:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZOBypmaSxtxu59Q57CJlUJqWrjnUNAoS2J8fSgHZY80=;
        b=ogIiyUV0F7OXtp45Rlf5NNzcmyW022roPWaIrvlGZ8AopEovcZuaSoMK65aOk0+QvJ
         oYGFi5yuZ/Ml7ymxa5Adus2ReAsGWSQNiA2tpcgJT1tAY1Vuw/v4D+Y3l082uljSupwO
         pCbHZsTYHW9wuSKvAFNmcfeeeFDx1SUFfbv85XvRqgBTrKdC15kk+Nw4gPS1gPK4Bw/0
         EDCqLfEj7MO97/OCiE+V8GM+Tt7sb+oDa15nQE8MeLKrtCwhabzMOs6Rul5CuYs7ofKq
         KyoJ0/LWuKO7HGf5UEYifnpsavKgoBvfoWRbXLmXS9eQEnZcsoqpZ6uAMSSVsGaaD3iJ
         XeoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWOPs5HhL7GApcdhGP1I1BJ4vZ82NhY72E4uhpnDI5ZG/gP/94g
	ifQ/wdrnX1hiOIITaEs2fm8t1mGrob9er0tQfwOv7RLDvRZzJIaUznTXU3stBzcBX09LyaWj732
	sXB+VT2EOVvrWH1w+ZyxFupYzdr/4Enj3oIytjMvXgqw7O0EJmWgrElrtMWdLaxnmgg==
X-Received: by 2002:a17:906:f87:: with SMTP id q7mr34522713ejj.204.1560145322426;
        Sun, 09 Jun 2019 22:42:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXVPE++ZOxP+MSvq/Zq+/d1UjIqFQXJDQYofx8YS9ctfC8xOGPfyWkvQ7JOLrYEDsN+Bcm
X-Received: by 2002:a17:906:f87:: with SMTP id q7mr34522675ejj.204.1560145321729;
        Sun, 09 Jun 2019 22:42:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560145321; cv=none;
        d=google.com; s=arc-20160816;
        b=IIaHJBcwaqD2/HNT1H/HHZqCaFrsHTVr+olfNSfyOKdoQzt2BhVgbm0GgkGdmeYQRb
         X0FcZnWiJiVPa4VoE0q94IIlgTCV+o3rmMdDHzcArlNXNADUC/3sfgFgQNzF2LuVFnR0
         iTtmQ5aLtamI4Jw/lhuDzEqoOetPT2I+NZYlDdLBtP74Ro1fSzYIhhFsQ0oh/kjlRbzM
         9dC7Vd8ENchB2LYwL7l6BAQc26Pnup9c9DH+5Hmvrfk9GggmVcu10HKXD6aohH8gaAfl
         DoQfFIYpgrGhEUGqO+Rw5obaCLw1F7tvik+hBfthLexKiOCIRklPGxrUCHNISJSiAanX
         Xo9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ZOBypmaSxtxu59Q57CJlUJqWrjnUNAoS2J8fSgHZY80=;
        b=qYoRQYa///efRhvaaKk2cXeX7Omr1liG+K5vcYUSjJ1aKNzGtng0NuV+XnDXVG0/Lu
         LpBMJ+2xD4XGkIWR8mSBHGCcfS8rTsvrlZLmW3Ykt8e5Q8RsXYkwzZIEYbRJV71IKjXV
         +onp2rzv7z/ix7MYHLZsm2nBEq3SFiKpMknfhXPSTLj9M6NE9MlGSoG9hniFYruZFS6x
         KQgmy9WTZLenPSYwgwiL6dIu2CH5ov1rWuVBGha/P1Nf4tcO1+JqCK2hqEMZAH4DxCva
         1b+3wyo3E5KTmHpj8YcZ6QFdzqi2gyqim58CRa4rsc7G25sgjwWIHiYL+C5wVABQjAri
         VKfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b6si672057edi.407.2019.06.09.22.42.01
        for <linux-mm@kvack.org>;
        Sun, 09 Jun 2019 22:42:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B3F48344;
	Sun,  9 Jun 2019 22:42:00 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2D6913F557;
	Sun,  9 Jun 2019 22:41:58 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: Move ioremap page table mapping function to mm/
To: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
References: <20190610043838.27916-1-npiggin@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <03de53e9-f1f9-1632-567e-b88aabc56764@arm.com>
Date: Mon, 10 Jun 2019 11:12:16 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190610043838.27916-1-npiggin@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/10/2019 10:08 AM, Nicholas Piggin wrote:
> ioremap_page_range is a generic function to create a kernel virtual
> mapping, move it to mm/vmalloc.c and rename it vmap_range.

Absolutely. It belongs in mm/vmalloc.c as its a kernel virtual range.
But what is the rationale of changing the name to vmap_range ?
 
> 
> For clarity with this move, also:
> - Rename vunmap_page_range (vmap_range's inverse) to vunmap_range.

Will be inverse for both vmap_range() and vmap_page[s]_range() ?

> - Rename vmap_page_range (which takes a page array) to vmap_pages.

s/vmap_pages/vmap_pages_range instead here ................^^^^^^

This deviates from the subject of this patch that it is related to
ioremap only. I believe what this patch intends is to create

- vunmap_range() takes [VA range]

	This will be the common kernel virtual range tear down
	function for ranges created either with vmap_range() or
	vmap_pages_range(). Is that correct ?

- vmap_range() takes [VA range, PA range, prot]
- vmap_pages_range() takes [VA range, struct pages, prot] 

Can we re-order the arguments (pages <--> prot) for vmap_pages_range()
just to make it sync with vmap_range() ?

static int vmap_pages_range(unsigned long start, unsigned long end,
 			   pgprot_t prot, struct page **pages)

