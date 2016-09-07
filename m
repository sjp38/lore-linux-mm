Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E23176B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:34:31 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w78so70022330oie.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:34:31 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id g50si24721207ote.67.2016.09.07.12.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 12:45:17 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id s131so41134175oie.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 12:45:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473277101.2092.39.camel@hpe.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160906131756.6b6c6315b7dfba3a9d5f233a@linux-foundation.org>
 <CAPcyv4hjdPWxdY+UTKVstiLZ7r4oOCa+h+Hd+kzS+wJZidzCjA@mail.gmail.com> <1473277101.2092.39.camel@hpe.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 7 Sep 2016 12:45:16 -0700
Message-ID: <CAPcyv4hbBVYk=vqeiJ28LHZ8H3y9HiRwOhKEQY7D02jZA0goEA@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: fix cache mode of dax pmd mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "kai.ka.zhang@oracle.com" <kai.ka.zhang@oracle.com>, "nilesh.choudhury@oracle.com" <nilesh.choudhury@oracle.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>

On Wed, Sep 7, 2016 at 12:39 PM, Kani, Toshimitsu <toshi.kani@hpe.com> wrote:
> On Tue, 2016-09-06 at 14:52 -0700, Dan Williams wrote:
>> On Tue, Sep 6, 2016 at 1:17 PM, Andrew Morton <akpm@linux-foundation.
>> org> wrote:
>> >
>> > On Tue, 06 Sep 2016 09:49:41 -0700 Dan Williams <dan.j.williams@int
>> > el.com> wrote:
>> >
>> > >
>> > > track_pfn_insert() is marking dax mappings as uncacheable.
>> > >
>> > > It is used to keep mappings attributes consistent across a
>> > > remapped range. However, since dax regions are never registered
>> > > via track_pfn_remap(), the caching mode lookup for dax pfns
>> > > always returns _PAGE_CACHE_MODE_UC.  We do not use
>> > > track_pfn_insert() in the dax-pte path, and we always want to use
>> > > the pgprot of the vma itself, so drop this call.
>> > >
>> > > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> > > Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > > Cc: Andrew Morton <akpm@linux-foundation.org>
>> > > Cc: Nilesh Choudhury <nilesh.choudhury@oracle.com>
>> > > Reported-by: Kai Zhang <kai.ka.zhang@oracle.com>
>> > > Reported-by: Toshi Kani <toshi.kani@hpe.com>
>> > > Cc: <stable@vger.kernel.org>
>> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> >
>> > Changelog fails to explain the user-visible effects of the
>> > patch.  The stable maintainer(s) will look at this and wonder "ytf
>> > was I sent this".
>>
>> True, I'll change it to this:
>>
>> track_pfn_insert() is marking dax mappings as uncacheable rendering
>> them impractical for application usage.  DAX-pte mappings are cached
>> and the goal of establishing DAX-pmd mappings is to attain more
>> performance, not dramatically less (3 orders of magnitude).
>>
>> Deleting the call to track_pfn_insert() in vmf_insert_pfn_pmd() lets
>> the default pgprot (write-back cache enabled) from the vma be used
>> for the mapping which yields the expected performance improvement
>> over DAX-pte mappings.
>>
>> track_pfn_insert() is meant to keep the cache mode for a given range
>> synchronized across different users of remap_pfn_range() and
>> vm_insert_pfn_prot().  DAX uses neither of those mapping methods, and
>> the pmem driver is already marking its memory ranges as write-back
>> cache enabled.  So, removing the call to track_pfn_insert() leaves
>> the kernel no worse off than the current situation where a user could
>> map the range via /dev/mem with an incompatible cache mode compared
>> to the driver.
>
> I think devm_memremap_pages() should call reserve_memtype() on x86 to
> keep it consistent with devm_memremap() on this regard.  We may need an
> arch stub for reserve_memtype(), though.  Then, track_pfn_insert()
> should have no issue in this case.

Yes, indeed!  In fact I already have that re-write getting 0day
coverage before posting.  It occurred to me while re-writing the
changelog per Andrew's prompting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
