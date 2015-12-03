Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 41C566B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:26:44 -0500 (EST)
Received: by oba1 with SMTP id 1so1501080oba.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:26:44 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id u9si5177130oel.44.2015.12.02.15.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 15:26:43 -0800 (PST)
Message-ID: <1449102105.9855.15.camel@hpe.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Toshi Kani <toshi.kani@hpe.com>
Date: Wed, 02 Dec 2015 17:21:45 -0700
In-Reply-To: <1449078237.31589.30.camel@hpe.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
	 <CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
	 <1449022764.31589.24.camel@hpe.com>
	 <CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
	 <1449078237.31589.30.camel@hpe.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 2015-12-02 at 10:43 -0700, Toshi Kani wrote:
> On Tue, 2015-12-01 at 19:45 -0800, Dan Williams wrote:
> > On Tue, Dec 1, 2015 at 6:19 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > > On Mon, 2015-11-30 at 14:08 -0800, Dan Williams wrote:
 :
> > > > 
> > > > Hey Toshi,
> > > > 
> > > > I ended up fixing this differently with follow_pmd_devmap() introduced
> > > > in this series:
> > > > 
> > > > https://lists.01.org/pipermail/linux-nvdimm/2015-November/003033.html
> > > > 
> > > > Does the latest libnvdimm-pending branch [1] pass your test case?
> > > 
> > > Hi Dan,
> > > 
> > > I ran several test cases, and they all hit the case "pfn not in memmap" in
> > > __dax_pmd_fault() during mmap(MAP_POPULATE).  Looking at the dax.pfn,
> > > PFN_DEV is set but PFN_MAP is not.  I have not looked into why, but I 
> > > thought I let you know first.  I've also seen the test thread got hung up 
> > > at the end sometime.
> > 
> > That PFN_MAP flag will not be set by default for NFIT-defined
> > persistent memory.  See pmem_should_map_pages() for pmem namespaces
> > that will have it set by default, currently only e820 type-12 memory
> > ranges.
> > 
> > NFIT-defined persistent memory can have a memmap array dynamically
> > allocated by setting up a pfn device (similar to setting up a btt).
> > We don't map it by default because the NFIT may describe hundreds of
> > gigabytes of persistent and the overhead of the memmap may be too
> > large to locate the memmap in ram.
> 
> Oh, I see.  I will setup the memmap array and run the tests again.

I setup a pfn device, and ran a few test cases again.  Yes, it solved the
PFN_MAP issue.  However, I am no longer able to allocate FS blocks aligned by
2MB, so PMD faults fall back to PTE.  They are off by 2 pages, which I suspect
due to the pfn metadata.  If I pass a 2MB-aligned+2pages virtual address to
mmap(MAP_POPULATE), the mmap() call gets hung up.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
