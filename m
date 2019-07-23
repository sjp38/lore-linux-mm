Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8A16C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:38:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB56D2238E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:38:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB56D2238E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 546C88E0003; Tue, 23 Jul 2019 02:38:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F68C8E0001; Tue, 23 Jul 2019 02:38:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BEBD8E0003; Tue, 23 Jul 2019 02:38:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1E2C8E0001
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:38:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so27618219edv.16
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:38:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=WrnsQ/F265rBRpQUbggUoo/EFISO7yBW733K1GfIbvw=;
        b=OLaaLEBY6Urs69/HlKXatV4s81+2ZTFAbs5ESOwGFhGaWQiAQYSUxmEgMM+1WOteGV
         I5rnGzJqeHwjIUDOC+P95lnukUXFAu054EpYHPwZ/ZF8+lQeglxPTL7yLKbalddUPsjy
         nFQltGlCi6GHPP/Dhkl7qjTlBfKZ3R7iyzoLfkr2/h3sQ7c+Sbhpo2YmulVqge5T+r9V
         UqurBFFa7lvs4PZOO1oYJZ394t6svSXmoo1kCqaL/T+v+vUHkWAZA5Ki+wNkeu8Eb4kN
         1EOUDTbNn+WKVKLAE4VdH0iMpQoOjViUrJvcNDVkE9Xob2EENBBLEj4xueJ8qgq/u+PA
         gKKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV9IwYMGUDdkOWovhtySd2m5fkAMvxHNBOqWSqr1zavRSZvvtcx
	NYOxOv85SWbVA81wlbA7XyCbR2AqvDDHgwBgsJIr/ml5dxh4+k4vzJxVwkNJ0jYWaRUtiEWzPto
	+STQslantAHw+UBZ3uhhI9jlsJPIQGFy7LTKvws77cJKaE5wDRR02y4gmalrUTMax5A==
X-Received: by 2002:a50:9947:: with SMTP id l7mr64959271edb.305.1563863935452;
        Mon, 22 Jul 2019 23:38:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLleEKysq2Ja2uuI6GsipWyRijYo1UNe2dajpMrmBIqq6tO5Q8ZjuU9f54IRAc0/7PfF14
X-Received: by 2002:a50:9947:: with SMTP id l7mr64959240edb.305.1563863934721;
        Mon, 22 Jul 2019 23:38:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563863934; cv=none;
        d=google.com; s=arc-20160816;
        b=iAUGE8pJF06alpkgtFgnSWjNLaku4yporlw1eGs+fDCSPqKlMsQXMAkujD4YRzXbNq
         Fyy6tBB0AcMAUz/oD6wAWYRGpt4HQ59pQ0/jqTv9LgL+AYeCgYUA30h4BwRVl6Vh3DYB
         bAZqzrgSa8vTl2CuIVmqAT4BJvnj+vK39+hVDEE5mSmlUGhjEpDN6IxTPQPwslkCjLUD
         b1fBTYoTRv3NAMmogqCPSJsZxMgcN7OQ7GGTucOmClEDv7/dyRb0DDY4FHPSX/rm7XHN
         qqtrdObbKohaEDfyqxviekUkDw3mMkPjo19QmYv5Zmu2QJMhuazIzeMHfyGPE3FDtNwP
         aIDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=WrnsQ/F265rBRpQUbggUoo/EFISO7yBW733K1GfIbvw=;
        b=jR/fQ58TYW6EVDN51wfzIoJLkkcy3/VGlLGWZMZ/0MvctD7U8I5PqKksHQXcwwGL1h
         4KeOZfOZAJwFfm9gYxibC7v7My3brx3vBPrSwLoje24Dq1AUrmaWc8DCabpnH1vD8bgv
         p9ZVb55abs/PEuC1RVLyX/caFVr+uDBWzam7y2WL0rQJp9O/vITGeNE+ul0h19VvlMY6
         mYOaogoS7gEKOrpFlYTDQQ6trCBDDQflj+3jTzwU39LmyL6ewh/rz4tnXoRSYOWIUwMB
         s4cE4qAFhQR6EC5oSEVvI/Jrp6RKuCa7qtSFGpRrUGx08yu4xLY2EMSlt+CEwGgJUnRh
         Xpqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e33si6994426eda.183.2019.07.22.23.38.54
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 23:38:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8CDAE344;
	Mon, 22 Jul 2019 23:38:53 -0700 (PDT)
Received: from [10.162.40.183] (p8cg001049571a15.blr.arm.com [10.162.40.183])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 502D83F71F;
	Mon, 22 Jul 2019 23:40:51 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan"
 <kan.liang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
Message-ID: <835a0f2e-328d-7f7f-e52a-b754137789f9@arm.com>
Date: Tue, 23 Jul 2019 12:09:25 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Steven,

On 07/22/2019 09:11 PM, Steven Price wrote:
> This is a slight reworking and extension of my previous patch set
> (Convert x86 & arm64 to use generic page walk), but I've continued the
> version numbering as most of the changes are the same. In particular
> this series ends with a generic PTDUMP implemention for arm64 and x86.
> 
> Many architectures current have a debugfs file for dumping the kernel
> page tables. Currently each architecture has to implement custom
> functions for this because the details of walking the page tables used
> by the kernel are different between architectures.
> 
> This series extends the capabilities of walk_page_range() so that it can
> deal with the page tables of the kernel (which have no VMAs and can
> contain larger huge pages than exist for user space). A generic PTDUMP
> implementation is the implemented making use of the new functionality of
> walk_page_range() and finally arm64 and x86 are switch to using it,
> removing the custom table walkers.

Could other architectures just enable this new generic PTDUMP feature if
required without much problem ?

> 
> To enable a generic page table walker to walk the unusual mappings of
> the kernel we need to implement a set of functions which let us know
> when the walker has reached the leaf entry. After a suggestion from Will
> Deacon I've chosen the name p?d_leaf() as this (hopefully) describes
> the purpose (and is a new name so has no historic baggage). Some
> architectures have p?d_large macros but this is easily confused with
> "large pages".

I have not been following the previous version of the series closely, hence
might be missing something here. But p?d_large() which identifies large
mappings on a given level can only signify a leaf entry. Large pages on the
table exist only as leaf entries. So what is the problem for it being used
directly instead. Is there any possibility in the kernel mapping when these
large pages are not leaf entries ?

> 
> Mostly this is a clean up and there should be very little functional
> change. The exceptions are:
> 
> * x86 PTDUMP debugfs output no longer display pages which aren't
>   present (patch 14).

Hmm, kernel mappings pages which are not present! which ones are those ?
Just curious.

> 
> * arm64 has the ability to efficiently process KASAN pages (which
>   previously only x86 implemented). This means that the combination of
>   KASAN and DEBUG_WX is now useable.
> 
> Also available as a git tree:
> git://linux-arm.org/linux-sp.git walk_page_range/v9
> 
> Changes since v8:
> https://lore.kernel.org/lkml/20190403141627.11664-1-steven.price@arm.com/
>  * Rename from p?d_large() to p?d_leaf()

As mentioned before wondering if this is actually required or it is even a
good idea to introduce something like this which expands page table helper
semantics scope further in generic MM.

>  * Dropped patches migrating arm64/x86 custom walkers to
>    walk_page_range() in favour of adding a generic PTDUMP implementation
>    and migrating arm64/x86 to that instead.
>  * Rebased to v5.3-rc1

Creating a generic PTDUMP implementation is definitely a better idea.

