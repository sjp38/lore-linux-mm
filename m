Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6036B000C
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 03:50:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j8-v6so12306071wrh.18
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 00:50:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12-v6si454078edq.27.2018.06.11.00.50.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jun 2018 00:50:06 -0700 (PDT)
Date: Mon, 11 Jun 2018 09:50:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE
 pages
Message-ID: <20180611075004.GH13364@dhcp22.suse.cz>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180604124031.GP19202@dhcp22.suse.cz>
 <CAPcyv4gLxz7Ke6ApXoATDN31PSGwTgNRLTX-u1dtT3d+6jmzjw@mail.gmail.com>
 <20180605141104.GF19202@dhcp22.suse.cz>
 <CAPcyv4iGd56kc2NG5GDYMqW740RNr7NZr9DRft==fPxPyieq7Q@mail.gmail.com>
 <20180606073910.GB32433@dhcp22.suse.cz>
 <CAPcyv4hA2Na7wyuyLZSWG5s_4+pEv6aMApk23d2iO1vhFx92XQ@mail.gmail.com>
 <20180607143724.GS32433@dhcp22.suse.cz>
 <CAPcyv4jnyuC-yjuSgu4qKtzB0h9yYMZDsg5Rqqa=HTCY9KM_gw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jnyuC-yjuSgu4qKtzB0h9yYMZDsg5Rqqa=HTCY9KM_gw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu 07-06-18 09:52:22, Dan Williams wrote:
> On Thu, Jun 7, 2018 at 7:37 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 06-06-18 06:44:45, Dan Williams wrote:
> >> On Wed, Jun 6, 2018 at 12:39 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >> > On Tue 05-06-18 07:33:17, Dan Williams wrote:
> >> >> On Tue, Jun 5, 2018 at 7:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >> >> > On Mon 04-06-18 07:31:25, Dan Williams wrote:
> >> >> > [...]
> >> >> >> I'm trying to solve this real world problem when real poison is
> >> >> >> consumed through a dax mapping:
> >> >> >>
> >> >> >>         mce: Uncorrected hardware memory error in user-access at af34214200
> >> >> >>         {1}[Hardware Error]: It has been corrected by h/w and requires
> >> >> >> no further action
> >> >> >>         mce: [Hardware Error]: Machine check events logged
> >> >> >>         {1}[Hardware Error]: event severity: corrected
> >> >> >>         Memory failure: 0xaf34214: reserved kernel page still
> >> >> >> referenced by 1 users
> >> >> >>         [..]
> >> >> >>         Memory failure: 0xaf34214: recovery action for reserved kernel
> >> >> >> page: Failed
> >> >> >>         mce: Memory error not recovered
> >> >> >>
> >> >> >> ...i.e. currently all poison consumed through dax mappings is
> >> >> >> needlessly system fatal.
> >> >> >
> >> >> > Thanks. That should be a part of the changelog.
> >> >>
> >> >> ...added for v3:
> >> >> https://lists.01.org/pipermail/linux-nvdimm/2018-June/016153.html
> >> >>
> >> >> > It would be great to
> >> >> > describe why this cannot be simply handled by hwpoison code without any
> >> >> > ZONE_DEVICE specific hacks? The error is recoverable so why does
> >> >> > hwpoison code even care?
> >> >> >
> >> >>
> >> >> Up until we started testing hardware poison recovery for persistent
> >> >> memory I assumed that the kernel did not need any new enabling to get
> >> >> basic support for recovering userspace consumed poison.
> >> >>
> >> >> However, the recovery code has a dedicated path for many different
> >> >> page states (see: action_page_types). Without any changes it
> >> >> incorrectly assumes that a dax mapped page is a page cache page
> >> >> undergoing dma, or some other pinned operation. It also assumes that
> >> >> the page must be offlined which is not correct / possible for dax
> >> >> mapped pages. There is a possibility to repair poison to dax mapped
> >> >> persistent memory pages, and the pages can't otherwise be offlined
> >> >> because they 1:1 correspond with a physical storage block, i.e.
> >> >> offlining pmem would be equivalent to punching a hole in the physical
> >> >> address space.
> >> >>
> >> >> There's also the entanglement of device-dax which guarantees a given
> >> >> mapping size (4K, 2M, 1G). This requires determining the size of the
> >> >> mapping encompassing a given pfn to know how much to unmap. Since dax
> >> >> mapped pfns don't come from the page allocator we need to read the
> >> >> page size from the page tables, not compound_order(page).
> >> >
> >> > OK, but my question is still. Do we really want to do more on top of the
> >> > existing code and add even more special casing or it is time to rethink
> >> > the whole hwpoison design?
> >>
> >> Well, there's the immediate problem that the current implementation is
> >> broken for dax and then the longer term problem that the current
> >> design appears to be too literal with a lot of custom marshaling.
> >>
> >> At least for dax in the long term we want to offer an alternative
> >> error handling model and get the filesystem much more involved. That
> >> filesystem redesign work has been waiting for the reverse-block-map
> >> effort to settle in xfs. However, that's more custom work for dax and
> >> not a redesign that helps the core-mm more generically.
> >>
> >> I think the unmap and SIGBUS portion of poison handling is relatively
> >> straightforward. It's the handling of the page HWPoison page flag that
> >> seems a bit ad hoc. The current implementation certainly was not
> >> prepared for the concept that memory can be repaired. set_mce_nospec()
> >> is a step in the direction of generic memory error handling.
> >
> > Agreed! Moreover random checks for HWPoison pages is just a maintenance
> > hell.
> >
> >> Thoughts on other pain points in the design that are on your mind, Michal?
> >
> > we have discussed those at LSFMM this year https://lwn.net/Articles/753261/
> > The main problem is that there is besically no design description so the
> > whole feature is very easy to break. Yours is another good example of
> > that. We need to get back to the drawing board and think about how to
> > make this more robust.
> 
> I saw that article, but to be honest I did not glean any direct
> suggestions that read on these current patches. I'm interested in
> discussing a redesign, but I'm not interested in leaving poison
> unhandled for DAX while we figure it out.

Sure but that just keeps the status quo and grows DAX special case like
we've done for hugetlb. We should not repeat that mistake. So we should
better start figuring the design _now_ rather than build the hous of
cards even higher.

> Developers are actively
> testing media error handling for persistent memory applications, and
> expect the current SIGBUS + BUS_MCEERR_AR kernel ABI to work for
> memory errors in userspace mappings.

I do understand you want your usecase to be covered but that is exactly
the reason why we have ended up in the current state. I am not going to
nack your patches on that groud, although I would be so tempted to do
so, but I would really like to see some improvements here. I am sorry I
cannot do that myself right now but somebody with usecases _should_
otherwise we stay in the unfortunate whack a mole state for ever.

-- 
Michal Hocko
SUSE Labs
