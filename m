Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7E79A829BA
	for <linux-mm@kvack.org>; Fri, 22 May 2015 12:33:38 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so22797300wgb.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 09:33:37 -0700 (PDT)
Received: from mail2.tiolive.com (mail2.tiolive.com. [94.23.229.207])
        by mx.google.com with ESMTP id f18si4535613wjz.182.2015.05.22.09.33.36
        for <linux-mm@kvack.org>;
        Fri, 22 May 2015 09:33:36 -0700 (PDT)
Date: Fri, 22 May 2015 19:35:05 +0300
From: Kirill Smelkov <kirr@nexedi.com>
Subject: Re: [PATCH 00/23] userfaultfd v4
Message-ID: <20150522163503.GA6346@teco.navytux.spb.ru>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <20150521131111.GA8932@teco.navytux.spb.ru>
 <20150521155251.GB4643@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150521155251.GB4643@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hi Andrea,

On Thu, May 21, 2015 at 05:52:51PM +0200, Andrea Arcangeli wrote:
> Hi Kirill,
> 
> On Thu, May 21, 2015 at 04:11:11PM +0300, Kirill Smelkov wrote:
> > Sorry for maybe speaking up too late, but here is additional real
> 
> Not too late, in fact I don't think there's any change required for
> this at this stage, but it'd be great if you could help me to review.

Thanks


> > Since arrays can be large, it would be slow and thus not practical to
> [..]
> > So I've implemented a scheme where array data is initially PROT_READ
> > protected, then we catch SIGSEGV, if it is write and area belongs to array
> 
> In the case of postcopy live migration (for qemu and/or containers) and
> postcopy live snapshotting, splitting the vmas is not an option
> because we may run out of them.
> 
> If your PROT_READ areas are limited perhaps this isn't an issue but
> with hundreds GB guests (currently plenty in production) that needs to
> live migrate fully reliably and fast, the vmas could exceed the limit
> if we were to use mprotect. If your arrays are very large and the
> PROT_READ aren't limited, using userfaultfd this isn't only an
> optimization for you too, it's actually a must to avoid a potential
> -ENOMEM.

I understand. To somehow mitigate this issue for every array/file I try
to allocate ram pages from separate file on tmpfs with the same offset.
This way if we allocate a lot of pages and mmap them in with PROT_READ,
if they are adjacent to each other, the kernel will merge adjacent vmas
into one vma:

    https://lab.nexedi.cn/kirr/wendelin.core/blob/ca064f75/include/wendelin/bigfile/ram.h#L100
    https://lab.nexedi.cn/kirr/wendelin.core/blob/ca064f75/bigfile/ram_shmfs.c#L102
    https://lab.nexedi.cn/kirr/wendelin.core/blob/ca064f75/bigfile/virtmem.c#L435

I agree this is only a half-measure - file parts accessed could be
sparse, and also there is a in-shmfs overhead maintaining tables what
real pages are allocated to which part of file on shmfs.

So yes, if userfaultfd allows to overcomes vma layer and work directly
on page tables, this helps.


> > Also, since arrays could be large - bigger than RAM, and only sparse
> > parts of it could be needed to get needed information, for reading it
> > also makes sense to lazily load data in SIGSEGV handler with initial
> > PROT_NONE protection.
> 
> Similarly I heard somebody wrote a fastresume to load the suspended
> (on disk) guest ram using userfaultfd. That is a slightly less
> fundamental case than postcopy because you could do it also with
> MAP_SHARED, but it's still interesting in allowing to compress or
> decompress the suspended ram on the fly with lz4 for example,
> something MAP_PRIVATE/MAP_SHARED wouldn't do (plus there's the
> additional benefit of not having an orphaned inode left open even if
> the file is deleted, that prevents to unmount the filesystem for the
> whole lifetime of the guest).

I see. Just a note - transparent compression/decompression could be
achieved with MAP_SHARED if the compression is being performed by
underlying filesystem - e.g. implemented with FUSE.

( I have not measured performance though )


