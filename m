Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 29E4D6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:32:37 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id is5so17751590obc.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:32:37 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id bo7si4716315obb.15.2016.01.27.12.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 12:32:36 -0800 (PST)
Received: by mail-ob0-x22a.google.com with SMTP id is5so17751298obc.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:32:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160127193958.GA31407@cmpxchg.org>
References: <20160127193958.GA31407@cmpxchg.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 27 Jan 2016 12:32:16 -0800
Message-ID: <CALCETrVy_QzNyaCiOsdwDdgXAgdRmwXsdiyPz8R5h3xaNR00TQ@mail.gmail.com>
Subject: Re: [PATCH] mm: do not let vdso pages into LRU rotation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jan 27, 2016 at 11:39 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi,
>
> I noticed that vdso pages are faulted and unmapped as if they were
> regular file pages. And I'm guessing this is so that the vdso mappings
> are able to use the generic COW code in memory.c.
>
> However, it's a little unsettling that zap_pte_range() makes decisions
> based on PageAnon() and the page even reaches mark_page_accessed(), as
> that function makes several assumptions about the page being a regular
> LRU user page. It seems this isn't crashing today by sheer luck, but I
> am working on code that does when page_is_file_cache() returns garbage.
>
> I'm using this hack to work around it:
>
> diff --git a/mm/memory.c b/mm/memory.c
> index c387430f06c3..f0537c500150 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1121,7 +1121,8 @@ again:
>                                         set_page_dirty(page);
>                                 }
>                                 if (pte_young(ptent) &&
> -                                   likely(!(vma->vm_flags & VM_SEQ_READ)))
> +                                   likely(!(vma->vm_flags & VM_SEQ_READ)) &&
> +                                   !PageReserved(page))
>                                         mark_page_accessed(page);
>                                 rss[MM_FILEPAGES]--;
>                         }
>
> but I think we need a cleaner (and more robust) solution there to make
> it clearer that these pages are not regularly managed pages.
>
> Could the VDSO be a VM_MIXEDMAP to keep the initial unmanaged pages
> out of the VM while allowing COW into regular anonymous pages?

Probably.  What are its limitations?  We want ptrace to work on it,
and mprotect needs to work and allow COW.  access_process_vm should
probably work, too.

>
> Are there other requirements of the VDSO that I might be missing?

There's vvar, too, on x86_64, and that mapping is really strange.
It's different in -tip than in any released kernel, too.  VM_MIXEDMAP
seems to work.

If you want to improve this, take a look at -tip -- it's cleaned up a lot.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
