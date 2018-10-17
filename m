Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD63D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:31:11 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id y22so20023657oty.3
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:31:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u205-v6sor8024414oig.120.2018.10.17.09.31.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 09:31:10 -0700 (PDT)
MIME-Version: 1.0
References: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153936657702.1198040.119388737535638846.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181017081753.GG18839@dhcp22.suse.cz>
In-Reply-To: <20181017081753.GG18839@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Oct 2018 09:30:58 -0700
Message-ID: <CAPcyv4hMFQYekvZWMzKYckuVLSGd3GizRtoDudFBQj5bfxD3Mw@mail.gmail.com>
Subject: Re: [PATCH v7 1/7] mm, devm_memremap_pages: Mark devm_memremap_pages()
 EXPORT_SYMBOL_GPL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Oct 17, 2018 at 1:18 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 12-10-18 10:49:37, Dan Williams wrote:
> > devm_memremap_pages() is a facility that can create struct page entries
> > for any arbitrary range and give drivers the ability to subvert core
> > aspects of page management.
> >
> > Specifically the facility is tightly integrated with the kernel's memory
> > hotplug functionality. It injects an altmap argument deep into the
> > architecture specific vmemmap implementation to allow allocating from
> > specific reserved pages, and it has Linux specific assumptions about
> > page structure reference counting relative to get_user_pages() and
> > get_user_pages_fast(). It was an oversight and a mistake that this was
> > not marked EXPORT_SYMBOL_GPL from the outset.
>
> One thing is still not clear to me. Both devm_memremap_* and
> hmm_devmem_add essentially do the same thing AFAICS. They both allow to
> hotplug a device memory. Both rely on the hotplug code (namely
> add_pages) which itself is not exported to modules. One is GPL only
> while the later is a general export. Is this mismatch desirable?

That is resolved by the last patch in this series.

> API exported by the core hotplug is ad-hoc to say the least. Symbols
> that we actually export are GPL mostly (only try_offline_node is
> EXPORT_SYMBOL without any explanation whatsoever). So I would call it a
> general mess tweaked for specific usecases.
>
> I personally do not care about EXPORT_SYMBOL vs. EXPORT_SYMBOL_GPL
> much to be honest. I understand an argument that we do not care about
> out-of-tree modules a wee bit. I would just be worried those will find a
> way around and my experience tells me that it would be much uglier than
> what the core kernel can provide. But this seems more political than
> technical discussion.

I'm not worried about people finding a way around, I'm sure
cringe-worthy workarounds of core kernel details happen on a regular
basis in out-of-tree code. EXPORT_SYMBOL_GPL in this instance is not a
political statement, it is a statement of the rate of evolution and
depth of the api.

>
> > Again, devm_memremap_pagex() exposes and relies upon core kernel
> > internal assumptions and will continue to evolve along with 'struct
> > page', memory hotplug, and support for new memory types / topologies.
> > Only an in-kernel GPL-only driver is expected to keep up with this
> > ongoing evolution. This interface, and functionality derived from this
> > interface, is not suitable for kernel-external drivers.
>
> I do not follow this line of argumentation though. We generally do not
> care about out-of-tree modules and breaking them if the interface has to
> be updated.

Exactly right. The EXPORT_SYMBOL_GPL is there to say that this api has
deep enough ties into the core kernel to lower the confidence that the
API will stay stable from one kernel revision to the next. It's also
an api that is attracting widening and varied reuse and the long term
health of the implementation depends on being able to peer deeply into
its users and refactor the interface and the core kernel as a result.

> Also what about GPL out of tree modules?

These are precisely the modules we want upstream.

> That being said, I do not mind this patch. You and Christoph are the
> authors and therefore it is you to decide. I just find the current
> situation confusing to say the least.

Hopefully I clarified, let me know if not.