> > This is very similar to how memory mapped files work, but adds
> > transactionality which, as far as I know, is not provided by any
> > currently in-kernel filesystem on Linux.
> 
> That's another benefit yes.
> 
> > The gist of virtual memory-manager is this:
> > 
> >     https://lab.nexedi.cn/kirr/wendelin.core/blob/master/include/wendelin/bigfile/virtmem.h
> >     https://lab.nexedi.cn/kirr/wendelin.core/blob/master/bigfile/virtmem.c  (vma_on_pagefault)
> 
> I'll check it more in detail ASAP, thanks for the pointers!
> 
> > For operations it currently needs
> > 
> >     - establishing virtual memory areas and connecting to tracking it
> 
> That's the UFFDIO_REGISTER/UNREGISTER.

Yes

> >     - changing pages protection
> > 
> >         PROT_NONE or absent                             - initially
> 
> absent is what works with -mm already. The lazy loading already works.

Yes

> >         PROT_NONE       -> PROT_READ                    - after read
> 
> Current UFFDIO_COPY will map it using vma->vm_page_prot.
> 
> We'll need a new flag for UFFDIO_COPY to map it readonly. This is
> already contemplated:
> 
> 	/*
> 	 * There will be a wrprotection flag later that allows to map
> 	 * pages wrprotected on the fly. And such a flag will be
> 	 * available if the wrprotection ioctl are implemented for the
> 	 * range according to the uffdio_register.ioctls.
> 	 */
> #define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
> 	__u64 mode;
> 
> If the memory protection framework exists (either through the
> uffdio_register.ioctl out value, or through uffdio_api.features
> out-only value) you can pass a new flag (MODE_WP) above to transition
> from "absent" to "PROT_READ".

Yes. The same probably applies to UFFDIO_ZEROPAGE (to mmap-in zeropage
as RO on read, if that part of file is currently hole)

So we settle on adding

    UFFDIO_COPY_MODE_WP         and
    UFFDIO_ZEROPAGE_MODE_WP
?

Or maybe why we have both COPY_DONTWAKE and ZEROPAGE_DONTWAKE (and
previously REMAP_MODE_DONTWAKE) and now duplicate _MODE_WP to all them?

Maybe it makes sense to move those common flags related to waking up or
not, mmaping in as R or RW (and maybe other in the future) to common
place.


> >         PROT_READ       -> PROT_READWRITE               - after write
> 
> This will need to add UFFDIO_MPROTECT.

Yes

> >         PROT_READWRITE  -> PROT_READ                    - after commit
> 
> UFFDIO_MPROTECT again (but harder if going from rw to ro, because of a
> slight mess to solve with regard to FAULT_FLAG_TRIED, in case you want
> to run this UFFDIO_MPROTECT without stopping the threads that are
> accessing the memory concurrently).

Yes. I understand the race of a manager making pages RW -> R, and an
other thread in user process simultaneously making a write to the same
page.

On user-level this race can be solved this way: before commit, changed
pages are first marked as R and only then written to storage.

- If a write is racing with RW->R protection being made - it's a client
  problem (of having one thread still modifying data, and other thread
  triggering commit) - we are ok with committing what has already been
  written at the moment RW->R has happened.

- If a write happened after RW->R protection has been made (even if it
  is racy), we are ok if we get a proper notification to userfaultfd
  handler of write to WP area.

So if on kernel side the "slight mess" can be solved, userspace is ok to
live with the potential race and solve it itself.

> And this should only work if the uffdio_register.mode had MODE_WP set,
> so we don't run into the races created by COWs (gup vs fork race).

It is ok to start with registering with

    (UFFDIO_REGISTER_MODE_MISSING | UFFDIO_REGISTER_MODE_WP)

for whole area at the beginning. In other words we are asking
userfaultfd "we want to handle all kind of faults - both reads and writes"


> >         PROT_READWRITE  -> PROT_NONE or absent (again)  - after abort
> 
> UFFDIO_MPROTECT again,

My idea here is that on transaction abort, we just don't need that
changed memory - we can both forget the changes and free the appropriate
pages - if in next transaction someone will need the file data of that
same part again, it just reloads the usual way from file.

So it is maybe

    UFFDIO_MFREE            ( make pte absent, and free(*) referenced page
                              (*) free maybe = decrement its refcount )

what is needed here.

But for generality, I agree it make sense to have a way to just MPROTECT
with PROT_NONE without freeing the page.

> but you won't be able to read the page contents
> inside the memory manager thread (the one working with
> userfaultfd).

With PROT_NONE I see.

