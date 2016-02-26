Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 381E36B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:46:26 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id dm2so78965314obb.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:46:26 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id fx6si11400597obb.56.2016.02.26.06.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 06:46:25 -0800 (PST)
Received: by mail-ob0-x233.google.com with SMTP id ts10so79831902obc.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:46:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160226103742.GC22450@node.shutemov.name>
References: <20160223154950.GA22449@node.shutemov.name>
	<20160223180609.GC23289@redhat.com>
	<20160223183832.GB21820@node.shutemov.name>
	<20160223192835.GJ9157@redhat.com>
	<CAA9_cmcoVs=bM5Q+=tGEBFoA-OG9A50NiM2vz+mXBkCtu0jm-A@mail.gmail.com>
	<20160226103742.GC22450@node.shutemov.name>
Date: Fri, 26 Feb 2016 06:46:24 -0800
Message-ID: <CAPcyv4jpjkpNGxwq4=6zS9qZ4g04PaPRofy8STRw2o68ar17gg@mail.gmail.com>
Subject: Re: THP race?
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>

On Fri, Feb 26, 2016 at 2:37 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Thu, Feb 25, 2016 at 10:45:05AM -0800, Dan Williams wrote:
>> On Tue, Feb 23, 2016 at 11:28 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>> > On Tue, Feb 23, 2016 at 09:38:32PM +0300, Kirill A. Shutemov wrote:
>> >> pmd_trans_unstable(pmd), otherwise looks good:
>> >
>> > Yes sorry.
>> >
>> >> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> >
>> > Thanks for the quick ack, I just noticed or I would have added it to
>> > the resubmit, but it can be still added to -mm.
>> >
>> >> BTW, I guess DAX would need to introduce the same infrastructure for
>> >> pmd_devmap(). Dan?
>> >
>> > There is a i_mmap_lock_write in the truncate path that saves the day
>> > for the pmd zapping in the truncate() case without mmap_sem (the only
>> > case anon THP doesn't need to care about as truncate isn't possible in
>> > the anon case), but not in the MADV_DONTNEED madvise case that runs
>> > only with the mmap_sem for reading.
>> >
>> > The only objective of this "infrastructure" is to add no pmd_lock()ing
>> > overhead to the page fault, if the mapping is already established but
>> > not huge, and we've just to walk through the pmd to reach the
>> > pte. All because MADV_DONTNEED is running with the mmap_sem for
>> > reading unlike munmap and other slower syscalls that are forced to
>> > mangle the vmas and have to take the mmap_sem for writing regardless.
>> >
>> > The question for DAX is if it should do a pmd_devmap check inside
>> > pmd_none_or_trans_huge_or_clear_bad() after pmd_trans_huge() and get
>> > away with a one liner, or add its own infrastructure with
>> > pmd_devmap_unstable(). In the pmd_devmap case the problem isn't just
>> > in __handle_mm_fault. If it could share the same infrastructure it'd
>> > be ideal.
>> >
>>
>> Yes, I see no reason why we can't/shoudn't move the pmd_devmap() check
>> inside pmd_none_or_trans_huge_or_clear_bad().
>
> Are you going take care about this?

Sure, I thought there was time to still fold this in to Andrea's
patch?  Otherwise yes, I'll send a patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
