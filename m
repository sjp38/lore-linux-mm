Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90A9D6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 15:42:40 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f11so4755392oic.3
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:42:40 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id k186si1033173oif.363.2017.08.11.12.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 12:42:39 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id j194so4196041oib.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:42:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170811191942.17487-3-riel@redhat.com>
References: <20170811191942.17487-1-riel@redhat.com> <20170811191942.17487-3-riel@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 Aug 2017 12:42:38 -0700
Message-ID: <CA+55aFzA+7CeCdUi-13DfOeE3FfhtTPMMmBA4UQx8FixXiD4YA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm <linux-mm@kvack.org>, Florian Weimer <fweimer@redhat.com>, colm@allcosts.net, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Linux API <linux-api@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>

On Fri, Aug 11, 2017 at 12:19 PM,  <riel@redhat.com> wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index 0e517be91a89..f9b0ad7feb57 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1134,6 +1134,16 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>                         !vma->anon_vma)
>                 return 0;
>
> +       /*
> +        * With VM_WIPEONFORK, the child inherits the VMA from the
> +        * parent, but not its contents.
> +        *
> +        * A child accessing VM_WIPEONFORK memory will see all zeroes;
> +        * a child accessing VM_DONTCOPY memory receives a segfault.
> +        */
> +       if (vma->vm_flags & VM_WIPEONFORK)
> +               return 0;
> +

Is this right?

Yes, you don't do the page table copies. Fine. But you leave vma with
the the anon_vma pointer - doesn't that mean that it's still connected
to the original anonvma chain, and we might end up swapping something
in?

And even if that ends up not being an issue, I'd expect that you'd
want to break the anon_vma chain just to not make it grow
unnecessarily.

So my gut feel is that doing this in "copy_page_range()" is wrong, and
the logic should be moved up to dup_mmap(), where we can also
short-circuit the anon_vma chain entirely.

No?

The madvice() interface looks fine to me.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
