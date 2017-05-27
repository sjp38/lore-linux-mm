Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3336B0292
	for <linux-mm@kvack.org>; Sat, 27 May 2017 18:56:56 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 14so10595825uar.7
        for <linux-mm@kvack.org>; Sat, 27 May 2017 15:56:56 -0700 (PDT)
Received: from mail-ua0-x22a.google.com (mail-ua0-x22a.google.com. [2607:f8b0:400c:c08::22a])
        by mx.google.com with ESMTPS id 73si2344855uag.23.2017.05.27.15.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 May 2017 15:56:55 -0700 (PDT)
Received: by mail-ua0-x22a.google.com with SMTP id y4so21035862uay.2
        for <linux-mm@kvack.org>; Sat, 27 May 2017 15:56:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170527224624.opc4yg4m7irvwbjl@node.shutemov.name>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <20170525203334.867-6-kirill.shutemov@linux.intel.com> <CAMzpN2j+CMCn-5pgEVZBNm9JMK1GEodvXqEtpAB2NXwTTHSM6g@mail.gmail.com>
 <20170527224624.opc4yg4m7irvwbjl@node.shutemov.name>
From: Brian Gerst <brgerst@gmail.com>
Date: Sat, 27 May 2017 18:56:54 -0400
Message-ID: <CAMzpN2gqK-QKwMh-tzXvU-tCKGWuhRdA6BFswsSQpT+YVuQyQQ@mail.gmail.com>
Subject: Re: [PATCHv1, RFC 5/8] x86/mm: Fold p4d page table layer at runtime
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, May 27, 2017 at 6:46 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sat, May 27, 2017 at 11:09:54AM -0400, Brian Gerst wrote:
>> >  static inline int pgd_none(pgd_t pgd)
>> >  {
>> > +       if (p4d_folded)
>> > +               return 0;
>> >         /*
>> >          * There is no need to do a workaround for the KNL stray
>> >          * A/D bit erratum here.  PGDs only point to page tables
>>
>> These should use static_cpu_has(X86_FEATURE_LA57), so that it gets
>> patched by alternatives.
>
> Right, eventually we would likely need something like this. But at this
> point I'm more worried about correctness than performance. Performance
> will be the next step.
>
> And I haven't tried it yet, but I would expect direct use of alternatives
> wouldn't be possible. If I read code correctly, we enable paging way
> before we apply alternatives. But we need to have something functional in
> between.

static_cpu_has() does the check dynamically before alternatives are
applied, so using it early isn't a problem.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
