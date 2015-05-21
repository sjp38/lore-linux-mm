Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id EBAB76B017D
	for <linux-mm@kvack.org>; Thu, 21 May 2015 11:53:28 -0400 (EDT)
Received: by qgez61 with SMTP id z61so38842400qge.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 08:53:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g22si534087qhc.47.2015.05.21.08.53.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 08:53:28 -0700 (PDT)
Date: Thu, 21 May 2015 17:52:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/23] userfaultfd v4
Message-ID: <20150521155251.GB4643@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <20150521131111.GA8932@teco.navytux.spb.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150521131111.GA8932@teco.navytux.spb.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Smelkov <kirr@nexedi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hi Kirill,

On Thu, May 21, 2015 at 04:11:11PM +0300, Kirill Smelkov wrote:
> Sorry for maybe speaking up too late, but here is additional real

Not too late, in fact I don't think there's any change required for
this at this stage, but it'd be great if you could help me to review.

> Since arrays can be large, it would be slow and thus not practical to
[..]
> So I've implemented a scheme where array data is initially PROT_READ
> protected, then we catch SIGSEGV, if it is write and area belongs to array

In the case of postcopy live migration (for qemu and/or containers) and
postcopy live snapshotting, splitting the vmas is not an option
because we may run out of them.

If your PROT_READ areas are limited perhaps this isn't an issue but
with hundreds GB guests (currently plenty in production) that needs to
live migrate fully reliably and fast, the vmas could exceed the limit
if we were to use mprotect. If your arrays are very large and the
PROT_READ aren't limited, using userfaultfd this isn't only an
optimization for you too, it's actually a must to avoid a potential
-ENOMEM.

> Also, since arrays could be large - bigger than RAM, and only sparse
> parts of it could be needed to get needed information, for reading it
> also makes sense to lazily load data in SIGSEGV handler with initial
> PROT_NONE protection.

Similarly I heard somebody wrote a fastresume to load the suspended
(on disk) guest ram using userfaultfd. That is a slightly less
fundamental case than postcopy because you could do it also with
MAP_SHARED, but it's still interesting in allowing to compress or
decompress the suspended ram on the fly with lz4 for example,
something MAP_PRIVATE/MAP_SHARED wouldn't do (plus there's the
additional benefit of not having an orphaned inode left open even if
the file is deleted, that prevents to unmount the filesystem for the
whole lifetime of the guest).

> This is very similar to how memory mapped files work, but adds
> transactionality which, as far as I know, is not provided by any
> currently in-kernel filesystem on Linux.

That's another benefit yes.

> The gist of virtual memory-manager is this:
> 
>     https://lab.nexedi.cn/kirr/wendelin.core/blob/master/include/wendelin/bigfile/virtmem.h
>     https://lab.nexedi.cn/kirr/wendelin.core/blob/master/bigfile/virtmem.c  (vma_on_pagefault)

I'll check it more in detail ASAP, thanks for the pointers!

> For operations it currently needs
> 
>     - establishing virtual memory areas and connecting to tracking it

That's the UFFDIO_REGISTER/UNREGISTER.

>     - changing pages protection
> 
>         PROT_NONE or absent                             - initially

absent is what works with -mm already. The lazy loading already works.

>         PROT_NONE       -> PROT_READ                    - after read

Current UFFDIO_COPY will map it using vma->vm_page_prot.

We'll need a new flag for UFFDIO_COPY to map it readonly. This is
already contemplated:

	/*
	 * There will be a wrprotection flag later that allows to map
	 * pages wrprotected on the fly. And such a flag will be
	 * available if the wrprotection ioctl are implemented for the
	 * range according to the uffdio_register.ioctls.
	 */
#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
	__u64 mode;

If the memory protection framework exists (either through the
uffdio_register.ioctl out value, or through uffdio_api.features
out-only value) you can pass a new flag (MODE_WP) above to transition
from "absent" to "PROT_READ".

>         PROT_READ       -> PROT_READWRITE               - after write

This will need to add UFFDIO_MPROTECT.

>         PROT_READWRITE  -> PROT_READ                    - after commit

