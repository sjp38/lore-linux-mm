Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 913596B025B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 17:29:28 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id xn1so91730503obc.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 14:29:28 -0800 (PST)
Received: from mail-ob0-x243.google.com (mail-ob0-x243.google.com. [2607:f8b0:4003:c01::243])
        by mx.google.com with ESMTPS id bv7si3817170oec.61.2016.01.08.14.29.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 14:29:27 -0800 (PST)
Received: by mail-ob0-x243.google.com with SMTP id or18so29391325obb.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 14:29:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39FA7163@ORSMSX114.amr.corp.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
	<20160106123346.GC19507@pd.tnic>
	<CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
	<20160106175948.GA16647@pd.tnic>
	<CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
	<20160106194222.GC16647@pd.tnic>
	<20160107121131.GB23768@pd.tnic>
	<20160108014526.GA31242@agluck-desk.sc.intel.com>
	<20160108103733.GC12132@pd.tnic>
	<3908561D78D1C84285E8C5FCA982C28F39FA7163@ORSMSX114.amr.corp.intel.com>
Date: Fri, 8 Jan 2016 17:29:27 -0500
Message-ID: <CAMzpN2ifrUKBUmxj3E1XVBTu9Cz4HS+1bT185SY0w687ENKmug@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
From: Brian Gerst <brgerst@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Fri, Jan 8, 2016 at 11:29 AM, Luck, Tony <tony.luck@intel.com> wrote:
>>> +EXPORT_SYMBOL(ex_handler_default);
>>
>> Why not EXPORT_SYMBOL_GPL() ?
>>
>> We do not care about external modules.
>
> I thought the guideline was that new features are GPL, but changes
> to existing features shouldn't break by adding new GPL requirements.
>
> The point is moot though because  the shared hallucinations wore
> off this morning and I realized that having the "handler" be a pointer
> to a function can't work. We're storing the 32-bit signed offset from
> the extable to the target address. This is fine if the table and the
> address are close together. But for modules we have an exception
> table wherever vmalloc() loaded the module, and a function back
> in the base kernel.
>
> So back to your ".long 0" for the default case.  And if we want to allow
> modules to use any of the new handlers, then we can't use
> relative function pointers for them either.
>
> So I'm looking at making the new field just a simple integer and using
> it to index an array of function pointers (like in v7).
>
> Unless someone has a better idea?

Aren't modules loaded in the top 2GB of address space like the main
kernel?  Otherwise rip-relative addressing wouldn't work and modules
would have to be compiled as PIC.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
