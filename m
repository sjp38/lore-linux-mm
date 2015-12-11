Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6126B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 16:51:12 -0500 (EST)
Received: by oifz134 with SMTP id z134so1684432oif.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 13:51:12 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id s125si19023922oif.132.2015.12.11.13.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 13:51:11 -0800 (PST)
Received: by obc18 with SMTP id 18so92344256obc.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 13:51:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com> <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com> <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Dec 2015 13:50:52 -0800
Message-ID: <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Fri, Dec 11, 2015 at 1:19 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> I still don't get the BIT(63) thing.  Can you explain it?
>
> It will be more obvious when I get around to writing copy_from_user().
>
> Then we will have a function that can take page faults if there are pages
> that are not present.  If the page faults can't be fixed we have a -EFAULT
> condition. We can also take machine checks if we reads from a location with an
> uncorrected error.
>
> We need to distinguish these two cases because the action we take is
> different. For the unresolved page fault we already have the ABI that the
> copy_to/from_user() functions return zero for success, and a non-zero
> return is the number of not-copied bytes.

I'm missing something, though.  The normal fixup_exception path
doesn't touch rax at all.  The memory_failure path does.  But couldn't
you distinguish them by just pointing the exception handlers at
different landing pads?

Also, would it be more straightforward if the mcexception landing pad
looked up the va -> pa mapping by itself?  Or is that somehow not
reliable?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