UFFDIO_MPROTECT again (but harder if going from rw to ro, because of a
slight mess to solve with regard to FAULT_FLAG_TRIED, in case you want
to run this UFFDIO_MPROTECT without stopping the threads that are
accessing the memory concurrently).

And this should only work if the uffdio_register.mode had MODE_WP set,
so we don't run into the races created by COWs (gup vs fork race).

>         PROT_READWRITE  -> PROT_NONE or absent (again)  - after abort

UFFDIO_MPROTECT again, but you won't be able to read the page contents
inside the memory manager thread (the one working with
userfaultfd).

The manager at all times if forbidden to touch the memory it is
tracking with userfaultfd (if it does it'll deadlock, but kill -9 will
get rid of it). gdb ironically because it is using an underoptimized
access_process_vm wouldn't hang, because FAULT_FLAG_RETRY won't be set
in handle_userfault in the gdb context, and it'll just receive a
sigbus if by mistake the user tries to touch the memory. Even if it
will hung later as get_user_pages_locked|unlocked gets used there too,
kill -9 would solve gdb too.

Back to the problem of accessing the UFFDIO_MPROTECT(PROT_NONE)
memory: to do that a new ioctl should be required. I'd rather not go
back to the route of UFFDIO_REMAP, but it could copy the data using
the kernel address.

It could be simply a reverse UFFDIO_COPY. We could add a
UFFDIO_COPY_MODE_REVERSE flag to the "mode" of UFFDIO_COPY to mean
"read source from kernel address and write destination in user
address". By default it reads the source from user address and write
the destination in kernel address (to be atomic).

If you want to put data back before lifting the PROT_NONE, UFFDIO_COPY
could be used in the standard way but with a
UFFDIO_COPY_MODE_OVERWRITE flag that just overwrites the contents of
the old page if it's not mapped (protnone), or just get rid of the old
page (currently it'd return -EEXIST if the pte is not none).

So the process would be:

UFFDIO_COPY(dst_tmpaddr, src_addr, mode=REVERSE)
UFFDIO_COPY(src_addr, dst_tmpaddr, mode=OVERWRITE)

Then if you also set mode=READONLY in the last UFFDIO_COPY, it'll
create a wrprotected mapping atomically before giving visibility to
the new page contents:

UFFDIO_COPY(src_addr, dst_tmpaddr, mode=OVERWRITE|WP)

>         PROT_READ       -> PROT_NONE or absent (again)  - on reclaim

Same as above.

>     - working with aliasable memory (thus taken from tmpfs)
> 
>         there could be two overlapping-in-file mapping for file (array)
>         requested at different time, and changes from one mapping should
>         propagate to another one -> for common parts only 1 page should
>         be memory-mapped into 2 places in address-space.

Why isn't the manager thread taking care of calling UFFDIO_MPROTECT in
two places?

And UFFDIO_COPY would fill the page and replace the old page and the
effect would be visible as far as the "data" is concerned, but the
protection bits would be more naturally different for each
mapping, like a double mmap call is also required to map such an area
in two places.

You could have a MAP_PRIVATE vma with PROT_READ, you can't create a
writable pte into it, just because you called
UFFDIO_MPROTECT(PROT_READ|PROT_WRITE) in a different mapping of the
same tmpfs page.

NOTE: the availability of the UFFDIO_MPROTECT|COPY on tmpfs ares would
still depend on UFFDIO_REGISTER to return the respecteve ioctl id in
the uffdio_register.ioctl (out value of the register ioctl).

> so what is currently lacking on userfaultfd side is:
> 
>     - ability to remove / make PROT_NONE already mapped pages
>       (UFFDIO_REMAP was recently dropped)
> 
>     - ability to arbitrarily change pages protection (e.g. RW -> R)
> 
>     - inject aliasable memory from tmpfs (or better hugetlbfs) and into
>       several places (UFFDIO_REMAP + some mapping copy semantic).

I think UFFDIO_COPY if added with OVERWRITE|REVERSE|WP flags is an ok
substitute for UFFDIO_REMAP.

If UFFDIO_COPY sees the page is protnone during the REVERSE copy (to
extract the memory atomically), it can also skip the tlb flush (and
obviously there's no tlb flush in the reverse direction). If the page
was not protnone, it can turn it in protnone, do a tlb flush, and then
copy it to the destination address using the userland mapping.

UFFDIO_MPROTECT is definitely necessary for postcopy live snapshotting
too (the reverse UFFDIO_COPY is not, it never deals with
PROT_NONE and it never cares about missing faults).

MPROTECT(PROT_NONE) so far seems needed only by this and perhaps UML
(and perhaps qemu linux-user).

I posted in another email why these features aren't implemented yet 

==
There will be some complications in adding the wrprotection/protnone
feature: if faults could already happen when the wrprotect/protnone is
armed, the handle_userfault() could be invoked in a retry-fault, that
is not ok without allowing the userfault to return VM_FAULT_RETRY even
during a refault (i.e. FAULT_FLAG_TRIED set but FAULT_FLAG_ALLOW_RETRY
not set). The invariants of vma->vm_page_prot and pte/trans_huge_pmd
permissions must also not break anywhere. These are the two main
reasons why these features that requires to flip protection bits are
left implemented later and made visible later with uffdio_api.feature
flags and/or through uffdio_register.ioctl during UFFDIO_REGISTER.
==

> The performance currently is not great, partly because of page clearing
> when getting ram from tmpfs, and partly because of mprotect/SIGSEGV/vmas
> overhead and other dumb things on my side.

Also the page faults get slowed down when the rbtree grows a lot,
userfaultfd won't let the rbtree grow.

> I still wanted to show the case, as userfaultd here has potential to
> remove overhead related to kernel.

That's very useful and interesting feedback!

Could you review the API to be sure we don't have to modify it when we
extend it like described above?

1) tmpfs returning uffdio_register.ioctl |=
   UFFDIO_MPROTECT|UFFDIO_COPY when enabled

2) UFFDIO_MPROTECT(PROT_NONE|READ|WRITE|EXEC) and in turn
   UFFDIO_COPY_MODE_REVERSE|UFFDIO_COPY_MODE_OVERWRITE|UFFDIO_COPY_MODE_WP
   being available if uffdio_register.ioctl includes UFFDIO_MPROTECT
   (and uffdio_api.features will then include
   UFFD_FEATURE_PAGEFAULT_WP to signal the uffd_msg.pagefault.flag WP
   is available [bit 1], and UFFDIO_REGISTER_MODE_WP can be used in
   uffdio_register.mode)

