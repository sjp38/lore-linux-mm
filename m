Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 179588E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:24:58 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a9so1212319pla.2
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:24:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor4047489plk.32.2019.01.15.00.24.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 00:24:56 -0800 (PST)
Date: Tue, 15 Jan 2019 11:24:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Message-ID: <20190115082450.stl6vlrgbvikbwzq@kshutemo-mobl1>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
 <ad3a53ba-82e2-2dc7-1cd2-feef7def0bc3@oracle.com>
 <50c6abdc-b906-d16a-2f8f-8647b3d129aa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50c6abdc-b906-d16a-2f8f-8647b3d129aa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux_lkml_grp@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 14, 2019 at 10:54:45AM -0800, Mike Kravetz wrote:
> On 1/14/19 7:35 AM, Steven Sistare wrote:
> > On 1/11/2019 6:28 PM, Mike Kravetz wrote:
> >> On 1/11/19 1:55 PM, Kirill A. Shutemov wrote:
> >>> On Fri, Jan 11, 2019 at 08:10:03PM +0000, Mike Kravetz wrote:
> >>>> At LPC last year, Boaz Harrosh asked why he had to 'jump through hoops'
> >>>> to get an address returned by mmap() suitably aligned for THP.  It seems
> >>>> that if mmap is asking for a mapping length greater than huge page
> >>>> size, it should align the returned address to huge page size.
> > 
> > A better heuristic would be to return an aligned address if the length
> > is a multiple of the huge page size.  The gap (if any) between the end of
> > the previous VMA and the start of this VMA would be filled by subsequent
> > smaller mmap requests.  The new behavior would need to become part of the
> > mmap interface definition so apps can rely on it and omit their hoop-jumping
> > code.
> 
> Yes, the heuristic really should be 'length is a multiple of the huge page
> size'.  As you mention, this would still leave gaps.  I need to look closer
> but this may not be any worse than the trick of mapping an area with rounded
> up length and then unmapping pages at the beginning.

The question why is it any better. Virtual address space is generally
cheap, additional VMA maybe more signficiant due to find_vma() overhead.

And you don't *need* to unmap anything. Just use alinged pointer.

> 
> When I sent this out, the thought in the back of my mind was that this doesn't
> really matter unless there is some type of alignment guarantee.  Otherwise,
> user space code needs continue employing their code to check/force alignment.
> Making matters somewhat worse is that I do not believe there is C interface to
> query huge page size.  I thought there was discussion about adding one, but I
> can not find it.

We have posix_memalign(3).


-- 
 Kirill A. Shutemov
