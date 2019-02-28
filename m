Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D380C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:04:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 349782084D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:04:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 349782084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD0BE8E0003; Thu, 28 Feb 2019 07:04:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7EE88E0001; Thu, 28 Feb 2019 07:04:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A47FD8E0003; Thu, 28 Feb 2019 07:04:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6F78E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:04:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u12so8445221edo.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:04:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=h5GH7Vl9yaJj/czE7BPBMi+uiO5bJ5BjuoyhFZ7G1TU=;
        b=CKjbGNgvUsru9s2G7Rqnl8b3Ri0PTXn4b8dC3G8FP4id/OiP2TO4EKuAYmNboMig90
         Mw63rjr//8PQom8KGl9R8lgL1uscfknOlr7zqCiDnJ9Bixe+aKOqYSbXFjw976WZng5d
         Ja1mROZoH5Ww+PzuvFjTAyOJYfJgRzzNcNOjYAC6ZHUqWAienvcAtY1snu033Qo9ydUQ
         NSCZQWwd8uq93R7iJyPGVTedyKBhYryqdXJbHrdL/ngmpoZu//8Wpsed/WDUEbweuHH2
         wXU3ndB2fWyhOW3zZPwWJUMzEVwFlihLNLo4mooikv31zu02eOyXg2Jq/8Ci7wZP5Nl7
         iEgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuazCwTvXOKm4NTadKf/kQYUn+FFPIUvmk/S6xotdr3Ac5q2wKtd
	p4fwhiScATb9EIHuXvjQsOZxVAhKgzI3+6kN5eJw7aj8npb4kpyQR9yaAJGIGvfANet8EC4gSHi
	cdgnP+Pgf7vIgaBBDCFDB8d6yBzKId9LL8Rr3IZCZqmM6K25thGQZ8/MV/azOxHN7wA==
X-Received: by 2002:a17:906:e56:: with SMTP id q22mr5208870eji.132.1551355455862;
        Thu, 28 Feb 2019 04:04:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia05iIJ8ANmmCyKhGwr542nk4lAeO8GwHu/TqpePwvRCqa0i+2ZMO5/73LGAfhfAu2tQg+d
X-Received: by 2002:a17:906:e56:: with SMTP id q22mr5208817eji.132.1551355454771;
        Thu, 28 Feb 2019 04:04:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551355454; cv=none;
        d=google.com; s=arc-20160816;
        b=ZITIWt6UjAuz8LA8RnKoTxuRgCesS3NZkyTFlNv8Y3mV7xvZmm3dEqfSNWN5FJndLO
         nFca3s6nSVaLduK3rSZy4YEGxSGew7KLvZ/P8OVhReQxUhNlt9x5vuQ1GQZNZRMSbV/e
         ZhQbMgFkYi72A2PjYC5wPmrFw/FhdFMSMz0p9SNqvtPcFHBjGZBcS8k/5+SdksBkkxZv
         BZ50AuTs9/53E2beOYzcYahfnncOl+D7eWm7+PkKlOQRm42I2bYc53sQETsi5tHdOIbF
         iqN/xYirBBQridO6dznNGVs+e60jBKBdscCseYhOYLTt8X0ZQB/dMIBSrO3HAAuO/qZ+
         LGwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=h5GH7Vl9yaJj/czE7BPBMi+uiO5bJ5BjuoyhFZ7G1TU=;
        b=j6kEJ8jMcJhmBLvbqECBNBhE8W5vOEFZguLQOxUvEwuaGXibMA7uJgjyBUOOzjCQwQ
         lLykXTZhDI09OAxDhRh23EBv1sCN4vL9ICa4ZMUG4/t43gAd1o58YKsakeNYKt803Qol
         Y0mL9uX3F18viKB9drxJvfXrtToPRc9Sht7DcBBvm4BwR1F9h5qyKGsFsR+aZwWt+750
         mU6caMDUYc6jua0pRLpr5R251TvJDhe9KyV5XPJb5729R6OBB0h1Tv8EKo8YcMqKY1Zh
         9LezDtqpLca4uzqQbmGJYRLuF+9oSmiH0Nt8n/hLby50CuHC92iWhtXIO/qP2l06coO1
         FJ1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e2si2943210ejr.125.2019.02.28.04.04.14
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 04:04:14 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 394E180D;
	Thu, 28 Feb 2019 04:04:13 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C7A4E3F738;
	Thu, 28 Feb 2019 04:04:09 -0800 (PST)
