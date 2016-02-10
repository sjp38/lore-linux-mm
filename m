Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 076EE6B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 05:58:48 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id 128so21492995wmz.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 02:58:47 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id 67si4654624wms.54.2016.02.10.02.58.46
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 02:58:46 -0800 (PST)
Date: Wed, 10 Feb 2016 11:58:43 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 3/4] x86, mce: Add __mcsafe_copy()
Message-ID: <20160210105843.GD23914@pd.tnic>
References: <cover.1454618190.git.tony.luck@intel.com>
 <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
 <20160207164933.GE5862@pd.tnic>
 <20160209231557.GA23207@agluck-desk.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20160209231557.GA23207@agluck-desk.sc.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Tue, Feb 09, 2016 at 03:15:57PM -0800, Luck, Tony wrote:
> > You can save yourself this MOV here in what is, I'm assuming, the
> > general likely case where @src is aligned and do:
> > 
> >         /* check for bad alignment of source */
> >         testl $7, %esi
> >         /* already aligned? */
> >         jz 102f
> > 
> >         movl %esi,%ecx
> >         subl $8,%ecx
> >         negl %ecx
> >         subl %ecx,%edx
> > 0:      movb (%rsi),%al
> >         movb %al,(%rdi)
> >         incq %rsi
> >         incq %rdi
> >         decl %ecx
> >         jnz 0b
> 
> The "testl $7, %esi" just checks the low three bits ... it doesn't
> change %esi.  But the code from the "subl $8" on down assumes that
> %ecx is a number in [1..7] as the count of bytes to copy until we
> achieve alignment.

Grr, sorry about that, I actually missed to copy-paste the AND:

        /* check for bad alignment of source */
        testl $7, %esi
        jz 102f                         /* already aligned */

        movl %esi,%ecx
        andl $7,%ecx
        subl $8,%ecx
        negl %ecx
        subl %ecx,%edx
0:      movb (%rsi),%al
        movb %al,(%rdi)
        incq %rsi
        incq %rdi
        decl %ecx
        jnz 0b

I basically am proposing to move the unlikely case out of line and
optimize the likely one.

> So your "movl %esi,%ecx" needs to be somthing that just copies the
> low three bits and zeroes the high part of %ecx.  Is there a cute
> way to do that in x86 assembler?

We could do some funky games with byte-sized moves but those are
generally slower anyway so doing the default operand size thing should
be ok.

> I copied that loop from arch/x86/lib/copy_user_64.S:__copy_user_nocache()
> I guess the answer depends on whether you generally copy enough
> cache lines to save enough time to cover the cost of saving and
> restoring those registers.

Well, that function will run on modern hw with a stack engine so I'd
assume those 4 pushes and pops would be paid for by the increased
registers count for the data shuffling.

But one could take out that function do some microbenchmarking with
different sizes and once with the current version and once with the
pushes and pops of r1[2-5] to see where the breakeven is.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
