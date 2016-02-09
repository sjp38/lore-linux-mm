Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D62986B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 18:15:58 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so1361010pac.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 15:15:58 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rr5si470350pab.188.2016.02.09.15.15.58
        for <linux-mm@kvack.org>;
        Tue, 09 Feb 2016 15:15:58 -0800 (PST)
Date: Tue, 9 Feb 2016 15:15:57 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v10 3/4] x86, mce: Add __mcsafe_copy()
Message-ID: <20160209231557.GA23207@agluck-desk.sc.intel.com>
References: <cover.1454618190.git.tony.luck@intel.com>
 <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
 <20160207164933.GE5862@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160207164933.GE5862@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

> You can save yourself this MOV here in what is, I'm assuming, the
> general likely case where @src is aligned and do:
> 
>         /* check for bad alignment of source */
>         testl $7, %esi
>         /* already aligned? */
>         jz 102f
> 
>         movl %esi,%ecx
>         subl $8,%ecx
>         negl %ecx
>         subl %ecx,%edx
> 0:      movb (%rsi),%al
>         movb %al,(%rdi)
>         incq %rsi
>         incq %rdi
>         decl %ecx
>         jnz 0b

The "testl $7, %esi" just checks the low three bits ... it doesn't
change %esi.  But the code from the "subl $8" on down assumes that
%ecx is a number in [1..7] as the count of bytes to copy until we
achieve alignment.

So your "movl %esi,%ecx" needs to be somthing that just copies the
low three bits and zeroes the high part of %ecx.  Is there a cute
way to do that in x86 assembler?

> Why aren't we pushing %r12-%r15 on the stack after the "jz 17f" above
> and using them too and thus copying a whole cacheline in one go?
> 
> We would need to restore them when we're done with the cacheline-wise
> shuffle, of course.

I copied that loop from arch/x86/lib/copy_user_64.S:__copy_user_nocache()
I guess the answer depends on whether you generally copy enough
cache lines to save enough time to cover the cost of saving and
restoring those registers.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
