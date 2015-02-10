Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id EA0E86B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 13:42:33 -0500 (EST)
Received: by labhv19 with SMTP id hv19so22084629lab.10
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 10:42:33 -0800 (PST)
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com. [209.85.215.50])
        by mx.google.com with ESMTPS id uf5si12650209lac.82.2015.02.10.10.42.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 10:42:32 -0800 (PST)
Received: by labgd6 with SMTP id gd6so13157808lab.7
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 10:42:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141222191452.GA20295@node.dhcp.inet.fi>
References: <549832E2.8060609@oracle.com>
	<20141222180102.GA8072@node.dhcp.inet.fi>
	<54985D59.5010506@oracle.com>
	<20141222191452.GA20295@node.dhcp.inet.fi>
Date: Tue, 10 Feb 2015 22:42:31 +0400
Message-ID: <CALYGNiO8-RqqY2gLGeoXvPkbKJabERHfaVLTaUp5s_=-WFR9KA@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in unlink_file_vma
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, Davidlohr Bueso <dave@stgolabs.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Dec 22, 2014 at 10:14 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Mon, Dec 22, 2014 at 01:05:13PM -0500, Sasha Levin wrote:
>> On 12/22/2014 01:01 PM, Kirill A. Shutemov wrote:
>> > On Mon, Dec 22, 2014 at 10:04:02AM -0500, Sasha Levin wrote:
>> >> > Hi all,
>> >> >
>> >> > While fuzzing with trinity inside a KVM tools guest running the latest -next
>> >> > kernel, I've stumbled on the following spew:
>> >> >
>> >> > [  432.376425] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
>> >> > [  432.378876] IP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
>> > Looks like vma->vm_file->mapping is NULL. Somebody freed ->vm_file from
>> > under us?
>> >
>> > I suspect Davidlohr's patchset on i_mmap_lock, but I cannot find any code
>> > path which could lead to the crash.
>>
>> I've reported a different issue which that patchset: https://lkml.org/lkml/2014/12/9/741
>>
>> I guess it could be related?
>
> Maybe.
>
> Other thing:
>
>  unmap_mapping_range()
>    i_mmap_lock_read(mapping);
>    unmap_mapping_range_tree()
>      unmap_mapping_range_vma()
>        zap_page_range_single()
>          unmap_single_vma()
>            untrack_pfn()
>              vma->vm_flags &= ~VM_PAT;
>
> It seems we modify ->vm_flags without mmap_sem taken, means we can corrupt
> them.
>
> Sasha could you check if you hit untrack_pfn()?
>
> The problem probably was hidden by exclusive i_mmap_lock on
> unmap_mapping_range(), but it's not exclusive anymore afrer Dave's
> patchset.
>
> Konstantin, you've modified untrack_pfn() back in 2012 to change
> ->vm_flags. Any coments?

Hmm. I don't really understand how
unmap_mapping_range() could be used for VM_PFNMAP mappings
except unmap() or exit_mmap() where mm is locked anyway.
Somebody truncates memory mapped device and unmaps mapped PFNs?

If it's a problem then I think VM_PAT could be tuned into hint which
means PAT tracking was here and we pat should check internal structure
for details and take actions if pat tracking is still here. As I see
pat tracking probably also have problems if somebody unmaps that vma
partially.

>
> For now, I would propose to revert the commit and probably re-introduce it
> after v3.19:
>
> From 14392c69fcfeeda34eb9f75d983dad32698cdd5c Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 22 Dec 2014 21:01:54 +0200
> Subject: [PATCH] Revert "mm/memory.c: share the i_mmap_rwsem"
>
> This reverts commit c8475d144abb1e62958cc5ec281d2a9e161c1946.
>
> There are several[1][2] of bug reports which points to this commit as potential
> cause[3].
>
> Let's revert it until we figure out what's going on.
>
> [1] https://lkml.org/lkml/2014/11/14/342
> [2] https://lkml.org/lkml/2014/12/22/213
> [3] https://lkml.org/lkml/2014/12/9/741
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> Cc: Mel Gorman <mgorman@suse.de>
> ---
>  mm/memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 649e7d440bd7..ca920d1fd314 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2378,12 +2378,12 @@ void unmap_mapping_range(struct address_space *mapping,
>                 details.last_index = ULONG_MAX;
>
>
> -       i_mmap_lock_read(mapping);
> +       i_mmap_lock_write(mapping);

Probably we could enable read-lock for "good" mappings, for example:

if (mapping->a_ops->error_remove_page == generic_error_remove_page)
     i_mmap_lock_read(mapping);
else
     i_mmap_lock_write(mapping);

=)

>         if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
>                 unmap_mapping_range_tree(&mapping->i_mmap, &details);
>         if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
>                 unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
> -       i_mmap_unlock_read(mapping);
> +       i_mmap_unlock_write(mapping);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
