Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B850C6B7713
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 01:38:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h4-v6so3259991ede.5
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 22:38:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u28-v6si5007826edd.23.2018.09.05.22.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 22:38:09 -0700 (PDT)
Date: Thu, 6 Sep 2018 07:38:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: Move page struct poisoning from CONFIG_DEBUG_VM
 to CONFIG_DEBUG_VM_PGFLAGS
Message-ID: <20180906053807.GH14951@dhcp22.suse.cz>
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183339.4416.44582.stgit@localhost.localdomain>
 <20180905061044.GT14951@dhcp22.suse.cz>
 <CAKgT0Uc3vV_knsA6rcbD2m02--+QGVZA=_=mJnTyB8b+xpUCAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Uc3vV_knsA6rcbD2m02--+QGVZA=_=mJnTyB8b+xpUCAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, pavel.tatashin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 05-09-18 08:32:05, Alexander Duyck wrote:
> On Tue, Sep 4, 2018 at 11:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 04-09-18 11:33:39, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > >
> > > On systems with a large amount of memory it can take a significant amount
> > > of time to initialize all of the page structs with the PAGE_POISON_PATTERN
> > > value. I have seen it take over 2 minutes to initialize a system with
> > > over 12GB of RAM.
> > >
> > > In order to work around the issue I had to disable CONFIG_DEBUG_VM and then
> > > the boot time returned to something much more reasonable as the
> > > arch_add_memory call completed in milliseconds versus seconds. However in
> > > doing that I had to disable all of the other VM debugging on the system.
> >
> > I agree that CONFIG_DEBUG_VM is a big hammer but the primary point of
> > this check is to catch uninitialized struct pages after the early mem
> > init rework so the intention was to make it enabled on as many systems
> > with debugging enabled as possible. DEBUG_VM is not free already so it
> > sounded like a good idea to sneak it there.
> >
> > > I did a bit of research and it seems like the only function that checks
> > > for this poison value is the PagePoisoned function, and it is only called
> > > in two spots. One is the PF_POISONED_CHECK macro that is only in use when
> > > CONFIG_DEBUG_VM_PGFLAGS is defined, and the other is as a part of the
> > > __dump_page function which is using the check to prevent a recursive
> > > failure in the event of discovering a poisoned page.
> >
> > Hmm, I have missed the dependency on CONFIG_DEBUG_VM_PGFLAGS when
> > reviewing the patch. My debugging kernel config doesn't have it enabled
> > for example. I know that Fedora configs have CONFIG_DEBUG_VM enabled
> > but I cannot find their config right now to double check for the
> > CONFIG_DEBUG_VM_PGFLAGS right now.
> >
> > I am not really sure this dependency was intentional but I strongly
> > suspect Pavel really wanted to have it DEBUG_VM scoped.
> 
> So I think the idea as per the earlier discussion with Pavel is that
> by preloading it with all 1's anything that is expecting all 0's will
> blow up one way or another. We just aren't explicitly checking for the
> value, but it is still possibly going to be discovered via something
> like a GPF when we try to access an invalid pointer or counter.
> 
> What I think I can do to address some of the concern is make this
> something that depends on CONFIG_DEBUG_VM and defaults to Y. That way
> for systems that are defaulting their config they should maintain the
> same behavior, however for those systems that are running a large
> amount of memory they can optionally turn off
> CONFIG_DEBUG_VM_PAGE_INIT_POISON instead of having to switch off all
> the virtual memory debugging via CONFIG_DEBUG_VM. I guess it would
> become more of a peer to CONFIG_DEBUG_VM_PGFLAGS as the poison check
> wouldn't really apply after init anyway.

So the most obvious question is, why don't you simply disable DEBUG_VM?
It is not aimed at production workloads because it adds asserts at many
places and it is quite likely to come up with performance penalty
already.

Besides that, Initializing memory to all ones is not much different to
initializing it to all zeroes which we have been doing until recently
when Pavel has removed that. So why do we need to add yet another
debugging config option. We have way too many of config options already.
-- 
Michal Hocko
SUSE Labs
