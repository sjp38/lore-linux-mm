Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93800C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EF2321A4A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:13:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="lqK7soM8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EF2321A4A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE3B26B0008; Mon,  9 Sep 2019 11:13:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E93F86B000D; Mon,  9 Sep 2019 11:13:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5B2E6B000E; Mon,  9 Sep 2019 11:13:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0107.hostedemail.com [216.40.44.107])
	by kanga.kvack.org (Postfix) with ESMTP id B2AF96B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:13:49 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 162E8A2BF
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:13:49 +0000 (UTC)
X-FDA: 75915726978.26.rings52_41c15ecd9330
X-HE-Tag: rings52_41c15ecd9330
X-Filterd-Recvd-Size: 8090
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:13:48 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id u6so13296826edq.6
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 08:13:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ptGQKrJwsC6QNZJxPTcIFHrTBzodlhROW8EV9Cr6mks=;
        b=lqK7soM8Ql8EG2Ftn3h3hR+olO0M3L5hi5yR7FV9iLEmOGD4dckGUM3j+cW0/Dime1
         tcaru2ydfakL0qOGX9NW71rS5xXhlEsWXHR5tZTvN8nAdg3jRR7H91vVYT27iUT4zLQL
         /8sd6tx6RSZch+NQKzd2gDDMnTl6lfsTiDI17WOQGfxtCfWUReS2eIOCKDQqmHkeOOb6
         CQ29hW9JyqW2659VgWaWS03hTBmcSoCzS6kj58DkCjvhtjcgvBnAojuQ6LW0JN5ngCCR
         oxmuahVreVZAzOjjnErCDvkrgGlDpVGWckjhAKTQyS0XAzH5VKEiZW6qr15a3nTgG9T0
         I28w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=ptGQKrJwsC6QNZJxPTcIFHrTBzodlhROW8EV9Cr6mks=;
        b=gL/7cOVWvLX9SmrWvoKTj3tO9811F0ZRRMZke7T887thb9KR6BlEEU+Fk3kBcbkwxU
         jbDsyb0IkzOUF3B2Olk6EkIL3f5nt0iE9DbH8WeuVBjnSP33WLaWr8545Ve5LhWUo5tU
         BWL4pg6XEMV+08G4eVTIjb1UWhZE3Up+WDVCxMJkINUe2dTvfvjyySNfxI4mYdh0/9jN
         RAC3SRdDDkjvc4nHLPRT9u4G3e4WFHZxDUvFkWW4ElgUxcKRcBCU2O7U+XZjpr1+FUOw
         D1VkBQENbAlXaepiLWLyKmOEPYuKiLKwc+zTgXNl+j4GJTfhOutck7uwCXs/CGJCwl9h
         FiaQ==
X-Gm-Message-State: APjAAAUS/KFrEVz+btqqIbrP6nzjvplosc2Murt4nVO/IHZNttBM7FwC
	JsvyHm/m31Cv8SZVbqK5BeVD3A==
X-Google-Smtp-Source: APXvYqwJokBcl6isKFmA//BZZyEEgwoj2uNW2kTs0Tg/Y35qXurjsqN7Jks2aTze1VFcwFZl9Fv8+Q==
X-Received: by 2002:a17:906:c304:: with SMTP id s4mr20002026ejz.71.1568042026870;
        Mon, 09 Sep 2019 08:13:46 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id bf19sm3010529edb.23.2019.09.09.08.13.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 08:13:46 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id CD9501003B5; Mon,  9 Sep 2019 18:13:44 +0300 (+03)
Date: Mon, 9 Sep 2019 18:13:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <broonie@kernel.org>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Matthew Wilcox <willy@infradead.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vineet Gupta <vgupta@synopsys.com>, James Hogan <jhogan@kernel.org>,
	Paul Burton <paul.burton@mips.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/1] mm/pgtable/debug: Add test validating architecture
 page table helpers
