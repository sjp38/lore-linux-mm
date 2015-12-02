Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE4F6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:33:59 -0500 (EST)
Received: by ykdr82 with SMTP id r82so66488780ykd.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:33:59 -0800 (PST)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id e79si3350988ywa.233.2015.12.02.15.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 15:33:58 -0800 (PST)
Received: by ykfs79 with SMTP id s79so67125585ykf.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:33:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449102105.9855.15.camel@hpe.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
	<CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
	<1449022764.31589.24.camel@hpe.com>
	<CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
	<1449078237.31589.30.camel@hpe.com>
	<1449102105.9855.15.camel@hpe.com>
Date: Wed, 2 Dec 2015 15:33:58 -0800
Message-ID: <CAPcyv4iLCmf48+JAaSPSMPuLUbK_vj67oB2ZFpz-KXKkiUz-8Q@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 2, 2015 at 4:21 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> On Wed, 2015-12-02 at 10:43 -0700, Toshi Kani wrote:
>> On Tue, 2015-12-01 at 19:45 -0800, Dan Williams wrote:
>> > On Tue, Dec 1, 2015 at 6:19 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
>> > > On Mon, 2015-11-30 at 14:08 -0800, Dan Williams wrote:
>  :
>> > > >
>> > > > Hey Toshi,
>> > > >
>> > > > I ended up fixing this differently with follow_pmd_devmap() introduced
>> > > > in this series:
>> > > >
>> > > > https://lists.01.org/pipermail/linux-nvdimm/2015-November/003033.html
>> > > >
>> > > > Does the latest libnvdimm-pending branch [1] pass your test case?
>> > >
>> > > Hi Dan,
>> > >
>> > > I ran several test cases, and they all hit the case "pfn not in memmap" in
>> > > __dax_pmd_fault() during mmap(MAP_POPULATE).  Looking at the dax.pfn,
>> > > PFN_DEV is set but PFN_MAP is not.  I have not looked into why, but I
>> > > thought I let you know first.  I've also seen the test thread got hung up
>> > > at the end sometime.
>> >
>> > That PFN_MAP flag will not be set by default for NFIT-defined
>> > persistent memory.  See pmem_should_map_pages() for pmem namespaces
>> > that will have it set by default, currently only e820 type-12 memory
>> > ranges.
>> >
>> > NFIT-defined persistent memory can have a memmap array dynamically
>> > allocated by setting up a pfn device (similar to setting up a btt).
>> > We don't map it by default because the NFIT may describe hundreds of
>> > gigabytes of persistent and the overhead of the memmap may be too
>> > large to locate the memmap in ram.
>>
>> Oh, I see.  I will setup the memmap array and run the tests again.
>
> I setup a pfn device, and ran a few test cases again.  Yes, it solved the
> PFN_MAP issue.  However, I am no longer able to allocate FS blocks aligned by
> 2MB, so PMD faults fall back to PTE.  They are off by 2 pages, which I suspect
> due to the pfn metadata.If I pass a 2MB-aligned+2pages virtual address to
> mmap(MAP_POPULATE), the mmap() call gets hung up.

Ok, I need to switch over from my memmap=ss!nn config.  We just need
to pad the info block reservation to 2M.  As for the MAP_POPULATE
hang, I'll take a look.

Right now I'm in the process of rebasing the whole set on top of -mm
which has a pending THP re-works from Kirill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
