Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66EAF6B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:54:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id u16-v6so13221528iol.18
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:54:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s18-v6sor3333012iog.127.2018.05.21.15.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 15:54:28 -0700 (PDT)
MIME-Version: 1.0
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com> <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com> <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com>
In-Reply-To: <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 15:54:16 -0700
Message-ID: <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
Subject: Re: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 3:48 PM Dave Hansen <dave.hansen@intel.com> wrote:

> On 05/21/2018 03:35 PM, Daniel Colascione wrote:
> >> I know folks use memfd to figure out
> >> how much memory pressure we are under.  I guess that would trigger when
> >> you consume lots of memory with VMAs.
> >
> > I think you're thinking of the VM pressure level special files, not
memfd,
> > which creates an anonymous tmpfs file.

> Yep, you're right.

> >> VMAs are probably the most similar to things like page tables that are
> >> kernel memory that can't be directly reclaimed, but do get freed at
> >> OOM-kill-time.  But, VMAs are a bit harder than page tables because
> >> freeing a page worth of VMAs does not necessarily free an entire page.
> >
> > I don't understand. We can reclaim memory used by VMAs by killing the
> > process or processes attached to the address space that owns those VMAs.
> > The OOM killer should Just Work. Why do we have to have some special
limit
> > of VMA count?

> The OOM killer doesn't take the VMA count into consideration as far as I
> remember.  I can't think of any reason why not except for the internal
> fragmentation problem.

> The current VMA limit is ~12MB of VMAs per process, which is quite a
> bit.  I think it would be reasonable to start considering that in OOM
> decisions, although it's surely inconsequential except on very small
> systems.

> There are also certainly denial-of-service concerns if you allow
> arbitrary numbers of VMAs.  The rbtree, for instance, is O(log(n)), but
> I 'd be willing to be there are plenty of things that fall over if you
> let the ~65k limit get 10x or 100x larger.

Sure. I'm receptive to the idea of having *some* VMA limit. I just think
it's unacceptable let deallocation routines fail.

What about the proposal at the end of my original message? If we account
for mapped address space by counting pages instead of counting VMAs, no
amount of VMA splitting can trip us over the threshold. We could just
impose a system-wide vsize limit in addition to RLIMIT_AS, with the
effective limit being the smaller of the two. (On further thought, we'd
probably want to leave the meaning of max_map_count unchanged and introduce
a new knob.)
