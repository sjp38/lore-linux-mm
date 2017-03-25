Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 428AE6B0343
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 18:05:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 76so32429069itj.0
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 15:05:42 -0700 (PDT)
Received: from mail-it0-x22c.google.com (mail-it0-x22c.google.com. [2607:f8b0:4001:c0b::22c])
        by mx.google.com with ESMTPS id t13si2925086ith.106.2017.03.25.15.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Mar 2017 15:05:41 -0700 (PDT)
Received: by mail-it0-x22c.google.com with SMTP id y18so40317338itc.0
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 15:05:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170325215012.v5vywew7pfi3qk5f@pd.tnic>
References: <20170325185855.4itsyevunczus7sc@pd.tnic> <20170325214615.eqgmkwbkyldt7wwl@pd.tnic>
 <20170325215012.v5vywew7pfi3qk5f@pd.tnic>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 25 Mar 2017 15:05:41 -0700
Message-ID: <CA+55aFz+23dAey7FnSF3pRNSydEZEe59RUmhO_a=dqZdGm-sEg@mail.gmail.com>
Subject: Re: Splat during resume
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, x86-ml <x86@kernel.org>

I think this is the same as the kexec issue that also hit -tip.

It's *probably* fixed by the final series to actually enable 5-level
paging (which I don't think is in -tip yet), but even if that is the
case this is obviously a nasty bisectability problem.

You migth want to verify, though. The second batch starts here:

  https://marc.info/?l=linux-mm&m=148977696117208&w=2

Hmm?

In the meantime, this is currently -tip only, so I will stack back
from this thread unless you can reproduce it in mainline too.

               Linus

On Sat, Mar 25, 2017 at 2:50 PM, Borislav Petkov <bp@alien8.de> wrote:
>
> So I see rIP pointing to ident_pmd_init() and the stack trace has
> load_image_and_restore() so if I try to connect the dots, I get:
>
> load_image_and_restore
> |-> hibernation_restore
>  |-> resume_target_kernel
>   |-> swsusp_arch_resume
>    |-> set_up_temporary_mappings
>     |-> kernel_ident_mapping_init
>      |-> ... ident_pmd_init
>
> I'll let you folks make sense of what's going on.
>
> Thanks.
>
> --
> Regards/Gruss,
>     Boris.
>
> Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