> The manager at all times if forbidden to touch the memory it is
> tracking with userfaultfd (if it does it'll deadlock, but kill -9 will
> get rid of it). gdb ironically because it is using an underoptimized
> access_process_vm wouldn't hang, because FAULT_FLAG_RETRY won't be set
> in handle_userfault in the gdb context, and it'll just receive a
> sigbus if by mistake the user tries to touch the memory. Even if it
> will hung later as get_user_pages_locked|unlocked gets used there too,
> kill -9 would solve gdb too.

Wait. I partly understand, because I have no much experience in mm. But
are you saying the manager cannot access the memory it tracks, if pages
even have PROT_READ or PROT_READWRITE protection, and we know they were
already loaded, e.g. they are not missing?

If yes, then for sure, there need to be a way to get the data back from
memory to manager to implement storing changes back.

And maybe for some cases it would make sense to first set just
protection to PROT_NONE so manager know the client cannot mess with the
data while it accesses it.


> Back to the problem of accessing the UFFDIO_MPROTECT(PROT_NONE)
> memory: to do that a new ioctl should be required. I'd rather not go
> back to the route of UFFDIO_REMAP, but it could copy the data using
> the kernel address.
> 
> It could be simply a reverse UFFDIO_COPY. We could add a
> UFFDIO_COPY_MODE_REVERSE flag to the "mode" of UFFDIO_COPY to mean
> "read source from kernel address and write destination in user
> address". By default it reads the source from user address and write
> the destination in kernel address (to be atomic).

Yes, with small clarification that "write to kernel address" is write to
"kernel address associated to address in destination mm"