Message-ID: <20190909151344.ghfypjbgxyosjdk3@box>
References: <1567497706-8649-1-git-send-email-anshuman.khandual@arm.com>
 <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
 <20190904221618.1b624a98@thinkpad>
 <20e3044d-2af5-b27b-7653-cec53bdec941@arm.com>
 <20190905190629.523bdb87@thinkpad>
 <3c609e33-afbb-ffaf-481a-6d225a06d1d0@arm.com>
 <20190906210346.5ecbff01@thinkpad>
 <3d5de35f-8192-1c75-50a9-03e66e3b8e5c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3d5de35f-8192-1c75-50a9-03e66e3b8e5c@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 11:56:50AM +0530, Anshuman Khandual wrote:
> 
> 
> On 09/07/2019 12:33 AM, Gerald Schaefer wrote:
> > On Fri, 6 Sep 2019 11:58:59 +0530
> > Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> > 
> >> On 09/05/2019 10:36 PM, Gerald Schaefer wrote:
> >>> On Thu, 5 Sep 2019 14:48:14 +0530
> >>> Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> >>>   
> >>>>> [...]    
> >>>>>> +
> >>>>>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
> >>>>>> +static void pud_clear_tests(pud_t *pudp)
> >>>>>> +{
> >>>>>> +	memset(pudp, RANDOM_NZVALUE, sizeof(pud_t));
> >>>>>> +	pud_clear(pudp);
> >>>>>> +	WARN_ON(!pud_none(READ_ONCE(*pudp)));
> >>>>>> +}    
> >>>>>
> >>>>> For pgd/p4d/pud_clear(), we only clear if the page table level is present
> >>>>> and not folded. The memset() here overwrites the table type bits, so
> >>>>> pud_clear() will not clear anything on s390 and the pud_none() check will
> >>>>> fail.
> >>>>> Would it be possible to OR a (larger) random value into the table, so that
> >>>>> the lower 12 bits would be preserved?    
> >>>>
> >>>> So the suggestion is instead of doing memset() on entry with RANDOM_NZVALUE,
> >>>> it should OR a large random value preserving lower 12 bits. Hmm, this should
> >>>> still do the trick for other platforms, they just need non zero value. So on
> >>>> s390, the lower 12 bits on the page table entry already has valid value while
> >>>> entering this function which would make sure that pud_clear() really does
> >>>> clear the entry ?  
> >>>
> >>> Yes, in theory the table entry on s390 would have the type set in the last
> >>> 4 bits, so preserving those would be enough. If it does not conflict with
> >>> others, I would still suggest preserving all 12 bits since those would contain
> >>> arch-specific flags in general, just to be sure. For s390, the pte/pmd tests
> >>> would also work with the memset, but for consistency I think the same logic
> >>> should be used in all pxd_clear_tests.  
> >>
> >> Makes sense but..
> >>
> >> There is a small challenge with this. Modifying individual bits on a given
> >> page table entry from generic code like this test case is bit tricky. That
> >> is because there are not enough helpers to create entries with an absolute
> >> value. This would have been easier if all the platforms provided functions
> >> like __pxx() which is not the case now. Otherwise something like this should
> >> have worked.
> >>
> >>
> >> pud_t pud = READ_ONCE(*pudp);
> >> pud = __pud(pud_val(pud) | RANDOM_VALUE (keeping lower 12 bits 0))
> >> WRITE_ONCE(*pudp, pud);
> >>
> >> But __pud() will fail to build in many platforms.
> > 
> > Hmm, I simply used this on my system to make pud_clear_tests() work, not
> > sure if it works on all archs:
> > 
> > pud_val(*pudp) |= RANDOM_NZVALUE;
> 
> Which compiles on arm64 but then fails on x86 because of the way pmd_val()
> has been defined there.

Use instead

	*pudp = __pud(pud_val(*pudp) | RANDOM_NZVALUE);

It *should* be more portable.

-- 
 Kirill A. Shutemov