Subject: Re: [PATCH v3 09/34] m68k: mm: Add p?d_large() definitions
To: Geert Uytterhoeven <geert@linux-m68k.org>,
 Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
 the arch/x86 maintainers <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>, James Morse <james.morse@arm.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 linux-m68k <linux-m68k@lists.linux-m68k.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 "Liang, Kan" <kan.liang@linux.intel.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-10-steven.price@arm.com>
 <CAMuHMdXCjuurBiFzQBeLPUFu=mmSowvb=37XyWmF_=xVhkQm4g@mail.gmail.com>
 <20190228113653.GB3766@rapoport-lnx>
 <CAMuHMdU5gn6ftAHNwHNPDoUy_JvcZLcXbkk1hvUmYxtfJRfTTQ@mail.gmail.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <a17f5ad7-9fba-9d51-4d6e-7a9effe81e4e@arm.com>
Date: Thu, 28 Feb 2019 12:04:08 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CAMuHMdU5gn6ftAHNwHNPDoUy_JvcZLcXbkk1hvUmYxtfJRfTTQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/02/2019 11:53, Geert Uytterhoeven wrote:
> Hi Mike,
> 
> On Thu, Feb 28, 2019 at 12:37 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>> On Wed, Feb 27, 2019 at 08:27:40PM +0100, Geert Uytterhoeven wrote:
>>> On Wed, Feb 27, 2019 at 6:07 PM Steven Price <steven.price@arm.com> wrote:
>>>> walk_page_range() is going to be allowed to walk page tables other than
>>>> those of user space. For this it needs to know when it has reached a
>>>> 'leaf' entry in the page tables. This information is provided by the
>>>> p?d_large() functions/macros.
>>>>
>>>> For m68k, we don't support large pages, so add stubs returning 0
>>>>
>>>> CC: Geert Uytterhoeven <geert@linux-m68k.org>
>>>> CC: linux-m68k@lists.linux-m68k.org
>>>> Signed-off-by: Steven Price <steven.price@arm.com>
>>>
>>> Thanks for your patch!
>>>
>>>>  arch/m68k/include/asm/mcf_pgtable.h      | 2 ++
>>>>  arch/m68k/include/asm/motorola_pgtable.h | 2 ++
>>>>  arch/m68k/include/asm/pgtable_no.h       | 1 +
>>>>  arch/m68k/include/asm/sun3_pgtable.h     | 2 ++
>>>>  4 files changed, 7 insertions(+)
>>>
>>> If the definitions are the same, why not add them to
>>> arch/m68k/include/asm/pgtable.h instead?

I don't really understand the structure of m68k, so I just followed the
existing layout (arch/m68k/include/asm/pgtable.h is basically empty). I
believe the following patch would be functionally equivalent.

----8<----
diff --git a/arch/m68k/include/asm/pgtable.h
b/arch/m68k/include/asm/pgtable.h
index ad15d655a9bf..6f6d463e69c1 100644
--- a/arch/m68k/include/asm/pgtable.h
+++ b/arch/m68k/include/asm/pgtable.h
@@ -3,4 +3,9 @@
 #include <asm/pgtable_no.h>
 #else
 #include <asm/pgtable_mm.h>
+
+#define pmd_large(pmd)		(0)
+
 #endif
+
+#define pgd_large(pgd)		(0)
----8<----

Let me know if you'd prefer that

>> Maybe I'm missing something, but why the stubs have to be defined in
>> arch/*/include/asm/pgtable.h rather than in include/asm-generic/pgtable.h?
> 
> That would even make more sense, given most architectures don't
> support huge pages.

Where the architecture has folded a level stubs are provided by the
asm-generic layer, see this later patch:

https://lore.kernel.org/lkml/20190227170608.27963-25-steven.price@arm.com/

However just because an architecture port doesn't (currently) support
huge pages doesn't mean that the architecture itself can't have large[1]
mappings at higher levels of the page table. For instance an
architecture might use large pages for the linear map but not support
huge page mappings for user space.

My previous posting of this series attempted to define generic versions
of p?d_large(), but it was pointed out to me that this was fragile and
having a way of knowing whether the page table was a 'leaf' is actually
useful, so I've attempted to implement for all architectures. See the
discussion here:
https://lore.kernel.org/lkml/20190221113502.54153-1-steven.price@arm.com/T/#mf0bd0155f185a19681b48a288be212ed1596e85d

Steve

[1] Note I've tried to use the term "large page" where I mean that page
table walk terminates early, and "huge page" for the Linux concept of
combining a large area of memory to reduce TLB pressure. Some
architectures have ways of mapping a large block in the TLB without
reducing the number of levels in the table walk - for example contiguous
hint bits in the page table entries.

