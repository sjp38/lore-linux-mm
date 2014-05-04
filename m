Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 625366B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 04:34:28 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so4456939eek.9
        for <linux-mm@kvack.org>; Sun, 04 May 2014 01:34:27 -0700 (PDT)
Received: from radon.swed.at (b.ns.miles-group.at. [95.130.255.144])
        by mx.google.com with ESMTPS id x47si6716154eel.133.2014.05.04.01.34.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 04 May 2014 01:34:26 -0700 (PDT)
Message-ID: <5365FB8A.8080303@nod.at>
Date: Sun, 04 May 2014 10:34:18 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix force_flush behavior in zap_pte_range()
References: <alpine.LSU.2.11.1404161239320.6778@eggly.anvils>	<1399160247-32093-1-git-send-email-richard@nod.at> <CA+55aFzbSUPGWyO42KM7geAy8WrP8e=q+KoqdOBY68zay0jrZA@mail.gmail.com>
In-Reply-To: <CA+55aFzbSUPGWyO42KM7geAy8WrP8e=q+KoqdOBY68zay0jrZA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>

Linus,

Am 04.05.2014 01:57, schrieb Linus Torvalds:
> On Sat, May 3, 2014 at 4:37 PM, Richard Weinberger <richard@nod.at> wrote:
>> Commit 1cf35d47 (mm: split 'tlb_flush_mmu()' into tlb flushing and memory freeing parts)
>> accidently changed the behavior of the force_flush variable.
> 
> No it didn't. There was nothing accidental about it, and it doesn't
> even change it the way you claim.
> 
>> Before the patch it was set by __tlb_remove_page(). Now it is only set to 1
>> if __tlb_remove_page() returns false but never set back to 0 if __tlb_remove_page()
>> returns true.
> 
> It starts out as zero. If __tlb_remove_page() returns true, it never
> gets set to anything *but* zero, except by the dirty shared mapping
> case that *needs* to set it to non-zero, exactly because it *needs* to
> flush the TLB before releasing the pte lock.
> 
> Which was the whole point of the patch.
> 
> Your explanation makes no sense for _another_ reason: even with your
> patch, it never gets set back to zero, since if it gets set to one you
> have that "break" in there. So the whole "gets set back to zero" is
> simply not relevant or true, with or with the patch.

Hmm, I got confused by:
                        if (PageAnon(page))
                                rss[MM_ANONPAGES]--;
                        else {
                                if (pte_dirty(ptent)) {
                                        force_flush = 1;

Here you set force_flush.

                                        set_page_dirty(page);
                                }
                                if (pte_young(ptent) &&
                                    likely(!(vma->vm_flags & VM_SEQ_READ)))
                                        mark_page_accessed(page);
                                rss[MM_FILEPAGES]--;
                        }
                        page_remove_rmap(page);
                        if (unlikely(page_mapcount(page) < 0))
                                print_bad_pte(vma, addr, ptent, page);
                        if (unlikely(!__tlb_remove_page(tlb, page))) {
                                force_flush = 1;
                                break;
                        }

And here it cannot get back to 0.

                        continue;



> The only place it actually gets zeroed (apart from initialization) is
> for the "goto again" case, which does it (and always did it)
> 
>> Fixes BUG: Bad rss-counter state ...
>> and
>> kernel BUG at mm/filemap.c:202!
> 
> So tell us more about those actual problems, because your patch and
> explanation is clearly wrong.
> 
> What hardware, what load, what "kernel BUG at filemap.c:202"?

With your patch applied I see lots of BUG: Bad rss-counter state messages on UML (x86_32)
when fuzzing with trinity the mremap syscall.
And sometimes I face BUG at mm/filemap.c:202.

UML is here a bit special. It maps two pages into every process (the stub pages)
to issue mmap(), munmap() or mprotect() upon a page fault to fix memory mappings
for the faulting process on the host side.
It has to make sure that a guest process cannot mess with its stub pages.
Otherwise a guest could execute code on the host side.

Trinity manages to destroy these stub pages, UML detects this upon TLB handling
and kills the current process immediately.
After killing a trinity child I start observing the said issues.

e.g.
fix_range_common: failed, killing current process: 841
fix_range_common: failed, killing current process: 842
fix_range_common: failed, killing current process: 843
BUG: Bad rss-counter state mm:28e69600 idx:0 val:2

> The shared dirty fix may certainly be exposing some other issue, but
> the only report I have seen about filemap.c:202 was reported by Dave
> Jones ten *days* before the commit you talk about was even done.

Mea culpa, I've not noticed that fact.
Back to the drawing board...

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
