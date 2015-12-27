Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 558A282FCE
	for <linux-mm@kvack.org>; Sat, 26 Dec 2015 21:17:19 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id bx1so97145492obb.0
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 18:17:19 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id i6si25155494obk.65.2015.12.26.18.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 18:17:18 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id l9so132284885oia.2
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 18:17:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic> <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
 <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com> <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 26 Dec 2015 18:16:59 -0800
Message-ID: <CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat, Dec 26, 2015 at 6:15 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Sat, Dec 26, 2015 at 6:08 PM, Tony Luck <tony.luck@gmail.com> wrote:
>> On Sat, Dec 26, 2015 at 6:54 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> On Dec 26, 2015 6:33 PM, "Borislav Petkov" <bp@alien8.de> wrote:
>>>> Andy, why is that? It makes the exception handling much simpler this way...
>>>>
>>>
>>> I like the idea of moving more logic into C, but I don't like
>>> splitting the logic across files and adding nasty special cases like
>>> this.
>>>
>>> But what if we generalized it?  An extable entry gives a fault IP and
>>> a landing pad IP.  Surely we can squeeze a flag bit in there.
>>
>> The clever squeezers have already been here. Instead of a pair
>> of 64-bit values for fault_ip and fixup_ip they managed with a pair
>> of 32-bit values that are each the relative offset of the desired address
>> from the table location itself.
>>
>> We could make one of them 31-bits (since even an "allyesconfig" kernel
>> is still much smaller than a gigabyte) to free a bit for a flag. But there
>> are those external tools to pre-sort exception tables that would all
>> need to be fixed too.

Wait, why?  The external tools sort by source address, and we'd
squeeze the flag into the target address, no?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