All of it could just check for uffdio_api.features &
UFFD_FEATURE_PAGEFAULT_WP being set, but you'd still have to check for
UFFDIO_MPROTECT being set in uffdio_register.ioctl for tmpfs areas (or
to know it's not available yet on hugetlbfs), so I think it's more
robust to check UFFDIO_MPROTECT ioctl being set in
uffdio_register.ioctl to assume all mprotection and writeprotect
tracking features are available for that specific range. The feature
flag will just tell that UFFDIO_REGISTER_MODE_WP can be used in the
register ioctl, that is something you need to know before in order to
"arm" the VMA for wrprotect faults.

For your usage I think you probably want to set
UFFDIO_REGISTER_MODE_WP|UFFDIO_REGISTER_MODE_MISSING and you'll be
told through uffdio_msg.flags if it's a WP or MISSING fault. You won't
be told if it's missing because of PROT_NONE or absent.

On a side note: all of the above is completely orthognal from the
non-cooperative usage: as far as memory protection features it doesn't
need any, it just needs to track more events like fork/mremap to
adjust its offsets as the memory manager is not part of the app and it
has no way to orchestrate by other means.

Doing it all at once (non-cooperative + full memory protection) looked
too much. We should just try to get the API right in a way that won't
require an UFFD_API bump passed to uffdio_api.api. Even then, if an
api bump is required, that's not a big deal, until recently the
non-cooperative usage already did the API bumb but we accomodated the
read(2) API to avoid it.

Thinking at the worst case scenario, if the API gets bumped the only
thing that has to remain fixed is the ioctl number of the UFFDIO_API
and the uffdio_api structure. Everything else can be upgraded without
risk of ABI breakage, even the ioctl numbers can be reused (except the
very UFFDIO_API). When the non-cooperative usage bumped the API it
actually kept all ioctl the same except the read(2) format.

Comments welcome, thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
