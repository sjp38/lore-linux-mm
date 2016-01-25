Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBE96B0009
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:53:02 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id 1so169183455ion.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 15:53:02 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id yr1si1692101igb.57.2016.01.25.15.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 15:53:01 -0800 (PST)
Received: by mail-io0-x22a.google.com with SMTP id q21so169613800iod.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 15:53:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160125231451.GA15513@node.shutemov.name>
References: <CAMbhsRTAeobrQAqujusAVpw+wZyr3WsdKd4iQPi62GWyLB3gJA@mail.gmail.com>
	<20160125231451.GA15513@node.shutemov.name>
Date: Mon, 25 Jan 2016 15:53:01 -0800
Message-ID: <CAMbhsRT-XsxkznXzygkdP2tmVr4Xgfi9TCQ2i66dqz8vGfJD3Q@mail.gmail.com>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Mon, Jan 25, 2016 at 3:14 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Mon, Jan 25, 2016 at 01:30:00PM -0800, Colin Cross wrote:
>> On Tue, Jan 19, 2016 at 3:30 PM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>> > On Tue, Jan 19, 2016 at 02:14:30PM -0800, Andrew Morton wrote:
>> >> On Tue, 19 Jan 2016 13:02:39 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
>> >>
>> >> > b764375 ("procfs: mark thread stack correctly in proc/<pid>/maps")
>> >> > added [stack:TID] annotation to /proc/<pid>/maps. Finding the task of
>> >> > a stack VMA requires walking the entire thread list, turning this into
>> >> > quadratic behavior: a thousand threads means a thousand stacks, so the
>> >> > rendering of /proc/<pid>/maps needs to look at a million threads. The
>> >> > cost is not in proportion to the usefulness as described in the patch.
>> >> >
>> >> > Drop the [stack:TID] annotation to make /proc/<pid>/maps (and
>> >> > /proc/<pid>/numa_maps) usable again for higher thread counts.
>> >> >
>> >> > The [stack] annotation inside /proc/<pid>/task/<tid>/maps is retained,
>> >> > as identifying the stack VMA there is an O(1) operation.
>> >>
>> >> Four years ago, ouch.
>> >>
>> >> Any thoughts on the obvious back-compatibility concerns?  ie, why did
>> >> Siddhesh implement this in the first place?  My bad for not ensuring
>> >> that the changelog told us this.
>> >>
>> >> https://lkml.org/lkml/2012/1/14/25 has more info:
>> >>
>> >> : Memory mmaped by glibc for a thread stack currently shows up as a
>> >> : simple anonymous map, which makes it difficult to differentiate between
>> >> : memory usage of the thread on stack and other dynamic allocation.
>> >> : Since glibc already uses MAP_STACK to request this mapping, the
>> >> : attached patch uses this flag to add additional VM_STACK_FLAGS to the
>> >> : resulting vma so that the mapping is treated as a stack and not any
>> >> : regular anonymous mapping.  Also, one may use vm_flags to decide if a
>> >> : vma is a stack.
>> >>
>> >> But even that doesn't really tell us what the actual *value* of the
>> >> patch is to end-users.
>> >
>> > I doubt it can be very useful as it's unreliable: if two stacks are
>> > allocated end-to-end (which is not good idea, but still) it can only
>> > report [stack:XXX] for the first one as they are merged into one VMA.
>> > Any other anon VMA merged with the stack will be also claimed as stack,
>> > which is not always correct.
>> >
>> > I think report the VMA as anon is the best we can know about it,
>> > everything else just rather expensive guesses.
>>
>> An alternative to guessing is the anonymous VMA naming patch used on
>> Android, https://lkml.org/lkml/2013/10/30/518.  It allows userspace to
>> name anonymous memory however it wishes, and prevents vma merging
>> adjacent regions with different names.  Android uses it to label
>> native heap memory, but it would work well for stacks too.
>
> I don't think preventing vma merging is fair price for the feature: you
> would pay extra in every find_vma() (meaning all page faults).
>
> I think it would be nice to have a way to store this kind of sideband info
> without impacting critical code path.
>
> One other use case I see for such sideband info is storing hits from
> MADV_HUGEPAGE/MADV_NOHUGEPAGE: need to split vma just for these hints is
> unfortunate.

In practice we don't see many extra VMAs from naming; alignment
requirements, guard pages, and permissions differences are usually
enough to keep adjacent anonymous VMAs from merging.  Here's an
example from a process on Android:
7f9086c000-7f9086d000 rw-p 00006000 fd:00 1495
  /system/lib64/libhardware_legacy.so
7f9086d000-7f9086e000 rw-p 00000000 00:00 0
7f9086e000-7f9086f000 rw-p 00000000 00:00 0
  [anon:linker_alloc]
7f90875000-7f90876000 r--p 00000000 00:00 0
  [anon:linker_alloc]
7f9087c000-7f9087d000 r--p 00000000 00:00 0
  [anon:linker_alloc]
7f90901000-7f90902000 ---p 00000000 00:00 0
  [anon:thread stack guard page]
7f90902000-7f90a00000 rw-p 00000000 00:00 0
  [stack:410]
7f90a00000-7f90c00000 rw-p 00000000 00:00 0
  [anon:libc_malloc]
7f90c02000-7f90c03000 ---p 00000000 00:00 0
  [anon:thread stack guard page]
7f90c03000-7f90d01000 rw-p 00000000 00:00 0
  [stack:409]
7f90d01000-7f90d02000 ---p 00000000 00:00 0
  [anon:thread stack guard page]
7f90d02000-7f90e00000 rw-p 00000000 00:00 0
  [stack:408]
7f90e00000-7f91200000 rw-p 00000000 00:00 0
  [anon:libc_malloc]
7f91206000-7f91207000 r--p 00000000 00:00 0
  [anon:linker_alloc]
7f91237000-7f91238000 ---p 00000000 00:00 0
  [anon:thread signal stack guard page]
7f91238000-7f9123c000 rw-p 00000000 00:00 0
  [anon:thread signal stack]
7f9123c000-7f9123d000 ---p 00000000 00:00 0
  [anon:thread signal stack guard page]
7f9123d000-7f91241000 rw-p 00000000 00:00 0
  [anon:thread signal stack]
7f91246000-7f91247000 ---p 00000000 00:00 0
  [anon:thread signal stack guard page]
7f91247000-7f9124b000 rw-p 00000000 00:00 0
  [anon:thread signal stack]
7f9124b000-7f9124c000 ---p 00000000 00:00 0
  [anon:thread signal stack guard page]
7f9124c000-7f91250000 rw-p 00000000 00:00 0
  [anon:thread signal stack]

I only see 2 extra VMAs here, the "[stack:410]" and "[stack:408]"
regions would have been merged with the following "[anon:libc_malloc]"
regions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
