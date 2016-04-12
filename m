Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B08266B025E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:59:10 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id zm5so15043367pac.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:59:10 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id mj6si10697605pab.89.2016.04.12.07.59.09
        for <linux-mm@kvack.org>;
        Tue, 12 Apr 2016 07:59:09 -0700 (PDT)
Date: Tue, 12 Apr 2016 15:59:03 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
Message-ID: <20160412145903.GF8066@e104818-lin.cambridge.arm.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <20160407142148.GI5657@arm.com>
 <570B10B2.2000000@hisilicon.com>
 <CAKv+Gu8iQ0NzLFWHy9Ggyv+jL-BqJ3x-KaRD1SZ1mU6yU3c7UQ@mail.gmail.com>
 <570B5875.20804@hisilicon.com>
 <CAKv+Gu9aqR=E3TmbPDFEUC+Q13bAJTU5wVTTHkOr6aX6BZ1OVA@mail.gmail.com>
 <570B758E.7070005@hisilicon.com>
 <CAKv+Gu-cWWUi6fCiveqaZRVhGCpEasCLEs7wq6t+C-x65g4cgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-cWWUi6fCiveqaZRVhGCpEasCLEs7wq6t+C-x65g4cgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Chen Feng <puck.chen@hisilicon.com>, Mark Rutland <mark.rutland@arm.com>, Dan Zhao <dan.zhao@hisilicon.com>, mhocko@suse.com, Yiping Xu <xuyiping@hisilicon.com>, puck.chen@foxmail.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, suzhuangluan@hisilicon.com, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxarm@huawei.com, albert.lubing@hisilicon.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, David Rientjes <rientjes@google.com>, oliver.fu@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, robin.murphy@arm.com, kirill.shutemov@linux.intel.com, saberlily.xia@hisilicon.com

On Mon, Apr 11, 2016 at 12:31:53PM +0200, Ard Biesheuvel wrote:
> On 11 April 2016 at 11:59, Chen Feng <puck.chen@hisilicon.com> wrote:
> > On 2016/4/11 16:00, Ard Biesheuvel wrote:
> >> On 11 April 2016 at 09:55, Chen Feng <puck.chen@hisilicon.com> wrote:
> >>> On 2016/4/11 15:35, Ard Biesheuvel wrote:
> >>>> On 11 April 2016 at 04:49, Chen Feng <puck.chen@hisilicon.com> wrote:
> >>>>>  0             1.5G    2G             3.5G            4G
> >>>>>  |              |      |               |              |
> >>>>>  +--------------+------+---------------+--------------+
> >>>>>  |    MEM       | hole |     MEM       |   IO (regs)  |
> >>>>>  +--------------+------+---------------+--------------+
> >>> The hole in 1.5G ~ 2G is also allocated mem-map array. And also with the 3.5G ~ 4G.
> >>>
> >>
> >> No, it is not. It may be covered by a section, but that does not mean
> >> sparsemem vmemmap will actually allocate backing for it. The
> >> granularity used by sparsemem vmemmap on a 4k pages kernel is 128 MB,
> >> due to the fact that the backing is performed at PMD granularity.
> >>
> >> Please, could you share the contents of the vmemmap section in
> >> /sys/kernel/debug/kernel_page_tables of your system running with
> >> sparsemem vmemmap enabled? You will need to set CONFIG_ARM64_PTDUMP=y
> >
> > Please see the pg-tables below.
> >
> > With sparse and vmemmap enable.
> >
> > ---[ vmemmap start ]---
> > 0xffffffbdc0200000-0xffffffbdc4800000          70M     RW NX SHD AF    UXN MEM/NORMAL
> > ---[ vmemmap end ]---
[...]
> > The board is 4GB, and the memap is 70MB
> > 1G memory --- 14MB mem_map array.
> 
> No, this is incorrect. 1 GB corresponds with 16 MB worth of struct
> pages assuming sizeof(struct page) == 64
> 
> So you are losing 6 MB to rounding here, which I agree is significant.
> I wonder if it makes sense to use a lower value for SECTION_SIZE_BITS
> on 4k pages kernels, but perhaps we're better off asking the opinion
> of the other cc'ees.

IIRC, SECTION_SIZE_BITS was chosen to be the maximum sane value we were
thinking of at the time, assuming that 1GB RAM alignment to be fairly
normal. For the !SPARSEMEM_VMEMMAP case, we should probably be fine with
29 but, as Will said, we need to be careful with the page flags. At a
quick look, we have 25 page flags, 2 bits per zone, NUMA nodes and (48 -
section_size_bits) for the section width. We also need to take into
account 4 more bits for 52-bit PA support (ARMv8.2). So, without NUMA
nodes, we are currently at 49 bits used in page->flags.

For the SPARSEMEM_VMEMMAP case, we can decrease the SECTION_SIZE_BITS in
the MAX_ORDER limit.

An alternative would be to free the vmemmap holes later (but still keep
the vmemmap mapping alias). Yet another option would be to change the
sparse_mem_map_populate() logic get the actual section end rather than
always assuming PAGES_PER_SECTION. But I don't think any of these are
worth if we can safely reduce SECTION_SIZE_BITS.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
