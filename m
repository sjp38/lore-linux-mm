Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4A46B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:02:19 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id is5so160210729obc.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 22:02:19 -0800 (PST)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id i62si3940145oib.73.2016.01.26.22.02.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 22:02:18 -0800 (PST)
Received: by mail-ob0-x234.google.com with SMTP id ba1so161827985obb.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 22:02:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160127041706.GP2948@linux.intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-4-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWuPa2SoUcMCtDiv1UDodNqKcQzsZV5PxQx5Xhb524f7w@mail.gmail.com> <20160127041706.GP2948@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 26 Jan 2016 22:01:08 -0800
Message-ID: <CALCETrXdCWtsLxhx_DqNPEma4mo71iTXF-FTVzSOfD9HDaiqhg@mail.gmail.com>
Subject: Re: [PATCH 3/3] dax: Handle write faults more efficiently
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 26, 2016 at 8:17 PM, Matthew Wilcox <willy@linux.intel.com> wrote:
> On Mon, Jan 25, 2016 at 09:38:19AM -0800, Andy Lutomirski wrote:
>> On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
>> <matthew.r.wilcox@intel.com> wrote:
>> > From: Matthew Wilcox <willy@linux.intel.com>
>> >
>> > When we handle a write-fault on a DAX mapping, we currently insert a
>> > read-only mapping and then take the page fault again to convert it to
>> > a writable mapping.  This is necessary for the case where we cover a
>> > hole with a read-only zero page, but when we have a data block already
>> > allocated, it is inefficient.
>> >
>> > Use the recently added vmf_insert_pfn_prot() to insert a writable mapping,
>> > even though the default VM flags say to use a read-only mapping.
>>
>> Conceptually, I like this.  Do you need to make sure to do all the
>> do_wp_page work, though?  (E.g. we currently update mtime in there.
>> Some day I'll fix that, but it'll be replaced with a set_bit to force
>> a deferred mtime update.)
>
> We update mtime in the ->fault handler of filesystems which support DAX
> like this:
>
>         if (vmf->flags & FAULT_FLAG_WRITE) {
>                 sb_start_pagefault(inode->i_sb);
>                 file_update_time(vma->vm_file);
>         }
>
> so I think we're covered.

A question that came up on IRC: if the page is a reflinked page on XFS
(whenever that feature lands), then presumably XFS has real work to do
in page_mkwrite.  If so, what ensures that page_mkwrite gets called?

As a half-baked alternative to this patch, there's a generic
optimization for this case.  do_shared_fault normally calls
do_page_mkwrite and installs the resulting page with the writable bit
set.  But if __do_fault returns VM_FAULT_NOPAGE, then this
optimization is skipped.  Could be add VM_FAULT_NOPAGE_READONLY (or
VM_FAULT_NOPAGE | VM_FAULT_READONLY) as a hint that a page was
installed but that it was installed readonly?  If we did that, then
do_shared_fault could check that bit and go through the wp_page logic
rather than returning to userspace.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
