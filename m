Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8263A6B0258
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 11:48:56 -0500 (EST)
Received: by obbww6 with SMTP id ww6so37280629obb.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:48:56 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id j9si4080396oex.31.2015.12.02.08.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 08:48:55 -0800 (PST)
Message-ID: <1449078237.31589.30.camel@hpe.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Toshi Kani <toshi.kani@hpe.com>
Date: Wed, 02 Dec 2015 10:43:57 -0700
In-Reply-To: <CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
	 <CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
	 <1449022764.31589.24.camel@hpe.com>
	 <CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 2015-12-01 at 19:45 -0800, Dan Williams wrote:
> On Tue, Dec 1, 2015 at 6:19 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > On Mon, 2015-11-30 at 14:08 -0800, Dan Williams wrote:
> > > On Mon, Nov 23, 2015 at 12:04 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > > > The following oops was observed when mmap() with MAP_POPULATE
> > > > pre-faulted pmd mappings of a DAX file.  follow_trans_huge_pmd()
> > > > expects that a target address has a struct page.
> > > > 
> > > >   BUG: unable to handle kernel paging request at ffffea0012220000
> > > >   follow_trans_huge_pmd+0xba/0x390
> > > >   follow_page_mask+0x33d/0x420
> > > >   __get_user_pages+0xdc/0x800
> > > >   populate_vma_page_range+0xb5/0xe0
> > > >   __mm_populate+0xc5/0x150
> > > >   vm_mmap_pgoff+0xd5/0xe0
> > > >   SyS_mmap_pgoff+0x1c1/0x290
> > > >   SyS_mmap+0x1b/0x30
> > > > 
> > > > Fix it by making the PMD pre-fault handling consistent with PTE.
> > > > After pre-faulted in faultin_page(), follow_page_mask() calls
> > > > follow_trans_huge_pmd(), which is changed to call follow_pfn_pmd()
> > > > for VM_PFNMAP or VM_MIXEDMAP.  follow_pfn_pmd() handles FOLL_TOUCH
> > > > and returns with -EEXIST.
> > > > 
> > > > Reported-by: Mauricio Porto <mauricio.porto@hpe.com>
> > > > Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > Cc: Matthew Wilcox <willy@linux.intel.com>
> > > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > > ---
> > > 
> > > Hey Toshi,
> > > 
> > > I ended up fixing this differently with follow_pmd_devmap() introduced
> > > in this series:
> > > 
> > > https://lists.01.org/pipermail/linux-nvdimm/2015-November/003033.html
> > > 
> > > Does the latest libnvdimm-pending branch [1] pass your test case?
> > 
> > Hi Dan,
> > 
> > I ran several test cases, and they all hit the case "pfn not in memmap" in
> > __dax_pmd_fault() during mmap(MAP_POPULATE).  Looking at the dax.pfn,
> > PFN_DEV is
> > set but PFN_MAP is not.  I have not looked into why, but I thought I let you
> > know first.  I've also seen the test thread got hung up at the end sometime.
> 
> That PFN_MAP flag will not be set by default for NFIT-defined
> persistent memory.  See pmem_should_map_pages() for pmem namespaces
> that will have it set by default, currently only e820 type-12 memory
> ranges.
> 
> NFIT-defined persistent memory can have a memmap array dynamically
> allocated by setting up a pfn device (similar to setting up a btt).
> We don't map it by default because the NFIT may describe hundreds of
> gigabytes of persistent and the overhead of the memmap may be too
> large to locate the memmap in ram.

Oh, I see.  I will setup the memmap array and run the tests again.

But, why does the PMD mapping depend on the memmap array?  We have observed
major performance improvement with PMD.  This feature should always be enabled
with DAX regardless of the option to allocate the memmap array.

Thanks,
-Toshi 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
