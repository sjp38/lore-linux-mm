Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 49C2F6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 20:43:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e69so19121486pfg.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 17:43:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a24sor2671328pfe.38.2017.10.03.17.43.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 17:43:45 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mm/mmu_notifier: avoid double notification when it is
 useless
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20171004001559.GD20644@redhat.com>
Date: Tue, 3 Oct 2017 17:43:47 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <0D64494B-AB3D-4091-B75A-883EA37BE098@gmail.com>
References: <20170901173011.10745-1-jglisse@redhat.com>
 <20171003234215.GA5231@redhat.com> <20171004001559.GD20644@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org

Jerome Glisse <jglisse@redhat.com> wrote:

> On Wed, Oct 04, 2017 at 01:42:15AM +0200, Andrea Arcangeli wrote:
>=20
>> I'd like some more explanation about the inner working of "that new
>> user" as per comment above.
>>=20
>> It would be enough to drop mmu_notifier_invalidate_range from above
>> without adding it to the filebacked case. The above gives higher prio
>> to the hypothetical and uncertain future case, than to the current
>> real filebacked case that doesn't need ->invalidate_range inside the
>> PT lock, or do you see something that might already need such
>> ->invalidate_range?
>=20
> No i don't see any new user today that might need such invalidate but
> i was trying to be extra cautious as i have a tendency to assume that
> someone might do a patch that use try_to_unmap() without going through
> all the comments in the function and thus possibly using it in a an
> unexpected way from mmu_notifier callback point of view. I am fine
> with putting the burden on new user to get it right and adding an
> extra warning in the function description to try to warn people in a
> sensible way.

I must be missing something. After the PTE is changed, but before the
secondary TLB notification/invalidation - What prevents another thread =
from
changing the mappings (e.g., using munmap/mmap), and setting a new page
at that PTE?

Wouldn=E2=80=99t it end with the page being mapped without a secondary =
TLB flush in
between?

Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
