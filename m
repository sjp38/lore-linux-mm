Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2B23E6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 17:21:44 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id r14so56329049oie.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:21:44 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id h185si16437334oic.78.2016.01.29.14.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 14:21:43 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id is5so75104241obc.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:21:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160128213302.GB4163@cmpxchg.org>
References: <20160127193958.GA31407@cmpxchg.org> <CALCETrVy_QzNyaCiOsdwDdgXAgdRmwXsdiyPz8R5h3xaNR00TQ@mail.gmail.com>
 <20160128213302.GB4163@cmpxchg.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 29 Jan 2016 14:21:23 -0800
Message-ID: <CALCETrVLf5LeAhAhrcYFYAK3yS+3vdyoE5oG-epFvpkab5UykA@mail.gmail.com>
Subject: Re: [PATCH] mm: do not let vdso pages into LRU rotation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jan 28, 2016 at 1:33 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Jan 27, 2016 at 12:32:16PM -0800, Andy Lutomirski wrote:
>> On Wed, Jan 27, 2016 at 11:39 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> > Could the VDSO be a VM_MIXEDMAP to keep the initial unmanaged pages
>> > out of the VM while allowing COW into regular anonymous pages?
>>
>> Probably.  What are its limitations?  We want ptrace to work on it,
>> and mprotect needs to work and allow COW.  access_process_vm should
>> probably work, too.
>
> Thanks, that's good to know.
>
> However, after looking at this a little longer, it appears this would
> need work in do_wp_page() to support non-page COW copying, then adding
> vm_ops->access and complicating ->fault in all VDSO implementations.
>
> And it looks like - at least theoretically - drivers can inject non-VM
> pages into the page tables as well (comment above insert_page())
>
> Given that this behavior has been around for a long time (the comment
> at the bottom of vm_normal_page is ancient), I'll probably go with a
> more conservative approach; add a comment to mark_page_accessed() and
> filter out non-VM pages in the function I'm going to call from it.

I just checked: in -tip, I'm creating a VM_PFNMAP (not VM_MIXEDMAP)
vma and faulting a RAM page (with struct page and all) in using
vm_insert_pfn.  Is that okay, or so I need to use VM_MIXEDMAP instead?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
