Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDEDE6B0343
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 17:50:33 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 76so8129892lft.18
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 14:50:33 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id v24si2130044ljd.133.2017.03.25.14.50.32
        for <linux-mm@kvack.org>;
        Sat, 25 Mar 2017 14:50:32 -0700 (PDT)
Date: Sat, 25 Mar 2017 22:50:12 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: Splat during resume
Message-ID: <20170325215012.v5vywew7pfi3qk5f@pd.tnic>
References: <20170325185855.4itsyevunczus7sc@pd.tnic>
 <20170325214615.eqgmkwbkyldt7wwl@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170325214615.eqgmkwbkyldt7wwl@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86-ml <x86@kernel.org>

On Sat, Mar 25, 2017 at 10:46:15PM +0100, Borislav Petkov wrote:
> On Sat, Mar 25, 2017 at 07:58:55PM +0100, Borislav Petkov wrote:
> > Hey Rafael,
> > 
> > have you seen this already (partial splat photo attached)? Happens
> > during resume from s2d. Judging by the timestamps, this looks like the
> > resume kernel before we switch to the original, boot one but I could be
> > mistaken.
> > 
> > This is -rc3+tip/master.
> > 
> > I can't catch a full splat because this is a laptop and it doesn't have
> > serial. netconsole is helping me for shit so we'd need some guess work.
> > 
> > So I'm open to suggestions.
> > 
> > Please don't say "bisect" yet ;-)))
> 
> No need, I found it. Reverting
> 
>   ea3b5e60ce80 ("x86/mm/ident_map: Add 5-level paging support")
> 
> makes the machine suspend and resume just fine again. Lemme add people to CC.

So I see rIP pointing to ident_pmd_init() and the stack trace has
load_image_and_restore() so if I try to connect the dots, I get:

load_image_and_restore
|-> hibernation_restore
 |-> resume_target_kernel
  |-> swsusp_arch_resume
   |-> set_up_temporary_mappings
    |-> kernel_ident_mapping_init
     |-> ... ident_pmd_init

I'll let you folks make sense of what's going on.

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
