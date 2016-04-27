Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id A99936B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:35:02 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id sq19so96715036igc.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:35:02 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id v53si2100636otv.211.2016.04.27.08.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 08:35:02 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id x19so52933747oix.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:35:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160427153158.GJ21011@pd.tnic>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225604.13567.55443.stgit@tlendack-t1.amdoffice.net>
 <CALCETrU9ozp1mBKG-P88cKRJRY5bifn2Ab__AZcn5b33n3j2cg@mail.gmail.com>
 <5720D066.7080409@amd.com> <CALCETrV+JzPZjrrqkhWSVfvKQt62Aq8NSW=ZvfdiAi8XKoLi8A@mail.gmail.com>
 <5720D546.6050105@amd.com> <CALCETrVcS-H9BtCevT4=Luo2sK0A3cbBs7Rs=RaBr2yzOzxp4w@mail.gmail.com>
 <20160427153158.GJ21011@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 27 Apr 2016 08:34:42 -0700
Message-ID: <CALCETrUUL+2CJvo8WWWCw7LB6+osrsx5VfLNBLW=FWiRZchtjg@mail.gmail.com>
Subject: Re: [RFC PATCH v1 01/18] x86: Set the write-protect cache mode for
 AMD processors
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Apr 27, 2016 at 8:31 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Wed, Apr 27, 2016 at 08:12:56AM -0700, Andy Lutomirski wrote:
>> I think there are some errata
>
> Isn't that addressed by the first branch of the if-test in pat_init():
>
>         if ((c->x86_vendor == X86_VENDOR_INTEL) &&
>             (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
>              ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {
>

That's the intent, but I'm unconvinced that it's complete.  The reason
that WT is in slot 7 is that if it accidentally ends up using the slot
3 entry instead of 7 (e.g. if a 2M page gets confused due to an
erratum we didn't handle or similar), then it falls back to UC, which
is safe.

But this is mostly moot in this case.  There is no safe fallback for
WP, but it doesn't really matter, because no one will actually try to
use it except on a system will full PAT support anyway.  So I'm not
really concerned.

>
> --
> Regards/Gruss,
>     Boris.
>
> ECO tip #101: Trim your mails when you reply.



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
