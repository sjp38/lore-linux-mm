Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECDD6B6F86
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 17:13:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id z20-v6so4927406iol.1
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 14:13:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3-v6sor117487itb.36.2018.09.04.14.13.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 14:13:41 -0700 (PDT)
MIME-Version: 1.0
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183339.4416.44582.stgit@localhost.localdomain> <47657613-688d-e701-4a30-39fbd92734ba@microsoft.com>
In-Reply-To: <47657613-688d-e701-4a30-39fbd92734ba@microsoft.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 4 Sep 2018 14:13:29 -0700
Message-ID: <CAKgT0Uf4xNkPLcDvcYMwVqxoENrBZhkLkh37nC8Qbn2varsX9w@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Move page struct poisoning from CONFIG_DEBUG_VM
 to CONFIG_DEBUG_VM_PGFLAGS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel.Tatashin@microsoft.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 4, 2018 at 1:07 PM Pasha Tatashin
<Pavel.Tatashin@microsoft.com> wrote:
>
> Hi Alexander,
>
> This is a wrong way to do it. memblock_virt_alloc_try_nid_raw() does not
> initialize allocated memory, and by setting memory to all ones in debug
> build we ensure that no callers rely on this function to return zeroed
> memory just by accident.

I get that, but setting this to all 1's is still just debugging code
and that is adding significant overhead.

> And, the accidents are frequent because most of the BIOSes and
> hypervisors zero memory for us. The exception is kexec reboot.
>
> So, the fact that page flags checks this pattern, does not mean that
> this is the only user. Memory that is returned by
> memblock_virt_alloc_try_nid_raw() is used for page table as well, and
> can be used in other places as well that don't want memblock to zero the
> memory for them for performance reasons.

The logic behind this statement is confusing. You are saying they
don't want memblock to zero the memory for performance reasons, yet
you are setting it to all 1's for debugging reasons? I get that it is
wrapped, but in my mind just using CONFIG_DEBUG_VM is too broad of a
brush. Especially with distros like Fedora enabling it by default.

> I am surprised that CONFIG_DEBUG_VM is used in production kernel, but if
> so perhaps a new CONFIG should be added: CONFIG_DEBUG_MEMBLOCK
>
> Thank you,
> Pavel

I don't know about production. I am running a Fedora kernel on my
development system and it has it enabled. It looks like it has been
that way for a while based on a FC20 Bugzilla
(https://bugzilla.redhat.com/show_bug.cgi?id=1074710). A quick look at
one of my CentOS systems shows that it doesn't have it set. I suspect
it will vary from distro to distro. I just know it spooked me when I
was stuck staring at a blank screen for three minutes when I was
booting a system with 12TB of memory since this delay can hit you
early in the boot.

I had considered adding a completely new CONFIG. The only thing is it
doesn't make much sense to have the logic setting the value to all 1's
without any logic to test for it. That is why I thought it made more
sense to just fold it into CONFIG_DEBUG_VM_PGFLAGS. I suppose I could
look at something like CONFIG_DEBUG_PAGE_INIT if we want to go that
route. I figure using something like MEMBLOCK probably wouldn't make
sense since this also impacts sparse section init.

Thanks.

- Alex