> If you want to put data back before lifting the PROT_NONE, UFFDIO_COPY
> could be used in the standard way but with a
> UFFDIO_COPY_MODE_OVERWRITE flag that just overwrites the contents of
> the old page if it's not mapped (protnone), or just get rid of the old
> page (currently it'd return -EEXIST if the pte is not none).
> 
> So the process would be:
> 
> UFFDIO_COPY(dst_tmpaddr, src_addr, mode=REVERSE)
> UFFDIO_COPY(src_addr, dst_tmpaddr, mode=OVERWRITE)
> 
> Then if you also set mode=READONLY in the last UFFDIO_COPY, it'll
> create a wrprotected mapping atomically before giving visibility to
> the new page contents:
> 
> UFFDIO_COPY(src_addr, dst_tmpaddr, mode=OVERWRITE|WP)

I agree in general.

The only thing which confuses me a bit is the REVERSE flag and dst/src
being skipped. I would rather keep the src / dst ordering and in mode
have COPY_TO and COPY_FROM or have both UFFDIO_COPY_TO and
UFFDIO_COPY_FROM to clarify API.

But this is only a style and does not change semantics.


But I wonder though again - is it maybe possible to get managed memory
content (with PROT_READ or PROT_READWRITE) without copying?


> >         PROT_READ       -> PROT_NONE or absent (again)  - on reclaim
> 
> Same as above.

The same as above about abort applies to reclaim - we just need
to forget and free memory here - so UFFDIO_MFREE.


> >     - working with aliasable memory (thus taken from tmpfs)
> > 
> >         there could be two overlapping-in-file mapping for file (array)
> >         requested at different time, and changes from one mapping should
> >         propagate to another one -> for common parts only 1 page should
> >         be memory-mapped into 2 places in address-space.
> 
> Why isn't the manager thread taking care of calling UFFDIO_MPROTECT in
> two places?
>
> And UFFDIO_COPY would fill the page and replace the old page and the
> effect would be visible as far as the "data" is concerned, but the
> protection bits would be more naturally different for each
> mapping, like a double mmap call is also required to map such an area
> in two places.

Because if we have a write on one place, the manager will
write-unprotect it, and would not get notified on further writes to the
same area.

And I need further writes to be visible in other mappings instantly.
Here is simplified example:

    In [1]: from numpy import *
    In [2]: A = zeros(10)   # it simulates big array backed by manager

    In [3]: a = A[0:5]      # one part is mapped with start/stop = (0,5)
    
    # something unrelated is done in between

    In [4]: b = A[3:10]     # another part is mapped with start/stop = (3,10)

    # NOTE a and b overlaps in array/backing file.
    # but since we already allocated address-space for a and did other
    # things, address space beyond a could be already allocated, so we
    # cannot just extend it and make b referencing addresses starting at
    # a tail.
    
    In [5]: a
    Out[5]: array([ 0.,  0.,  0.,  0.,  0.])
    
    In [6]: b
    Out[6]: array([ 0.,  0.,  0.,  0.,  0.,  0.,  0.])
    
    In [7]: a[4] = 1    # first change to a; the manager removes WP
    
    In [8]: a
    Out[8]: array([ 0.,  0.,  0.,  0.,  1.])
    
    In [9]: b
    Out[9]: array([ 0.,  1.,  0.,  0.,  0.,  0.,  0.]) # propagated to b

    # write again - the manager does not get a WP fault, but the change have to
    # propagate again
    In [10]: a[4] = 2

    In [11]: a
    Out[11]: array([ 0.,  0.,  0.,  0.,  2.])
    
    In [12]: b
    Out[12]: array([ 0.,  2.,  0.,  0.,  0.,  0.,  0.])

so if we resolve fault for a[4], the exact page mapped in, should be
also eventually mapped into b[1].

> You could have a MAP_PRIVATE vma with PROT_READ, you can't create a
> writable pte into it, just because you called
> UFFDIO_MPROTECT(PROT_READ|PROT_WRITE) in a different mapping of the
> same tmpfs page.

I don't fully understand here, but I use MAP_SHARED so changes propagate
back to tmpfs file and are visible in other mappings.

https://lab.nexedi.cn/kirr/wendelin.core/blob/ca064f75/bigfile/ram_shmfs.c#L89

> NOTE: the availability of the UFFDIO_MPROTECT|COPY on tmpfs ares would
> still depend on UFFDIO_REGISTER to return the respecteve ioctl id in
> the uffdio_register.ioctl (out value of the register ioctl).

It is ok to check. But I'd like to note: here we mmap two overlapping
parts of a tmpfs file in two regions, and register both regions to
userfaultfd.


> > so what is currently lacking on userfaultfd side is:
> > 
> >     - ability to remove / make PROT_NONE already mapped pages
> >       (UFFDIO_REMAP was recently dropped)
> > 
> >     - ability to arbitrarily change pages protection (e.g. RW -> R)
> > 
> >     - inject aliasable memory from tmpfs (or better hugetlbfs) and into
> >       several places (UFFDIO_REMAP + some mapping copy semantic).
> 
> I think UFFDIO_COPY if added with OVERWRITE|REVERSE|WP flags is an ok
> substitute for UFFDIO_REMAP.
> 
> If UFFDIO_COPY sees the page is protnone during the REVERSE copy (to
> extract the memory atomically), it can also skip the tlb flush (and
> obviously there's no tlb flush in the reverse direction). If the page
> was not protnone, it can turn it in protnone, do a tlb flush, and then
> copy it to the destination address using the userland mapping.

We are also ok if the page is PROT_READ - in this case no need to do a
tlbflush - nothing can change to page while we are copying it - only we
have to care not to allow changing protection to PROT_READWRITE in the
process.

> UFFDIO_MPROTECT is definitely necessary for postcopy live snapshotting
> too (the reverse UFFDIO_COPY is not, it never deals with
> PROT_NONE and it never cares about missing faults).
> 
> MPROTECT(PROT_NONE) so far seems needed only by this and perhaps UML
> (and perhaps qemu linux-user).
> 
> I posted in another email why these features aren't implemented yet 
> 
> ==
> There will be some complications in adding the wrprotection/protnone
> feature: if faults could already happen when the wrprotect/protnone is
> armed, the handle_userfault() could be invoked in a retry-fault, that
> is not ok without allowing the userfault to return VM_FAULT_RETRY even
> during a refault (i.e. FAULT_FLAG_TRIED set but FAULT_FLAG_ALLOW_RETRY
> not set). The invariants of vma->vm_page_prot and pte/trans_huge_pmd
> permissions must also not break anywhere. These are the two main
> reasons why these features that requires to flip protection bits are
> left implemented later and made visible later with uffdio_api.feature
> flags and/or through uffdio_register.ioctl during UFFDIO_REGISTER.
> ==

I understand, maybe not in full details though. The changes would anyway
be needed to make userfaultfd capable of generic memory managing,
instead of populating it only in one way.

And as I noted above, besides UFFDIO_COPY(both direction, overwrite) and
UFFDIO_MPROTECT, UFFDIO_MFREE is also needed.

> > The performance currently is not great, partly because of page clearing
> > when getting ram from tmpfs, and partly because of mprotect/SIGSEGV/vmas
> > overhead and other dumb things on my side.
> 
> Also the page faults get slowed down when the rbtree grows a lot,
> userfaultfd won't let the rbtree grow.

Yes. This is the same as splitting or not vmas.

> > I still wanted to show the case, as userfaultd here has potential to
> > remove overhead related to kernel.
> 
> That's very useful and interesting feedback!
> 
> Could you review the API to be sure we don't have to modify it when we
> extend it like described above?
> 
> 1) tmpfs returning uffdio_register.ioctl |=
>    UFFDIO_MPROTECT|UFFDIO_COPY when enabled

and UFFDIO_MFREE with maybe ability to automatically punch hole of freed
memory (we need to return the memory to the system on reclaim, and
preferable on abort).


> 2) UFFDIO_MPROTECT(PROT_NONE|READ|WRITE|EXEC) and in turn
>    UFFDIO_COPY_MODE_REVERSE|UFFDIO_COPY_MODE_OVERWRITE|UFFDIO_COPY_MODE_WP
>    being available if uffdio_register.ioctl includes UFFDIO_MPROTECT

