Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 118E76B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:18:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d127so36206978wmf.15
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:18:53 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 71si3778666wmw.68.2017.05.24.01.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 01:18:51 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id d127so45298088wmf.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:18:51 -0700 (PDT)
Date: Wed, 24 May 2017 10:18:48 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 04/11] x86/mm: Pass flush_tlb_info to
 flush_tlb_others() etc
Message-ID: <20170524081848.dozbpzdbi5syyyx2@gmail.com>
References: <cover.1495492063.git.luto@kernel.org>
 <3aa98b1199bdcc258706bc8084135b51b52f1ece.1495492063.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3aa98b1199bdcc258706bc8084135b51b52f1ece.1495492063.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>


* Andy Lutomirski <luto@kernel.org> wrote:

> Rather than passing all the contents of flush_tlb_info to
> flush_tlb_others(), pass a pointer to the structure directly. For
> consistency, this also removes the unnecessary cpu parameter from
> uv_flush_tlb_others() to make its signature match the other
> *flush_tlb_others() functions.
> 
> This serves two purposes:
> 
>  - It will dramatically simplify future patches that change struct
>    flush_tlb_info, which I'm planning to do.
> 
>  - struct flush_tlb_info is an adequate description of what to do
>    for a local flush, too, so by reusing it we can remove duplicated
>    code between local and remove flushes in a future patch.
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/paravirt.h       |  6 ++--
>  arch/x86/include/asm/paravirt_types.h |  5 ++-
>  arch/x86/include/asm/tlbflush.h       | 19 ++++++-----
>  arch/x86/include/asm/uv/uv.h          |  9 ++---
>  arch/x86/mm/tlb.c                     | 64 +++++++++++++++++------------------
>  arch/x86/platform/uv/tlb_uv.c         | 10 +++---
>  arch/x86/xen/mmu.c                    | 10 +++---
>  7 files changed, 59 insertions(+), 64 deletions(-)

I've picked up the first three patches, but this patch apparently clashes with 
v4.12 changes:

patching file arch/x86/platform/uv/tlb_uv.c
Hunk #1 FAILED at 1109.
Hunk #2 FAILED at 1170.
2 out of 2 hunks FAILED -- rejects in file arch/x86/platform/uv/tlb_uv.c
patching file arch/x86/xen/mmu.c
Hunk #1 FAILED at 1427.
Hunk #2 FAILED at 1440.
Hunk #3 FAILED at 1454.
3 out of 3 hunks FAILED -- rejects in file arch/x86/xen/mmu.c

Patch 10 is broken and patch 11 needs an Ack from the KVM guys so I'll wait for a 
new series on top of the new x86/mm branch. (Which I'll push out once it passes 
testing.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
