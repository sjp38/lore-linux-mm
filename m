Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93303C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56D8920857
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:46:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56D8920857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAFB28E0002; Wed, 30 Jan 2019 05:46:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5F088E0001; Wed, 30 Jan 2019 05:46:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4F388E0002; Wed, 30 Jan 2019 05:46:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1D28E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:46:44 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a9so16612293pla.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:46:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=NGpn5fpCfKPsOmiNYNdOy2tbGYsSKVIaC7+Y0mQ+KnU=;
        b=AAf198ChkaFxXSyR8ZCIRzUIvlTEpoU4bk+Qt707PTm4GlGwPRbdFJzQIdH13ULIL8
         ssYSJyiO7MYunpsB07knL1JALq3TNi5FrLy69gMueGC2nedjveChtbXilg7iwGpcT+P7
         l3WMRWguYYvabF79+CUf/fhEOfgX4/JUAWWr5kZQcYR4tR0IbWxd8OI4D5j78a0tBRKA
         rUihicvXb1DCkMGXlrelyJr9ZgARA5XmZgUwudKGAyf33g8Om6ON40newOYtk0C4uYdT
         dzCdTZkd2MF6S6VlvzLuHIeROUQL6hptURK8kLwlC9oNqFcLHjcf8qFpNUWum3UyPikM
         malQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukdEDPWmQemaw4JBh7q/fvn08J8KD4dqjHt6dGjVzi3YYDAndY7s
	EfAYS6QUXx8WIhiXOiLz+1T38V3V10zt3SfIxgSf9W7tfHAI/5EIMXE/PZsvVzEoUIabT8ztIwj
	XHGfjoPRAssR1f6Uk6fY3N12Xp3Sk65IsZXjfiHQWWeinrp6rTULzOV87Z+13hMc=
X-Received: by 2002:a17:902:6502:: with SMTP id b2mr29416435plk.44.1548845204196;
        Wed, 30 Jan 2019 02:46:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6nkr3FZ/RwxdOUD1punGkcJsSA67F8ztca3y6P5MyTMTgod1I9L8V5GY6LYpxeuZ8lDpHq
X-Received: by 2002:a17:902:6502:: with SMTP id b2mr29416397plk.44.1548845203601;
        Wed, 30 Jan 2019 02:46:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548845203; cv=none;
        d=google.com; s=arc-20160816;
        b=cWB+Tvc7iGcWHQvLYQ/vaGvqRh9QZ4dOtq0e6J+YP+9kCvDKI9VhqoC60JADYWVco1
         ivSL3ejjfjMtKEZU74Cm5f41OwuzlKhBknKEV9tetBDdKlh5JyqFF/OoPDYxqqRsgOrO
         xApnwY2ejxW70oczY7cQ9VxXpkNpd6tiRFkpl1VgaQ0gl6XDbpU54XfCBz7McO7T6gWQ
         6wyADbO7fJzx0HcAzfMhVZn8XT8G0ALzohNigM2ACOLLFh1u/DvB3zlDaIzKJLXrKuuu
         E7zRj9Bar2g51TlW9ib0QT+c8Pmi93GfUJ0PLZQM8zWD97LlG/sgFvb4TYpffYDZ8NeV
         P7aA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=NGpn5fpCfKPsOmiNYNdOy2tbGYsSKVIaC7+Y0mQ+KnU=;
        b=afmrx8ICqUiKHk6nV8C4cpSciOE/XkhBDP4xxm1nrPO5pCF+LAMZNrrqVMx97qZuvz
         v3jHre6dthMeN14dgc6yRYOQXEOOHQMMHqzV+iBeW7bpc12wuMpfhOYNlqCu+wdufx9+
         3+zaT2uxaLaeyBDpF7uORCwLN3cMqorAIu4o22XdVcTaZeQrhmjG15Pt78dwYfUS6XMc
         nElQUY0HYYfGzAggcnEDcdUd/zykOJPsrhvDaNbj5TYSTD4MZigss9gjvMXH7kLQSUMW
         H36KSmnJc4zjsqTK51tFO1E/VoSMajTq4cBGS7V1ovfrO8SQYS3kuhEIfiOwxeR9Nhgj
         Xexg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id y40si1229710pla.251.2019.01.30.02.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 02:46:43 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qKmc3XpFz9s3q;
	Wed, 30 Jan 2019 21:46:40 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V5 2/5] mm: update ptep_modify_prot_commit to take old pte value as arg
In-Reply-To: <20190116085035.29729-3-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190116085035.29729-3-aneesh.kumar@linux.ibm.com>
Date: Wed, 30 Jan 2019 21:46:39 +1100
Message-ID: <87imy6qv74.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> Architectures like ppc64 require to do a conditional tlb flush based on the old
> and new value of pte. Enable that by passing old pte value as the arg.

It's not actually the architecture, it's to work around a specific bug
on Power9.

> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index c89ce07923c8..028c724dcb1a 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -110,8 +110,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  					continue;
>  			}
>  
> -			ptent = ptep_modify_prot_start(vma, addr, pte);
> -			ptent = pte_modify(ptent, newprot);
> +			oldpte = ptep_modify_prot_start(vma, addr, pte);
> +			ptent = pte_modify(oldpte, newprot);
>  			if (preserve_write)
>  				ptent = pte_mk_savedwrite(ptent);

Is it OK to reuse oldpte here?

It was set at the top of the loop with:

		oldpte = *pte;

Is it guaranteed that ptep_modify_prot_start() returns the old value
unmodified, or could an implementation conceivably filter some bits out?

If so then it could be confusing for oldpte to have its value change
half way through the loop.


cheers

