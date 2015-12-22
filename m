Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id EA44582F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:38:08 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p187so123484417wmp.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 11:38:08 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id f187si45323711wmd.4.2015.12.22.11.38.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 11:38:07 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id l65so1842333wmf.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 11:38:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151222111349.GB3728@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
	<d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
	<20151222111349.GB3728@pd.tnic>
Date: Tue, 22 Dec 2015 11:38:07 -0800
Message-ID: <CA+8MBbJ+T0Bkea48rivWEZRn8_iPiSvrPm5p22RfbS7V0_KyEA@mail.gmail.com>
Subject: Re: [PATCHV3 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@pd.tnic, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm@ml01.01.org, X86-ML <x86@kernel.org>

On Tue, Dec 22, 2015 at 3:13 AM, Borislav Petkov <bp@alien8.de> wrote:
>> +#define      COPY_MCHECK_ERRBIT      BIT(63)
>
> What happened to the landing pads Andy was talking about? They sound
> like cleaner design than that bit 63...

I interpreted that comment as "stop playing with %rax in the fault
handler ... just change the IP to point the the .fixup location" ...
the target of the fixup being the "landing pad".

Right now this function has only one set of fault fixups (for machine
checks). When I tackle copy_from_user() it will sprout a second
set for page faults, and then will look a bit more like Andy's dual
landing pad example.

I still need an indicator to the caller which type of fault happened
since their actions will be different. So BIT(63) lives on ... but is
now set in the .fixup section rather than in the machine check
code.

I'll move the function and #defines as you suggest - we don't need
new files for these.  Also will fix the assembly code.
[In my defense that load immediate 0x8000000000000000 and 'or'
was what gcc -O2 generates from a simple bit of C code to set
bit 63 ... perhaps it is faster, or perhaps gcc is on drugs. In this
case code compactness wins over possible speed difference].

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
