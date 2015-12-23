Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 787F882F99
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 18:57:12 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id bx1so58030211obb.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:57:12 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id b202si15212281oig.100.2015.12.23.15.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 15:57:11 -0800 (PST)
Received: by mail-oi0-x234.google.com with SMTP id o124so131284285oia.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:57:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1450117783.git.luto@kernel.org>
References: <cover.1450117783.git.luto@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 23 Dec 2015 15:56:52 -0800
Message-ID: <CALCETrUo4U9RwOVBZu7P0d9DjtgRTFOyUQFteoVQroMdaOwVuQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/6] mm, x86/vdso: Special IO mapping improvements
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Kees Cook <keescook@chromium.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>

Hi Oleg and Kees-

I meant to cc you on this in the first place, but I failed.  If you
have a few minutes, want to take a peek at these and see if you can
poke any holes in them?  I'm reasonably confident that they're a
considerable improvement over the old state of affairs, but they might
still not be perfect.

Let me know if you want me to email out a fresh copy.  This series
applies to tip:x86/asm.

--Andy

On Mon, Dec 14, 2015 at 10:31 AM, Andy Lutomirski <luto@kernel.org> wrote:
> This applies on top of the earlier vdso pvclock series I sent out.
> Once that lands in -tip, this will apply to -tip.
>
> This series cleans up the hack that is our vvar mapping.  We currently
> initialize the vvar mapping as a special mapping vma backed by nothing
> whatsoever and then we abuse remap_pfn_range to populate it.
>
> This cheats the mm core, probably breaks under various evil madvise
> workloads, and prevents handling faults in more interesting ways.
>
> To clean it up, this series:
>
>  - Adds a special mapping .fault operation
>  - Adds a vm_insert_pfn_prot helper
>  - Uses the new .fault infrastructure in x86's vdso and vvar mappings
>  - Hardens the HPET mapping, mitigating an HW attack surface that bothers me
>
> akpm, can you ack patck 1?
>
> Changes from v1:
>  - Lots of changelog clarification requested by akpm
>  - Minor tweaks to style and comments in the first two patches
>
> Andy Lutomirski (6):
>   mm: Add a vm_special_mapping .fault method
>   mm: Add vm_insert_pfn_prot
>   x86/vdso: Track each mm's loaded vdso image as well as its base
>   x86,vdso: Use .fault for the vdso text mapping
>   x86,vdso: Use .fault instead of remap_pfn_range for the vvar mapping
>   x86/vdso: Disallow vvar access to vclock IO for never-used vclocks
>
>  arch/x86/entry/vdso/vdso2c.h            |   7 --
>  arch/x86/entry/vdso/vma.c               | 124 ++++++++++++++++++++------------
>  arch/x86/entry/vsyscall/vsyscall_gtod.c |   9 ++-
>  arch/x86/include/asm/clocksource.h      |   9 +--
>  arch/x86/include/asm/mmu.h              |   3 +-
>  arch/x86/include/asm/vdso.h             |   3 -
>  arch/x86/include/asm/vgtod.h            |   6 ++
>  include/linux/mm.h                      |   2 +
>  include/linux/mm_types.h                |  22 +++++-
>  mm/memory.c                             |  25 ++++++-
>  mm/mmap.c                               |  13 ++--
>  11 files changed, 151 insertions(+), 72 deletions(-)
>
> --
> 2.5.0
>



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
