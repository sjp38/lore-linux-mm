Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A60B2C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:18:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67861214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:18:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67861214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEB958E0003; Mon, 28 Jan 2019 20:18:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D75478E0001; Mon, 28 Jan 2019 20:18:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3D3C8E0003; Mon, 28 Jan 2019 20:18:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6E48E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 20:18:16 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id x26so12787005pgc.5
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:18:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=a+2blrXX59xEskjaE8gYIMdcuinaNPOCZz8mlE3lSzc=;
        b=F++4IhIan/IhN1pNaSUmLRLGJW5+eh5oi4UXXQBVufTiu1fxiPMnz3quWHoeIS8wzb
         th9tukZB/e8kVAmvJmAUHk7iDQKyBfKKd8cl/NoNb3awYf+/ewuIjZDRovHH2IMDmMlC
         IH/HfMGbRIGfZPJnQtm10IsdtyA/mMS000yap6rszuCRoOHGtYeURmQnfjCdAe7ztR4+
         b+6AARrEK1owqU7gDXMYB0JfYHtaLHUj36xAng7C7KgZdKu+vy5YEXgFIbTFQWMeOKbg
         KHAqXvcsczNN+K879qQ7vJT1wDsfmZV/e4YmCXhNP8YbNEaLXYTCe36eMqiy51K9Kksg
         cmgA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukfY0EGljpS2Eomemk8dbMoxweVPp5atHBpx4+cH1wHI23h1H9KK
	nnq0/2x8oODc8jVI82ECd6NV4HpYLrou4UC1w3Ymbe5JeEf1oUewWoNXcMNGaL5t9f/+e9J254v
	V5J+G3FaguvGhUuXeChIvWpG88MK76VpkrzReciHlwkfb6ld98tgTIwstx5uCR9g=
X-Received: by 2002:a63:5320:: with SMTP id h32mr21886363pgb.414.1548724696184;
        Mon, 28 Jan 2019 17:18:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4n8RfeNBQAzu/ngrMjJoG6CP2UjyZVAq5D+jXzgzMCBbSDi7Eeyq8hCYhhXszdjGGi8iBJ
X-Received: by 2002:a63:5320:: with SMTP id h32mr21886325pgb.414.1548724695241;
        Mon, 28 Jan 2019 17:18:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548724695; cv=none;
        d=google.com; s=arc-20160816;
        b=XMXpFxHRKSSSle6TDMawjfiijYHHwgDB5GVzJY0uvpKZk3XOGGuJsbHfsDcRqAWsxg
         WWicjUhryIQ130KFifLYxsY7rZeGbd12yG+ZKZ/0ntcdMtV3tlQ9AGJG46UYWNRbZBay
         69sSFHbO8ltGSKTJDAOqB+XJLq51YgYWWoaTjJrWW4QVu7J9OoH4BMAaaie3QVUJZ+QN
         z/zlUn/IzEKBbjs2XphF3oUPDhk09Tz9ag2/cDpYc5rWflApC+OI+4h7uNdcrdAA0S5M
         cWxRYP4BKaVuxATErsJUyeOj79IkXbpQEU28gJ0mgra/PfTz3pGowu6njiP90gWsy+Na
         5TYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=a+2blrXX59xEskjaE8gYIMdcuinaNPOCZz8mlE3lSzc=;
        b=gMb3gN64b5cZPz8ImWBIiofO53+74uN18PoJrIfPb1iItJgCg+YoY1Imf1PWcuE2vQ
         toXSqf6yaUonmBjryTSLWy0mjQLPfZDYtlTW1Ar9fa7mrkmXBuY8iywhFv2duqIVmBrN
         qQL2PD0eaH7lpg9G5+14Q9+DUX6bKBHbGmLIZTnWVDmTq0ErkJ3IktbWRnWTqhvUbUhK
         ywhZEhwV5jv7ex9SOas6AIBrIw9aZG3IVlQusC94nkgMk2OT9keujxhThDYnzulbxSkF
         7lAceXfIvYpyGLdtR2DNVSioSzyo8Cvso0T0RbJXkT+PhMwRaTM9rG7EClt3n10oMpeW
         z+ZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id m14si34223879pgd.326.2019.01.28.17.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 17:18:15 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43pTC33jzjz9sCX;
	Tue, 29 Jan 2019 12:18:06 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Dave Hansen <dave.hansen@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>, Jerome Glisse <jglisse@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 1/5] mm/resource: return real error codes from walk failures
In-Reply-To: <4898e064-5298-6a82-83ea-23d16f3dfb3d@intel.com>
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231442.EFD29EE0@viggo.jf.intel.com> <CAErSpo7kMjfi-1r8ZyGbheWzo+JCFkDZ1zpVhyNV7VVy8NOV7g@mail.gmail.com> <4898e064-5298-6a82-83ea-23d16f3dfb3d@intel.com>
Date: Tue, 29 Jan 2019 12:18:05 +1100
Message-ID: <87k1ios1ma.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <dave.hansen@intel.com> writes:
> On 1/25/19 1:02 PM, Bjorn Helgaas wrote:
>>> @@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
>>>         unsigned long flags;
>>>         struct resource res;
>>>         unsigned long pfn, end_pfn;
>>> -       int ret = -1;
>>> +       int ret = -EINVAL;
>> Can you either make a similar change to the powerpc version of
>> walk_system_ram_range() in arch/powerpc/mm/mem.c or explain why it's
>> not needed?  It *seems* like we'd want both versions of
>> walk_system_ram_range() to behave similarly in this respect.
>
> Sure.  A quick grep shows powerpc being the only other implementation.

Ugh gross, why are we reimplementing it? ...

Oh right, memblock vs iomem. We should fix that one day :/

> I'll just add this hunk:
>
>> diff -puN arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1 arch/powerpc/mm/mem.c
>> --- a/arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1  2019-01-25 12:57:00.000004446 -0800
>> +++ b/arch/powerpc/mm/mem.c     2019-01-25 12:58:13.215004263 -0800 
>> @@ -188,7 +188,7 @@ walk_system_ram_range(unsigned long star 
>>         struct memblock_region *reg; 
>>         unsigned long end_pfn = start_pfn + nr_pages; 
>>         unsigned long tstart, tend; 
>> -       int ret = -1; 
>> +       int ret = -EINVAL; 
>
> I'll also dust off the ol' cross-compiler and make sure I didn't
> fat-finger anything.

Modern Fedora & Ubuntu have packaged cross toolchains. Otherwise there's
the kernel.org ones, or bootlin has versions with libc if you need it.

Patch looks fine. That value could only get to userspace if we have no
memory, which would be interesting.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

