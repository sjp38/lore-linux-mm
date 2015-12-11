Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 38F026B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:56:06 -0500 (EST)
Received: by obbsd4 with SMTP id sd4so44524424obb.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:56:06 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id d3si711821obo.16.2015.12.11.14.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 14:56:05 -0800 (PST)
Received: by obber4 with SMTP id er4so10968783obb.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:56:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F82FED@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com> <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
 <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
 <CALCETrUK1raRagO=JxCRpy0_eKfS56gce737fVe9rtJqNwH+_A@mail.gmail.com> <3908561D78D1C84285E8C5FCA982C28F39F82FED@ORSMSX114.amr.corp.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Dec 2015 14:55:45 -0800
Message-ID: <CALCETrUFQXPB9HM8O+4UfMij7nodfrWtjicy0XNhOiWCka+4yw@mail.gmail.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Fri, Dec 11, 2015 at 2:45 PM, Luck, Tony <tony.luck@intel.com> wrote:
>>> But a machine check safe copy_from_user() would be useful
>>> current generation cpus that broadcast all the time.
>>
>> Fair enough.
>
> Thanks for spending the time to look at this.  Coaxing me to re-write the
> tail of do_machine_check() has made that code much better. Too many
> years of one patch on top of another without looking at the whole context.
>
> Cogitate on this series over the weekend and see if you can give me
> an Acked-by or Reviewed-by (I'll be adding a #define for BIT(63)).

I can't review the MCE decoding part, because I don't understand it
nearly well enough.  The interaction with the core fault handling
looks fine, modulo any need to bikeshed on the macro naming (which
I'll refrain from doing).

I still think it would be better if you get rid of BIT(63) and use a
pair of landing pads, though.  They could be as simple as:

.Lpage_fault_goes_here:
    xorq %rax, %rax
    jmp .Lbad

.Lmce_goes_here:
    /* set high bit of rax or whatever */
    /* fall through */

.Lbad:
    /* deal with it */

That way the magic is isolated to the function that needs the magic.

Also, at least renaming the macro to EXTABLE_MC_PA_IN_AX might be
nice.  It'll keep future users honest.  Maybe some day there'll be a
PA_IN_AX flag, and, heck, maybe some day there'll be ways to get info
for non-MCE faults delivered through fixup_exception.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
