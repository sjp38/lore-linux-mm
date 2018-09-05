Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDE86B719D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 02:10:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b4-v6so2159700ede.4
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 23:10:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6-v6si1122530edd.279.2018.09.04.23.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 23:10:47 -0700 (PDT)
Date: Wed, 5 Sep 2018 08:10:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: Move page struct poisoning from CONFIG_DEBUG_VM
 to CONFIG_DEBUG_VM_PGFLAGS
Message-ID: <20180905061044.GT14951@dhcp22.suse.cz>
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183339.4416.44582.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904183339.4416.44582.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Tue 04-09-18 11:33:39, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> On systems with a large amount of memory it can take a significant amount
> of time to initialize all of the page structs with the PAGE_POISON_PATTERN
> value. I have seen it take over 2 minutes to initialize a system with
> over 12GB of RAM.
> 
> In order to work around the issue I had to disable CONFIG_DEBUG_VM and then
> the boot time returned to something much more reasonable as the
> arch_add_memory call completed in milliseconds versus seconds. However in
> doing that I had to disable all of the other VM debugging on the system.

I agree that CONFIG_DEBUG_VM is a big hammer but the primary point of
this check is to catch uninitialized struct pages after the early mem
init rework so the intention was to make it enabled on as many systems
with debugging enabled as possible. DEBUG_VM is not free already so it
sounded like a good idea to sneak it there.

> I did a bit of research and it seems like the only function that checks
> for this poison value is the PagePoisoned function, and it is only called
> in two spots. One is the PF_POISONED_CHECK macro that is only in use when
> CONFIG_DEBUG_VM_PGFLAGS is defined, and the other is as a part of the
> __dump_page function which is using the check to prevent a recursive
> failure in the event of discovering a poisoned page.

Hmm, I have missed the dependency on CONFIG_DEBUG_VM_PGFLAGS when
reviewing the patch. My debugging kernel config doesn't have it enabled
for example. I know that Fedora configs have CONFIG_DEBUG_VM enabled
but I cannot find their config right now to double check for the
CONFIG_DEBUG_VM_PGFLAGS right now.

I am not really sure this dependency was intentional but I strongly
suspect Pavel really wanted to have it DEBUG_VM scoped. 
-- 
Michal Hocko
SUSE Labs
