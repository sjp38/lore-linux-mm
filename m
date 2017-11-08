Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F79644043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 16:36:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u27so3220565pfg.12
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 13:36:46 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0081.outbound.protection.outlook.com. [104.47.36.81])
        by mx.google.com with ESMTPS id y8si145293pli.714.2017.11.08.13.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 13:36:45 -0800 (PST)
Subject: Re: [PATCH] x86/mm: Unbreak modules that rely on external PAGE_KERNEL
 availability
References: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
 <alpine.DEB.2.20.1711082133410.1962@nanos>
 <CA+55aFz5Z8dfLp1swfOaEomH21mvCFEy=4w6L0cWska=He45FQ@mail.gmail.com>
 <20171108211525.4kxwj5ygg3kvfl2a@pd.tnic>
 <CA+55aFwNgm9qkptXTwVbN6Krwki+zvJD1M9UiGppX+Eb1yvfoQ@mail.gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <4c2c7797-00f5-13af-5a50-c815f6806b33@amd.com>
Date: Wed, 8 Nov 2017 15:36:31 -0600
MIME-Version: 1.0
In-Reply-To: <CA+55aFwNgm9qkptXTwVbN6Krwki+zvJD1M9UiGppX+Eb1yvfoQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jikos@kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Greg KH <greg@kroah.com>

On 11/8/2017 3:23 PM, Linus Torvalds wrote:
> On Wed, Nov 8, 2017 at 1:15 PM, Borislav Petkov <bp@suse.de> wrote:
>>
>> Right, AFAIRC, the main reason for this being an export was because if
>> we hid it in a function, you'd have all those function calls as part of
>> the _PAGE_* macros and that's just crap.
> 
> Yes, that would be worse.
> 
> I was thinking that maybe we could have a fixed "encrypt" bit in our
> PTE, and then replace that "software bit" with whatever the real
> hardware mask is (if any).
> 
> Because it's nasty to have these constants that _used_ to be
> constants, and still _look_ like constants, suddely do stupid memory
> reads from random kernel data.
> 
> So _this_ is the underflying problem:
> 
>    #define _PAGE_ENC  (_AT(pteval_t, sme_me_mask))
> 
> because that is simply not how the _PAGE_xyz macros should work!
> 
> So it should have been a fixed bit to begin with, and the dynamic part
> should have been elsewhere.
> 
> The whole EXPORT_SYMBOL() thing is just a symptom of that fundamental
> error. Modules - GPL or not - should _never_ have to know or care
> about this _PAGE_ENC bit madness, simply because it shouldn't have
> been there.

I'll look into that and see what I can come up with.

Thanks,
Tom

> 
>                 Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
