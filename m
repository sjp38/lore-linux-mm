Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9ED16B0292
	for <linux-mm@kvack.org>; Sat, 27 May 2017 18:46:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p62so5467551wrc.13
        for <linux-mm@kvack.org>; Sat, 27 May 2017 15:46:29 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id a15si7126510wme.139.2017.05.27.15.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 May 2017 15:46:28 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id d127so9586146wmf.1
        for <linux-mm@kvack.org>; Sat, 27 May 2017 15:46:28 -0700 (PDT)
Date: Sun, 28 May 2017 01:46:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv1, RFC 5/8] x86/mm: Fold p4d page table layer at runtime
Message-ID: <20170527224624.opc4yg4m7irvwbjl@node.shutemov.name>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <20170525203334.867-6-kirill.shutemov@linux.intel.com>
 <CAMzpN2j+CMCn-5pgEVZBNm9JMK1GEodvXqEtpAB2NXwTTHSM6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMzpN2j+CMCn-5pgEVZBNm9JMK1GEodvXqEtpAB2NXwTTHSM6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, May 27, 2017 at 11:09:54AM -0400, Brian Gerst wrote:
> >  static inline int pgd_none(pgd_t pgd)
> >  {
> > +       if (p4d_folded)
> > +               return 0;
> >         /*
> >          * There is no need to do a workaround for the KNL stray
> >          * A/D bit erratum here.  PGDs only point to page tables
> 
> These should use static_cpu_has(X86_FEATURE_LA57), so that it gets
> patched by alternatives.

Right, eventually we would likely need something like this. But at this
point I'm more worried about correctness than performance. Performance
will be the next step.

And I haven't tried it yet, but I would expect direct use of alternatives
wouldn't be possible. If I read code correctly, we enable paging way
before we apply alternatives. But we need to have something functional in
between.

I guess it will be fun :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
