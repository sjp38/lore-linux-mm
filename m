Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2876B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 19:33:52 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e2-v6so9590565oii.20
        for <linux-mm@kvack.org>; Tue, 29 May 2018 16:33:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4-v6sor4991338otk.179.2018.05.29.16.33.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 16:33:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPM=9twm=17t=2=M27ELB=vZWzpqM7GuwCUsC891jJ0t3JM4vg@mail.gmail.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180524001026.GA3527@redhat.com> <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
 <CAPM=9tzMJq=KC+ijoj-JGmc1R3wbshdwtfR3Zpmyaw3jYJ9+gw@mail.gmail.com>
 <CAPcyv4g2XQtuYGPu8HMbPj6wXqGwxiL5jDRznf5fmW4WgC2DTw@mail.gmail.com> <CAPM=9twm=17t=2=M27ELB=vZWzpqM7GuwCUsC891jJ0t3JM4vg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 29 May 2018 16:33:49 -0700
Message-ID: <CAPcyv4jTty4k1xXCOWbeRjzv-KjxNH1L4oOkWW1EbJt66jF4_w@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, May 29, 2018 at 4:00 PM, Dave Airlie <airlied@gmail.com> wrote:
> On 30 May 2018 at 08:31, Dan Williams <dan.j.williams@intel.com> wrote:
>> On Tue, May 29, 2018 at 3:22 PM, Dave Airlie <airlied@gmail.com> wrote:
>>>
>>> On 24 May 2018 at 13:18, Dan Williams <dan.j.williams@intel.com> wrote:
>>> > On Wed, May 23, 2018 at 5:10 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>>> >> On Mon, May 21, 2018 at 03:35:14PM -0700, Dan Williams wrote:
>>> >>> Hi Andrew, please consider this series for 4.18.
>>> >>>
>>> >>> For maintainability, as ZONE_DEVICE continues to attract new users,
>>> >>> it is useful to keep all users consolidated on devm_memremap_pages() as
>>> >>> the interface for create "device pages".
>>> >>>
>>> >>> The devm_memremap_pages() implementation was recently reworked to make
>>> >>> it more generic for arbitrary users, like the proposed peer-to-peer
>>> >>> PCI-E enabling. HMM pre-dated this rework and opted to duplicate
>>> >>> devm_memremap_pages() as hmm_devmem_pages_create().
>>> >>>
>>> >>> Rework HMM to be a consumer of devm_memremap_pages() directly and fix up
>>> >>> the licensing on the exports given the deep dependencies on the mm.
>>> >>
>>> >> I am on PTO right now so i won't be able to quickly review it all
>>> >> but forcing GPL export is problematic for me now. I rather have
>>> >> device driver using "sane" common helpers than creating their own
>>> >> crazy thing.
>>> >
>>> > Sane drivers that need this level of deep integration with Linux
>>> > memory management need to be upstream. Otherwise, HMM is an
>>> > unprecedented departure from the norms of Linux kernel development.
>>>
>>> Isn't it the author of code choice what EXPORT_SYMBOL to use? and
>>> isn't the agreement that if something is EXPORT_SYMBOL now, changing
>>> underlying exports isn't considered a good idea. We've seen this before
>>> with the refcount fun,
>>>
>>> See d557d1b58b3546bab2c5bc2d624c5709840e6b10
>>>
>>> Not commenting on the legality or what derived works are considered,
>>> since really the markings are just an indication of the authors opinion,
>>> and at this stage I think are actually meaningless, since we've diverged
>>> considerably from the advice given to Linus back when this started.
>>
>> Yes, and in this case devm_memremap_pages() was originally written by
>> Christoph and I:
>>
>>     41e94a851304 add devm_memremap_pages
>
> So you wrote some code in 2015 (3 years ago) and you've now decided
> to change the EXPORT marker on it? what changed in 3 years, and why
> would changing that marker 3 years later have any effect on your original
> statement that it was an EXPORT_SYMBOL.
>
> Think what EXPORT_SYMBOL vs GPL means, it isn't a bit stick that magically
> makes things into derived works. If something wasn't a derived work for 3 years
> using that API, then it isn't a derived work now 3 years later because you
> changed the marker. Retrospectively changing the markers doesn't really
> make any sense legally or otherwise.

It honestly was an oversight, and as we've gone on to add deeper and
deeper ties into the mm and filesystems [1] I realized this symbol was
mis-labeled.  It would be one thing if this was just some random
kernel leaf / library function, but this capability when turned on
causes the entire kernel to be recompiled as things like the
definition of put_page() changes. It's deeply integrated with how
Linux manages memory.

>> HMM started off by duplicating devm_memremap_pages() which is fixed up
>> by this series:
>
> Just looking in my current tree hmm_devmem_pages_create and
> devm_memremap_pages don't look like duplicates, they might have
> code but they definitely aren't one for one copies. I'm not sure you can
> just say Jerome copied that code in, you've now refactored the code
> so HMM can use it and are changing the symbol exports underneath it,

The initial patches for HMM used devm_memremap_pages() directly, and
during review I asked for the exact same arrangement as implemented
here, i.e. for the dev_pagemap structure to be a sub-structure of the
HMM data [2]. At some point along the way we lost that review
feedback. It was not until Christoph and Logan recently reworked
devm_memermap_pages() that I realized that HMM had unnecessarily
diverged.

> Again if Christoph believes all uses of this are a derived work he didn't
> indicate it 3 years ago, but neither does the mark make any legal difference
> in this case, since everything in the kernel is GPL, and if you
> consider something
> a derived work or not is well into legal land.
>
> I'd rather anyways the original author of HMM wishes were respected
> on his code, or at least you wait until he gets back from holidays before
> pushing to merge this.

To be clear this only affects the usage of the ZONE_DEVICE facility,
I'm not touching the other pieces of HMM that are original to HMM. I
didn't realize Jerome was on vacation when I sent the patches, and I
think it is otherwise healthy to have this discussion in the meantime.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-May/015905.html
[2]: http://lkml.iu.edu/hypermail/linux/kernel/1701.2/00812.html
