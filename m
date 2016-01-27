Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id B14E86B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 00:23:36 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id is5so159677440obc.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 21:23:36 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id ba9si1460235obb.102.2016.01.26.21.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 21:23:35 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id is5so159677323obc.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 21:23:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160127041706.GP2948@linux.intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-4-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWuPa2SoUcMCtDiv1UDodNqKcQzsZV5PxQx5Xhb524f7w@mail.gmail.com> <20160127041706.GP2948@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 26 Jan 2016 21:22:35 -0800
Message-ID: <CALCETrV=Me4Z9RvGXcxcoVTz0q9L7L-jF6GN+HS6PJaA7F+fLQ@mail.gmail.com>
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

Sounds good.

On second reading, though, what ensures that the vm is
VM_WRITE|VM_SHARED?  If nothing else, some nice comments might help.

A WARN_ON_ONCE that the pgprot you're starting with is RO would be
nice if there's a generic way to do that.  Actually, having a generic
pgprot_writable could make this less ugly.

Also, this optimization could be generalized, albeit a bit slower, by
having handle_pte_fault check if the inserted pte is read-only for a
write fault and continuing down the function to the wp_page logic.
After all, returning back to the arch entry code and retrying the
fault the old fashioned way is both very slow and has an outcome
that's known in advance.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
