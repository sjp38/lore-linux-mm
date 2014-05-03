Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id B98226B0036
	for <linux-mm@kvack.org>; Sat,  3 May 2014 19:57:28 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id jz11so3363663veb.21
        for <linux-mm@kvack.org>; Sat, 03 May 2014 16:57:28 -0700 (PDT)
Received: from mail-ve0-x233.google.com (mail-ve0-x233.google.com [2607:f8b0:400c:c01::233])
        by mx.google.com with ESMTPS id xt2si736300vcb.141.2014.05.03.16.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 03 May 2014 16:57:28 -0700 (PDT)
Received: by mail-ve0-f179.google.com with SMTP id oy12so4061302veb.24
        for <linux-mm@kvack.org>; Sat, 03 May 2014 16:57:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399160247-32093-1-git-send-email-richard@nod.at>
References: <alpine.LSU.2.11.1404161239320.6778@eggly.anvils>
	<1399160247-32093-1-git-send-email-richard@nod.at>
Date: Sat, 3 May 2014 16:57:27 -0700
Message-ID: <CA+55aFzbSUPGWyO42KM7geAy8WrP8e=q+KoqdOBY68zay0jrZA@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix force_flush behavior in zap_pte_range()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>

On Sat, May 3, 2014 at 4:37 PM, Richard Weinberger <richard@nod.at> wrote:
> Commit 1cf35d47 (mm: split 'tlb_flush_mmu()' into tlb flushing and memory freeing parts)
> accidently changed the behavior of the force_flush variable.

No it didn't. There was nothing accidental about it, and it doesn't
even change it the way you claim.

> Before the patch it was set by __tlb_remove_page(). Now it is only set to 1
> if __tlb_remove_page() returns false but never set back to 0 if __tlb_remove_page()
> returns true.

It starts out as zero. If __tlb_remove_page() returns true, it never
gets set to anything *but* zero, except by the dirty shared mapping
case that *needs* to set it to non-zero, exactly because it *needs* to
flush the TLB before releasing the pte lock.

Which was the whole point of the patch.

Your explanation makes no sense for _another_ reason: even with your
patch, it never gets set back to zero, since if it gets set to one you
have that "break" in there. So the whole "gets set back to zero" is
simply not relevant or true, with or with the patch.

The only place it actually gets zeroed (apart from initialization) is
for the "goto again" case, which does it (and always did it)

> Fixes BUG: Bad rss-counter state ...
> and
> kernel BUG at mm/filemap.c:202!

So tell us more about those actual problems, because your patch and
explanation is clearly wrong.

What hardware, what load, what "kernel BUG at filemap.c:202"?

The shared dirty fix may certainly be exposing some other issue, but
the only report I have seen about filemap.c:202 was reported by Dave
Jones ten *days* before the commit you talk about was even done.

So this whole thing makes no sense what-so-ever.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
