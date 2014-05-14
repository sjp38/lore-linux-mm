Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF026B003A
	for <linux-mm@kvack.org>; Wed, 14 May 2014 17:26:30 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id hy4so3249113vcb.39
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:26:30 -0700 (PDT)
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
        by mx.google.com with ESMTPS id x18si537168vcs.193.2014.05.14.14.26.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 14:26:29 -0700 (PDT)
Received: by mail-ve0-f179.google.com with SMTP id oy12so210186veb.10
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:26:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
References: <53739201.6080604@oracle.com> <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com> <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 May 2014 14:26:09 -0700
Message-ID: <CALCETrXpFd7c35A5uSDD4xprokmsRL-Zjz6pVOwOKB_EUn8tpQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Stefani Seibold <stefani@seibold.net>

On Wed, May 14, 2014 at 2:03 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 14 May 2014 16:41:45 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>
>> On 05/14/2014 04:23 PM, Andrew Morton wrote:
>> > On Wed, 14 May 2014 11:55:45 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>> >
>> >> Hi all,
>> >>
>> >> While fuzzing with trinity inside a KVM tools guest running the latest -next
>> >> kernel I've stumbled on the following spew:
>> >>
>> >> [ 1634.969408] BUG: unable to handle kernel NULL pointer dereference at           (null)
>> >> [ 1634.970538] IP: special_mapping_fault (mm/mmap.c:2961)
>> >> [ 1634.971420] PGD 3334fc067 PUD 3334cf067 PMD 0
>> >> [ 1634.972081] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> >> [ 1634.972913] Dumping ftrace buffer:
>> >> [ 1634.975493]    (ftrace buffer empty)
>> >> [ 1634.977470] Modules linked in:
>> >> [ 1634.977513] CPU: 6 PID: 29578 Comm: trinity-c269 Not tainted 3.15.0-rc5-next-20140513-sasha-00020-gebce144-dirty #461
>> >> [ 1634.977513] task: ffff880333158000 ti: ffff88033351e000 task.ti: ffff88033351e000
>> >> [ 1634.977513] RIP: special_mapping_fault (mm/mmap.c:2961)
>> >
>> > Somebody's gone and broken the x86 oops output.  It used to say
>> > "special_mapping_fault+0x30/0x120" but the offset info has now
>> > disappeared.  That was useful for guesstimating whereabouts in the
>> > function it died.
>>
>> I'm the one who "broke" the oops output, but I thought I'm helping people
>> read that output instead of making it harder...
>>
>> What happened before is that due to my rather complex .config, the offsets
>> didn't make sense to anyone who didn't build the kernel with my .config,
>> so I had to repeatedly send it out to folks who attempted to get basic
>> things like line numbers.
>>
>> > The line number isn't very useful as it's not possible (or at least,
>> > not convenient) for others to reliably reproduce your kernel.
>>
>> I don't understand that part. I'm usually stating in the beginning of my
>> mails that I run my testing on the latest -next kernel.
>
> Your "latest next kernel" apparently differes from mine ;( It would be
> useful if you could just quote the +/-5 lines, perhaps?
>
>
>> And indeed if
>> you look at today's -next, that line number would point to:
>>
>>         for (pages = vma->vm_private_data; pgoff && *pages; ++pages) <=== HERE
>>                 pgoff--;
>>
>> So I'm not sure how replacing the offset with line numbers is making things
>> worse? previously offsets were useless for people who tried to debug these
>> spews so that's why I switched it to line numbers in the first place.
>>
>> > <scrabbles with git for a while>
>> >
>> > : static int special_mapping_fault(struct vm_area_struct *vma,
>> > :                           struct vm_fault *vmf)
>> > : {
>> > :   pgoff_t pgoff;
>> > :   struct page **pages;
>> > :
>> > :   /*
>> > :    * special mappings have no vm_file, and in that case, the mm
>> > :    * uses vm_pgoff internally. So we have to subtract it from here.
>> > :    * We are allowed to do this because we are the mm; do not copy
>> > :    * this code into drivers!
>> > :    */
>> > :   pgoff = vmf->pgoff - vma->vm_pgoff;
>> > :
>> > :   for (pages = vma->vm_private_data; pgoff && *pages; ++pages)
>> > :           pgoff--;
>> > :
>> > :   if (*pages) {
>> > :           struct page *page = *pages;
>> > :           get_page(page);
>> > :           vmf->page = page;
>> > :           return 0;
>> > :   }
>> > :
>> > :   return VM_FAULT_SIGBUS;
>> > : }
>> >
>> > OK so it might be the "if (*pages)".  So vma->vm_private_data was NULL
>> > and pgoff was zero.  As usual, I can't imagine what race would cause
>> > that :(
>>
>> Yup, it's the *pages part in the 'for' loop above that. I did find the
>> following in the vdso code:
>>
>>         vma = _install_special_mapping(mm,
>>                                        addr + image->size,
>>                                        image->sym_end_mapping - image->size,
>>                                        VM_READ,
>>                                        NULL);
>>
>> Which installs a mapping with a NULL ptr for pages (if I understand that
>> correctly), but that code has been there for a while now.
>
> Well that's weird.  I don't see anything which permits that.  Maybe
> nobody faulted against that address before?
>
> It's unclear what that code's actually doing and nobody bothered
> commenting it of course.  Maybe it's installing a guard page?
>
> In my linux-next all that code got deleted by Andy's "x86, vdso:
> Reimplement vdso.so preparation in build-time C" anyway.  What kernel
> were you looking at?
>
> Andy, are you able to shed some light on why
> arch_setup_additional_pages() is (or was) passing a NULL into
> _install_special_mapping()?
>

Ugh.  I just moved that code; I didn't delete it.  In fact, I likely
made it worse by causing x86_64 to use it, too.

Oddly, this code worked when I tested it.  Do you know what Trinity
did to break it?  Did the PTEs get nuked due to memory pressure?

The intent is to use remap_pfn_range (a couple of lines below) to map
some kernel data into userspace read-only.  I think the right fix
would be to pass in the pages array directly but to modify
_install_special_mapping to clear VM_MAYWRITE.  The idea is that
ptrace and mprotect should *not* be usable to COW these pages:
userspace will shoot itself in the foot quite thoroughly if the pages
get COWed.  Additionally, one of those pages actually represents some
hardware registers, which almost certainly needs to be mapped UC.

IIRC on x86_32 there are two pages in there.  One is regular kernel
memory that has a struct page associated with it.  The other is the
HPET, which is a page of hardware registers that may not have a struct
page.

Can anyone who's less clueless than I am about how vmas work help?
Does this need to use its own vmops instead of the special mapping
stuff?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