UFFDIO_MPROTECT -> UFFDIO_MPROTECT(PROT_NONE|READ|WRITE|EXEC) looks ok.

but imho various copy modes could be allowed besides mprotect - e.g. for
a manager to get back managed memory. Thus, maybe

    UFFDIO_COPY_MODE_REVERSE (or analogues) and UFFDIO_COPY_MODE_OVERWRITE

should be available for when just UFFDIO_COPY is set.


>From userspace point of view, it would be simpler to operate when all
those operations are always allowed though.

>    (and uffdio_api.features will then include
>    UFFD_FEATURE_PAGEFAULT_WP to signal the uffd_msg.pagefault.flag WP
>    is available [bit 1], and UFFDIO_REGISTER_MODE_WP can be used in
>    uffdio_register.mode)

Yes, though it is not fully represents the capability - e.g.
MPROTECT(PROT_NONE) should work too, so it should be maybe
UFFD_FEATURE_PAGEFAULT_PROTECT.

Again, from clients point of view it would be simpler if those features
are in base - e.g. they are always available.

> All of it could just check for uffdio_api.features &
> UFFD_FEATURE_PAGEFAULT_WP being set, but you'd still have to check for
> UFFDIO_MPROTECT being set in uffdio_register.ioctl for tmpfs areas (or
> to know it's not available yet on hugetlbfs), so I think it's more
> robust to check UFFDIO_MPROTECT ioctl being set in
> uffdio_register.ioctl to assume all mprotection and writeprotect
> tracking features are available for that specific range. The feature
> flag will just tell that UFFDIO_REGISTER_MODE_WP can be used in the
> register ioctl, that is something you need to know before in order to
> "arm" the VMA for wrprotect faults.

ok

> For your usage I think you probably want to set
> UFFDIO_REGISTER_MODE_WP|UFFDIO_REGISTER_MODE_MISSING and you'll be
> told through uffdio_msg.flags if it's a WP or MISSING fault.

ok

> You won't be told if it's missing because of PROT_NONE or absent.

looks like not good - to know whether a page is mapped there already or
not. Is it possible to distinguish this cases too?

> 
> On a side note: all of the above is completely orthognal from the
> non-cooperative usage: as far as memory protection features it doesn't
> need any, it just needs to track more events like fork/mremap to
> adjust its offsets as the memory manager is not part of the app and it
> has no way to orchestrate by other means.
> 
> Doing it all at once (non-cooperative + full memory protection) looked
> too much. We should just try to get the API right in a way that won't
> require an UFFD_API bump passed to uffdio_api.api. Even then, if an
> api bump is required, that's not a big deal, until recently the
> non-cooperative usage already did the API bumb but we accomodated the
> read(2) API to avoid it.
> 
> Thinking at the worst case scenario, if the API gets bumped the only
> thing that has to remain fixed is the ioctl number of the UFFDIO_API
> and the uffdio_api structure. Everything else can be upgraded without
> risk of ABI breakage, even the ioctl numbers can be reused (except the
> very UFFDIO_API). When the non-cooperative usage bumped the API it
> actually kept all ioctl the same except the read(2) format.

I agree we can change API / ABI with versioning, but it is better to try
to get it right from the beginning and not fixup with several api
versions on top.

Thanks for your comments and feedback,
Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
