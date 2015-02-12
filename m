Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2E56B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:42:22 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id u14so9560682lbd.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 05:42:21 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id h4si2994314lag.70.2015.02.12.05.42.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 05:42:20 -0800 (PST)
Received: by mail-lb0-f177.google.com with SMTP id z11so9539108lbi.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 05:42:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211122224.GA9769@node.dhcp.inet.fi>
References: <549832E2.8060609@oracle.com>
	<20141222180102.GA8072@node.dhcp.inet.fi>
	<54985D59.5010506@oracle.com>
	<20141222191452.GA20295@node.dhcp.inet.fi>
	<CALYGNiO8-RqqY2gLGeoXvPkbKJabERHfaVLTaUp5s_=-WFR9KA@mail.gmail.com>
	<20150211122224.GA9769@node.dhcp.inet.fi>
Date: Thu, 12 Feb 2015 17:42:19 +0400
Message-ID: <CALYGNiN8kb4M8Xh-78-SxZyC5nMkggA2tLVcoLTw5dqC2C0RyQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in unlink_file_vma
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, Davidlohr Bueso <dave@stgolabs.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Feb 11, 2015 at 3:22 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Tue, Feb 10, 2015 at 10:42:31PM +0400, Konstantin Khlebnikov wrote:
>> On Mon, Dec 22, 2014 at 10:14 PM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>> > On Mon, Dec 22, 2014 at 01:05:13PM -0500, Sasha Levin wrote:
>> >> On 12/22/2014 01:01 PM, Kirill A. Shutemov wrote:
>> >> > On Mon, Dec 22, 2014 at 10:04:02AM -0500, Sasha Levin wrote:
>> >> >> > Hi all,
>> >> >> >
>> >> >> > While fuzzing with trinity inside a KVM tools guest running the latest -next
>> >> >> > kernel, I've stumbled on the following spew:
>> >> >> >
>> >> >> > [  432.376425] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
>> >> >> > [  432.378876] IP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
>> >> > Looks like vma->vm_file->mapping is NULL. Somebody freed ->vm_file from
>> >> > under us?
>> >> >
>> >> > I suspect Davidlohr's patchset on i_mmap_lock, but I cannot find any code
>> >> > path which could lead to the crash.
>> >>
>> >> I've reported a different issue which that patchset: https://lkml.org/lkml/2014/12/9/741
>> >>
>> >> I guess it could be related?
>> >
>> > Maybe.
>> >
>> > Other thing:
>> >
>> >  unmap_mapping_range()
>> >    i_mmap_lock_read(mapping);
>> >    unmap_mapping_range_tree()
>> >      unmap_mapping_range_vma()
>> >        zap_page_range_single()
>> >          unmap_single_vma()
>> >            untrack_pfn()
>> >              vma->vm_flags &= ~VM_PAT;
>> >
>> > It seems we modify ->vm_flags without mmap_sem taken, means we can corrupt
>> > them.
>> >
>> > Sasha could you check if you hit untrack_pfn()?
>> >
>> > The problem probably was hidden by exclusive i_mmap_lock on
>> > unmap_mapping_range(), but it's not exclusive anymore afrer Dave's
>> > patchset.
>> >
>> > Konstantin, you've modified untrack_pfn() back in 2012 to change
>> > ->vm_flags. Any coments?
>>
>> Hmm. I don't really understand how
>> unmap_mapping_range() could be used for VM_PFNMAP mappings
>> except unmap() or exit_mmap() where mm is locked anyway.
>> Somebody truncates memory mapped device and unmaps mapped PFNs?
>
> Hm. Probably not. But it's not obvious to me what would stop this.
> Should we at least have assert on mmap_sem locked in untrack_pfn()?

exit_mmap() runs without mmap_sem thus this should be something like thus:
WARN_ON_ONCE(atomic_read(&mm->mm_users) && !rwsem_is_locked(&mm->mmap_sem));

Clearing VM_MAYSHARE in __unmap_hugepage_range_final() has the same problem,
it's called from unmap_single_vma() as well as untrack_pfn().

Also clear_soft_dirty_pmd() clears VM_SOFTDIRTY under mmap_sem  locked for read.

>
>> If it's a problem then I think VM_PAT could be tuned into hint which
>> means PAT tracking was here and we pat should check internal structure
>> for details and take actions if pat tracking is still here. As I see
>> pat tracking probably also have problems if somebody unmaps that vma
>> partially.
>
> IIUC, we only mark a vma with VM_PAT if whole vma is subject for
> remap_pfn_range(). I don't see a point in cleaning VM_PAT -- just let it
> die with vma. Or do I miss something?

Yep, for now track/untrack works only for whole vma and cannot handle
vma split or partial munmap.

>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
