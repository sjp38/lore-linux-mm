Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 317CC6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:29:57 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id u82so288730900ywc.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 23:29:57 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id m190si10269987qkb.222.2016.09.11.23.29.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 23:29:56 -0700 (PDT)
Received: by mail-qk0-x234.google.com with SMTP id z190so122430104qkc.3
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 23:29:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
From: "Oliver O'Halloran" <oohall@gmail.com>
Date: Mon, 12 Sep 2016 16:29:55 +1000
Message-ID: <CAOSf1CHKY7LT0z+wpo7jUy3aYUDHCKDKwF0XoMwpKN4JwfYjeA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm, mincore2(): retrieve dax and tlb-size
 attributes of an address range
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Sep 12, 2016 at 3:31 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> As evidenced by this bug report [1], userspace libraries are interested
> in whether a mapping is DAX mapped, i.e. no intervening page cache.
> Rather than using the ambiguous VM_MIXEDMAP flag in smaps, provide an
> explicit "is dax" indication as a new flag in the page vector populated
> by mincore.
>
> There are also cases, particularly for testing and validating a
> configuration to know the hardware mapping geometry of the pages in a
> given process address range.  Consider filesystem-dax where a
> configuration needs to take care to align partitions and block
> allocations before huge page mappings might be used, or
> anonymous-transparent-huge-pages where a process is opportunistically
> assigned large pages.  mincore2() allows these configurations to be
> surveyed and validated.
>
> The implementation takes advantage of the unused bits in the per-page
> byte returned for each PAGE_SIZE extent of a given address range.  The
> new format of each vector byte is:
>
> (TLB_SHIFT - PAGE_SHIFT) << 2 | vma_is_dax() << 1 | page_present

What is userspace expected to do with the information in vec? Whether
PMD or THP mappings can be used is going to depend more on the block
allocations done by the filesystem rather than anything the an
application can directly influence. Returning a vector for each page
makes some sense in the mincore() case since the application can touch
each page to fault them in, but I don't see what they can do here.

Why not just get rid of vec entirely and make mincore2() a yes/no
check over the range for whatever is supplied in flags? That would
work for NVML's use case and it should be easier to extend if needed.

Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
