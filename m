Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 437556B73D1
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 11:32:19 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s15-v6so7400884iob.11
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 08:32:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 191-v6sor975126iou.248.2018.09.05.08.32.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 08:32:18 -0700 (PDT)
MIME-Version: 1.0
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183339.4416.44582.stgit@localhost.localdomain> <20180905061044.GT14951@dhcp22.suse.cz>
In-Reply-To: <20180905061044.GT14951@dhcp22.suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 5 Sep 2018 08:32:05 -0700
Message-ID: <CAKgT0Uc3vV_knsA6rcbD2m02--+QGVZA=_=mJnTyB8b+xpUCAw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Move page struct poisoning from CONFIG_DEBUG_VM
 to CONFIG_DEBUG_VM_PGFLAGS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, pavel.tatashin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 4, 2018 at 11:10 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 04-09-18 11:33:39, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> >
> > On systems with a large amount of memory it can take a significant amount
> > of time to initialize all of the page structs with the PAGE_POISON_PATTERN
> > value. I have seen it take over 2 minutes to initialize a system with
> > over 12GB of RAM.
> >
> > In order to work around the issue I had to disable CONFIG_DEBUG_VM and then
> > the boot time returned to something much more reasonable as the
> > arch_add_memory call completed in milliseconds versus seconds. However in
> > doing that I had to disable all of the other VM debugging on the system.
>
> I agree that CONFIG_DEBUG_VM is a big hammer but the primary point of
> this check is to catch uninitialized struct pages after the early mem
> init rework so the intention was to make it enabled on as many systems
> with debugging enabled as possible. DEBUG_VM is not free already so it
> sounded like a good idea to sneak it there.
>
> > I did a bit of research and it seems like the only function that checks
> > for this poison value is the PagePoisoned function, and it is only called
> > in two spots. One is the PF_POISONED_CHECK macro that is only in use when
> > CONFIG_DEBUG_VM_PGFLAGS is defined, and the other is as a part of the
> > __dump_page function which is using the check to prevent a recursive
> > failure in the event of discovering a poisoned page.
>
> Hmm, I have missed the dependency on CONFIG_DEBUG_VM_PGFLAGS when
> reviewing the patch. My debugging kernel config doesn't have it enabled
> for example. I know that Fedora configs have CONFIG_DEBUG_VM enabled
> but I cannot find their config right now to double check for the
> CONFIG_DEBUG_VM_PGFLAGS right now.
>
> I am not really sure this dependency was intentional but I strongly
> suspect Pavel really wanted to have it DEBUG_VM scoped.

So I think the idea as per the earlier discussion with Pavel is that
by preloading it with all 1's anything that is expecting all 0's will
blow up one way or another. We just aren't explicitly checking for the
value, but it is still possibly going to be discovered via something
like a GPF when we try to access an invalid pointer or counter.

What I think I can do to address some of the concern is make this
something that depends on CONFIG_DEBUG_VM and defaults to Y. That way
for systems that are defaulting their config they should maintain the
same behavior, however for those systems that are running a large
amount of memory they can optionally turn off
CONFIG_DEBUG_VM_PAGE_INIT_POISON instead of having to switch off all
the virtual memory debugging via CONFIG_DEBUG_VM. I guess it would
become more of a peer to CONFIG_DEBUG_VM_PGFLAGS as the poison check
wouldn't really apply after init anyway.

- Alex
