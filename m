Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77A6D6B0494
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 20:56:24 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m4so14660879qke.6
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 17:56:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n13si3812274qtk.258.2017.08.29.17.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 17:56:23 -0700 (PDT)
Date: Tue, 29 Aug 2017 20:56:15 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 00/13] mmu_notifier kill invalidate_page callback
Message-ID: <20170830005615.GA2386@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <CA+55aFz6ArJ-ADXiYCu6xMUzdY=mKBtkzfJmLaBohC6Ub9t2SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFz6ArJ-ADXiYCu6xMUzdY=mKBtkzfJmLaBohC6Ub9t2SQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, DRI <dri-devel@lists.freedesktop.org>, amd-gfx@lists.freedesktop.org, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, xen-devel <xen-devel@lists.xenproject.org>, KVM list <kvm@vger.kernel.org>

On Tue, Aug 29, 2017 at 05:11:24PM -0700, Linus Torvalds wrote:
> On Tue, Aug 29, 2017 at 4:54 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > Note this is barely tested. I intend to do more testing of next few days
> > but i do not have access to all hardware that make use of the mmu_notifier
> > API.
> 
> Thanks for doing this.
> 
> > First 2 patches convert existing call of mmu_notifier_invalidate_page()
> > to mmu_notifier_invalidate_range() and bracket those call with call to
> > mmu_notifier_invalidate_range_start()/end().
> 
> Ok, those two patches are a bit more complex than I was hoping for,
> but not *too* bad.
> 
> And the final end result certainly looks nice:
> 
> >  16 files changed, 74 insertions(+), 214 deletions(-)
> 
> Yeah, removing all those invalidate_page() notifiers certainly makes
> for a nice patch.
> 
> And I actually think you missed some more lines that can now be
> removed: kvm_arch_mmu_notifier_invalidate_page() should no longer be
> needed either, so you can remove all of those too (most of them are
> empty inline functions, but x86 has one that actually does something.
> 
> So there's an added 30 or so dead lines that should be removed in the
> kvm patch, I think.

Yes i missed that. I will wait for people to test and for result of my
own test before reposting if need be, otherwise i will post as separate
patch.

> 
> But from a _very_ quick read-through this looks fine. But it obviously
> needs testing.
> 
> People - *especially* the people who saw issues under KVM - can you
> try out Jerome's patch-series? I aded some people to the cc, the full
> series is on lkml. Jerome - do you have a git branch for people to
> test that they could easily pull and try out?

https://cgit.freedesktop.org/~glisse/linux mmu-notifier branch
git://people.freedesktop.org/~glisse/linux

(Sorry if that tree is bit big it has a lot of dead thing i need
 to push a clean and slim one)

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
