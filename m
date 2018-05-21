Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA526B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:35:37 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q8-v6so13173073ioh.7
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:35:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 102-v6sor7513342ioj.288.2018.05.21.15.35.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 15:35:36 -0700 (PDT)
MIME-Version: 1.0
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com> <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
In-Reply-To: <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 15:35:25 -0700
Message-ID: <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
Subject: Re: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 3:29 PM Dave Hansen <dave.hansen@intel.com> wrote:

> On 05/21/2018 03:20 PM, Daniel Colascione wrote:
> >> VMAs consume kernel memory and we can't reclaim them.  That's what it
> >> boils down to.
> > How is it different from memfd in that respect?

> I don't really know what you mean.

I should have been more clear. I meant, in general, that processes can
*already* ask the kernel to allocate memory on behalf of the process, and
sometimes this memory can't be reclaimed without an OOM kill. (You can swap
memfd/tmpfs contents, but for simplicity, imagine we're running without a
pagefile.)

> I know folks use memfd to figure out
> how much memory pressure we are under.  I guess that would trigger when
> you consume lots of memory with VMAs.

I think you're thinking of the VM pressure level special files, not memfd,
which creates an anonymous tmpfs file.

> VMAs are probably the most similar to things like page tables that are
> kernel memory that can't be directly reclaimed, but do get freed at
> OOM-kill-time.  But, VMAs are a bit harder than page tables because
> freeing a page worth of VMAs does not necessarily free an entire page.

I don't understand. We can reclaim memory used by VMAs by killing the
process or processes attached to the address space that owns those VMAs.
The OOM killer should Just Work. Why do we have to have some special limit
of VMA count?
