Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76D3C6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 13:25:25 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h11so134799408oic.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:25:25 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id l127si10922498oia.46.2016.09.12.10.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 10:25:24 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id d191so108481044oih.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:25:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOSf1CHKY7LT0z+wpo7jUy3aYUDHCKDKwF0XoMwpKN4JwfYjeA@mail.gmail.com>
References: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAOSf1CHKY7LT0z+wpo7jUy3aYUDHCKDKwF0XoMwpKN4JwfYjeA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Sep 2016 10:25:23 -0700
Message-ID: <CAPcyv4i7faR5KnaSKFFHnc-=1XsTn2naWfiCjB4Mn2=womg9QA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm, mincore2(): retrieve dax and tlb-size
 attributes of an address range
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sun, Sep 11, 2016 at 11:29 PM, Oliver O'Halloran <oohall@gmail.com> wrote:
> On Mon, Sep 12, 2016 at 3:31 AM, Dan Williams <dan.j.williams@intel.com> wrote:
>> As evidenced by this bug report [1], userspace libraries are interested
>> in whether a mapping is DAX mapped, i.e. no intervening page cache.
>> Rather than using the ambiguous VM_MIXEDMAP flag in smaps, provide an
>> explicit "is dax" indication as a new flag in the page vector populated
>> by mincore.
>>
>> There are also cases, particularly for testing and validating a
>> configuration to know the hardware mapping geometry of the pages in a
>> given process address range.  Consider filesystem-dax where a
>> configuration needs to take care to align partitions and block
>> allocations before huge page mappings might be used, or
>> anonymous-transparent-huge-pages where a process is opportunistically
>> assigned large pages.  mincore2() allows these configurations to be
>> surveyed and validated.
>>
>> The implementation takes advantage of the unused bits in the per-page
>> byte returned for each PAGE_SIZE extent of a given address range.  The
>> new format of each vector byte is:
>>
>> (TLB_SHIFT - PAGE_SHIFT) << 2 | vma_is_dax() << 1 | page_present
>
> What is userspace expected to do with the information in vec? Whether
> PMD or THP mappings can be used is going to depend more on the block
> allocations done by the filesystem rather than anything the an
> application can directly influence. Returning a vector for each page
> makes some sense in the mincore() case since the application can touch
> each page to fault them in, but I don't see what they can do here.

It's not a "can huge pages be used?" question it's interrogating the
mapping that got established after the fact.  If an
application/environment expects huge mappings, but pte mappings are
getting established

> Why not just get rid of vec entirely and make mincore2() a yes/no
> check over the range for whatever is supplied in flags? That would
> work for NVML's use case and it should be easier to extend if needed.

I think having a way to ask the kernel if an address range satisfies a
certain set of input attributes is a useful interface.  Perhaps a
"MINCORE_CHECK" flag can indicate that the input vector contains a
single character that it wants the kernel to validate during the page
table walk, and return zero or the offset of the first mismatch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
