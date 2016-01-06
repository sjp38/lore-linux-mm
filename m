Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id ABD8A6B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 13:07:39 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ba1so305807662obb.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 10:07:39 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id c75si22894127oig.36.2016.01.06.10.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 10:07:39 -0800 (PST)
Received: by mail-ob0-x236.google.com with SMTP id wp13so170810192obc.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 10:07:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160106175948.GA16647@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com> <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic> <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jan 2016 10:07:19 -0800
Message-ID: <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Wed, Jan 6, 2016 at 9:59 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Wed, Jan 06, 2016 at 09:54:19AM -0800, Andy Lutomirski wrote:
>> I assume that this zero is to save the couple of bytes for the
>> relocation entry on relocatable kernels?
>
> I didn't want to touch all _ASM_EXTABLE() macro invocations by adding a
> third param @handler which is redundant as we know which it is.

I see.  You could shove the .long ex_handler_default - . into the
macro, but that would indeed bloat the kernel image a bit more
(although not the in-memory size of the kernel).

>
>> > +       new_ip  = ex_fixup_addr(e);
>> > +       handler = ex_fixup_handler(e);
>> > +
>> > +       if (!handler)
>> > +               handler = ex_handler_default;
>>
>> the !handler condition here will never trigger because the offset was
>> already applied.
>
> Actually, if I do "0 - .", that would overflow the int because current
> location is virtual address and that's 64-bit. Or would gas simply
> truncate it? Lemme check...
>
> Anyway, what we should do instead is simply
>
>         .long 0
>
> to denote that the @handler is implicit.
>
> Right?

Agreed.  I just think that your current fixup_ex_handler
implementation needs adjustment if you do it that way.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
