Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C14128E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:01:50 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u126-v6so12625881itb.0
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 13:01:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x129-v6sor1347971itb.29.2018.09.11.13.01.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 13:01:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234341.4068.26882.stgit@localhost.localdomain> <CAPcyv4j301Ma8D65oMzFo9-jVdwKGHzOVHb=7u9XaxACR5RAhg@mail.gmail.com>
In-Reply-To: <CAPcyv4j301Ma8D65oMzFo9-jVdwKGHzOVHb=7u9XaxACR5RAhg@mail.gmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 11 Sep 2018 13:01:37 -0700
Message-ID: <CAKgT0UddVdf=+SnfeZ2hL=a47YkjOa+r96xnghP8r1fQZ_1Ycw@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: Provide kernel parameter to allow disabling page
 init poisoning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, dave.jiang@intel.com, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, jglisse@redhat.com, Andrew Morton <akpm@linux-foundation.org>, logang@deltatee.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 11, 2018 at 9:50 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Mon, Sep 10, 2018 at 4:43 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
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
> >
> > In order to work around a kernel that might have CONFIG_DEBUG_VM enabled on
> > a system that has a large amount of memory I have added a new kernel
> > parameter named "page_init_poison" that can be set to "off" in order to
> > disable it.
>
> In anticipation of potentially more DEBUG_VM options wanting runtime
> control I'd propose creating a new "vm_debug=" option for this modeled
> after "slub_debug=" along with a CONFIG_DEBUG_VM_ON to turn on all
> options.
>
> That way there is more differentiation for debug cases like this that
> have significant performance impact when enabled.
>
> CONFIG_DEBUG_VM leaves optional debug capabilities disabled by default
> unless CONFIG_DEBUG_VM_ON is also set.

Based on earlier discussions I would assume that CONFIG_DEBUG_VM would
imply CONFIG_DEBUG_VM_ON anyway since we don't want most of these
disabled by default.

In my mind we should be looking at a selective "vm_debug_disable="
instead of something that would be turning on features.

- Alex
