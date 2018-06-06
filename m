Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF626B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 21:33:07 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t133-v6so2669770oih.2
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 18:33:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s3-v6sor3006246otc.25.2018.06.05.18.33.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 18:33:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180606000822.GE4423@redhat.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180524001026.GA3527@redhat.com> <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
 <CAPM=9tzMJq=KC+ijoj-JGmc1R3wbshdwtfR3Zpmyaw3jYJ9+gw@mail.gmail.com>
 <CAPcyv4g2XQtuYGPu8HMbPj6wXqGwxiL5jDRznf5fmW4WgC2DTw@mail.gmail.com>
 <CAPM=9twm=17t=2=M27ELB=vZWzpqM7GuwCUsC891jJ0t3JM4vg@mail.gmail.com>
 <CAPcyv4jTty4k1xXCOWbeRjzv-KjxNH1L4oOkWW1EbJt66jF4_w@mail.gmail.com>
 <20180605184811.GC4423@redhat.com> <CAPM=9twgL_tzkPO=V2mmecSzLjKJkEsJ8A4426fO2Nuus0N_UQ@mail.gmail.com>
 <CAPcyv4gSEYdnJKd=D-_yc3M=sY0HWjYzYhh5ha-v7KA4-40dsg@mail.gmail.com> <20180606000822.GE4423@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 5 Jun 2018 18:33:04 -0700
Message-ID: <CAPcyv4gsS4xDXahZdOggURBHS2y-oJ5tPG9vXPDdY2p6jPufxA@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dave Airlie <airlied@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jun 5, 2018 at 5:08 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Tue, Jun 05, 2018 at 04:06:12PM -0700, Dan Williams wrote:
[..]
>> I want the EXPORT_SYMBOL_GPL on devm_memremap_pages() primarily for
>> development purposes. Any new users of devm_memremap_pages() should be
>> aware that they are subscribing to the whims of the core-VM, i.e. the
>> ongoing evolution of 'struct page', and encourage those drivers to be
>> upstream to improve the implementation, and consolidate use cases. I'm
>> not qualified to comment on your "nor will it change anyone's legal
>> position.", but I'm saying it's in the Linux kernel's best interest
>> that new users of this interface assume they need to be GPL.
>
> Note that HMM isolate the device driver from struct page as long as
> the driver only use HMM helpers to get to the information it needs.
> I intend to be pedantic about that with any driver using HMM. I want
> HMM to be an impedance layer that provide stable and simple API to
> device driver while preserving freedom of change to mm.
>

I would not classify redefining put_page() and recompiling the
entirety of the kernel to turn on HMM as "isolating the driver from
'struct page'". HMM is instead isolating these out of drivers from
ever needing to go upstream.

Unless the nouveau patches are using the entirety of what is already
upstream for HMM, we should look to pare HMM back.

There is plenty of precedent of building a large capability
out-of-tree and piecemeal merging it later, so I do not buy the
"chicken-egg" argument. The change in the export is to make sure we
don't repeat this backward "merge first, ask questions later" mistake
in the future as devm_memremap_pages() is continuing to find new users
like peer-to-peer DMA support and Linux is better off if that
development is upstream. From a purely technical standpoint
devm_memremap_pages() is EXPORT_SYMBOL_GPL because it hacks around
several implementation details in the core kernel to achieve its goal,
and it leaks new assumptions all over the kernel. It is strictly not a
self contained interface.
