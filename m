Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0E6C6B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 17:19:44 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k15so2177078otd.20
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 14:19:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k130-v6sor10937169oia.72.2018.10.09.14.19.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 14:19:43 -0700 (PDT)
MIME-Version: 1.0
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain> <20181009170051.GA40606@tiger-server>
 <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com> <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
In-Reply-To: <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 9 Oct 2018 14:19:32 -0700
Message-ID: <CAPcyv4gZV_V=iY0mHiiAWwbynqtPxLTwdZ0j0vQ0F95ZZ4nTZg@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Oct 9, 2018 at 1:34 PM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> On 10/9/2018 11:04 AM, Dan Williams wrote:
> > On Tue, Oct 9, 2018 at 3:21 AM Yi Zhang <yi.z.zhang@linux.intel.com> wrote:
[..]
> > That comment is incorrect, device-pages are never onlined. So I think
> > we can just skip that call to __SetPageReserved() unless the memory
> > range is MEMORY_DEVICE_{PRIVATE,PUBLIC}.
> >
>
> When pages are "onlined" via __free_pages_boot_core they clear the
> reserved bit, that is the reason for the comment. The reserved bit is
> meant to indicate that the page cannot be swapped out or moved based on
> the description of the bit.

...but ZONE_DEVICE pages are never onlined so I would expect
memmap_init_zone_device() to know that detail.

> I would think with that being the case we still probably need the call
> to __SetPageReserved to set the bit with the expectation that it will
> not be cleared for device-pages since the pages are not onlined.
> Removing the call to __SetPageReserved would probably introduce a number
> of regressions as there are multiple spots that use the reserved bit to
> determine if a page can be swapped out to disk, mapped as system memory,
> or migrated.

Right, this is what Yi is working on... the PageReserved flag is
problematic for KVM. Auditing those locations it seems as long as we
teach hibernation to avoid ZONE_DEVICE ranges we can safely not set
the reserved flag for DAX pages. What I'm trying to avoid is a local
KVM hack to check for DAX pages when the Reserved flag is not
otherwise needed.
