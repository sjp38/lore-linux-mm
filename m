Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA040280395
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 20:11:26 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g33so644762ioj.8
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 17:11:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m100sor2217228iod.20.2017.08.29.17.11.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 17:11:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Aug 2017 17:11:24 -0700
Message-ID: <CA+55aFz6ArJ-ADXiYCu6xMUzdY=mKBtkzfJmLaBohC6Ub9t2SQ@mail.gmail.com>
Subject: Re: [PATCH 00/13] mmu_notifier kill invalidate_page callback
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, DRI <dri-devel@lists.freedesktop.org>, amd-gfx@lists.freedesktop.org, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, xen-devel <xen-devel@lists.xenproject.org>, KVM list <kvm@vger.kernel.org>

On Tue, Aug 29, 2017 at 4:54 PM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
>
> Note this is barely tested. I intend to do more testing of next few days
> but i do not have access to all hardware that make use of the mmu_notifie=
r
> API.

Thanks for doing this.

> First 2 patches convert existing call of mmu_notifier_invalidate_page()
> to mmu_notifier_invalidate_range() and bracket those call with call to
> mmu_notifier_invalidate_range_start()/end().

Ok, those two patches are a bit more complex than I was hoping for,
but not *too* bad.

And the final end result certainly looks nice:

>  16 files changed, 74 insertions(+), 214 deletions(-)

Yeah, removing all those invalidate_page() notifiers certainly makes
for a nice patch.

And I actually think you missed some more lines that can now be
removed: kvm_arch_mmu_notifier_invalidate_page() should no longer be
needed either, so you can remove all of those too (most of them are
empty inline functions, but x86 has one that actually does something.

So there's an added 30 or so dead lines that should be removed in the
kvm patch, I think.

But from a _very_ quick read-through this looks fine. But it obviously
needs testing.

People - *especially* the people who saw issues under KVM - can you
try out J=C3=A9r=C3=B4me's patch-series? I aded some people to the cc, the =
full
series is on lkml. J=C3=A9r=C3=B4me - do you have a git branch for people t=
o
test that they could easily pull and try out?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
