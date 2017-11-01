Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 968C46B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 06:38:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z11so1911993pfk.23
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 03:38:46 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w5si485056pgo.221.2017.11.01.03.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 03:38:45 -0700 (PDT)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 16EAD21921
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 10:38:45 +0000 (UTC)
Received: by mail-io0-f175.google.com with SMTP id 97so5039249iok.7
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 03:38:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171101101147.x2gvag62zpzydgr3@node.shutemov.name>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223154.67F15B2A@viggo.jf.intel.com>
 <CALCETrW06XjaWYD1O_HPXPDrHS96FZz9=OkPCQ3vsKrAxnr8+A@mail.gmail.com> <20171101101147.x2gvag62zpzydgr3@node.shutemov.name>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 03:38:23 -0700
Message-ID: <CALCETrVhKwGPN-=sL5SoSg1ussO+oCfzH1cJ+ZSWb69Y51XjXg@mail.gmail.com>
Subject: Re: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 1, 2017 at 3:11 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> On Wed, Nov 01, 2017 at 01:01:45AM -0700, Andy Lutomirski wrote:
>> On Tue, Oct 31, 2017 at 3:31 PM, Dave Hansen
>> <dave.hansen@linux.intel.com> wrote:
>> >
>> > Our CR4-based TLB flush currently requries global pages to be
>> > supported *and* enabled.  But, we really only need for them to be
>> > supported.  Make the code more robust by alllowing X86_CR4_PGE to
>> > clear as well as set.
>> >
>> > This change was suggested by Kirill Shutemov.
>>
>> I may have missed something, but why would be ever have CR4.PGE off?
>
> This came out from me thinking on if we can disable global pages by not
> turning on CR4.PGE instead of making _PAGE_GLOBAL zero.
>
> Dave decided to not take this path, but this change would make
> __native_flush_tlb_global_irq_disabled() a bit less fragile in case
> if the situation would change in the future.

How about just adding a VM_WARN_ON_ONCE, then?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
