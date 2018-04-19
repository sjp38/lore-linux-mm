Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16D256B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 20:45:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v19so1828692pfn.7
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 17:45:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g92-v6si2262323plg.256.2018.04.18.17.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 17:45:18 -0700 (PDT)
Received: from mail-wr0-f170.google.com (mail-wr0-f170.google.com [209.85.128.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5E556217DF
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 00:45:18 +0000 (UTC)
Received: by mail-wr0-f170.google.com with SMTP id s18-v6so9351776wrg.9
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 17:45:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180419003833.GO6694@tassilo.jf.intel.com>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
 <1523892323-14741-4-git-send-email-joro@8bytes.org> <87k1t4t7tw.fsf@linux.intel.com>
 <CA+55aFxKzsPQW4S4esvJY=wb7D3LKBdDDcXoMKJSqcOgnD3FuA@mail.gmail.com> <20180419003833.GO6694@tassilo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 18 Apr 2018 17:44:56 -0700
Message-ID: <CALCETrWYdug6cY_ZjGPV19baFWb_VZxMHGmfxnoJfnXP7z=1Sg@mail.gmail.com>
Subject: Re: [PATCH 03/35] x86/entry/32: Load task stack from x86_tss.sp1 in
 SYSENTER handler
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waim@linux.intel.com

On Wed, Apr 18, 2018 at 5:38 PM, Andi Kleen <ak@linux.intel.com> wrote:
> On Wed, Apr 18, 2018 at 05:02:02PM -0700, Linus Torvalds wrote:
>> On Wed, Apr 18, 2018 at 4:26 PM, Andi Kleen <ak@linux.intel.com> wrote:
>> >
>> > Seems like a hack. Why can't that be stored in a per cpu variable?
>>
>> It *is* a percpu variable - the whole x86_tss structure is percpu.
>>
>> I guess it could be a different (separate) percpu variable, but might
>> as well use the space we already have allocated.
>
> Would be better/cleaner to use a separate variable instead of reusing
> x86 structures like this. Who knows what subtle side effects that
> may have eventually.


This variable is extremely hot, and it=E2=80=99s used under the same
circumstances as sp0, so sharing a cache line makes sense. And x86_64
works this way.

>
> It will be also easier to understand in the code.

I suppose it could go right before the TSS, but then we have potential
alignment issues.  We could also muck with unions to give the field an
alternative, clearer name, I suppose.  But this patch should go in
regardless and any cleanups should be done on x86_32 and x86_64
simultaneously, I think.
