Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 980B76B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 12:55:44 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so550896wiv.2
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:55:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lk19si5172725wic.103.2014.07.11.09.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 09:55:06 -0700 (PDT)
Date: Fri, 11 Jul 2014 12:53:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 1/3] mm: introduce fincore()
Message-ID: <20140711165335.GA8877@nhori.bos.redhat.com>
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404756006-23794-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <53BAEE95.50807@intel.com>
 <20140708190326.GA28595@nhori>
 <53BC49C2.8090409@intel.com>
 <20140708204132.GA16195@nhori.redhat.com>
 <53BC717E.6020705@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BC717E.6020705@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jul 08, 2014 at 03:32:30PM -0700, Dave Hansen wrote:
> On 07/08/2014 01:41 PM, Naoya Horiguchi wrote:
> >> >  It would only set the first two bytes of a
> >> > 256k BMAP buffer since only two pages were encountered in the radix tree.
> > Hmm, this example shows me a problem, thanks.
> > 
> > If the user knows the fd is for 1GB hugetlbfs file, it just prepares
> > the 2 bytes buffer, so no problem.
> > But if the user doesn't know whether the fd is from hugetlbfs file,
> > the user must prepare the large buffer, though only first few bytes
> > are used. And the more problematic is that the user could interpret
> > the data in buffer differently:
> >   1. only the first two 4kB-pages are loaded in the 2GB range,
> >   2. two 1GB-pages are loaded.
> > So for such callers, fincore() must notify the relevant page size
> > in some way on return.
> > Returning it via fincore_extra is my first thought but I'm not sure
> > if it's elegant enough.
> 
> That does limit the interface to being used on a single page size per
> call, which doesn't sound too bad since we don't mix page sizes in a
> single file.  But, you mentioned using this interface along with
> /proc/$pid/mem.  How would this deal with a process which had two sizes
> of pages mapped?

Hmm, we should handle everything (including hugetlbfs) in 4kB page in
BMAP mode, because the position of the data in user buffer has the meaning.
And maybe it should be the case basically for in extensible modes, but
only in FINCORE_PGOFF mode (where no data of holes is passed to userspace,
and per-page entry contains offset information, so the in-buffer position
doesn't mean anything,) we can skip tail pages in the natural manner.

In this approach, fincore(FINCORE_PGOFF) returns not only pgoff, but also
page order (encoded in highest bits in pgoff field?). The callers must be
prepared to handle different page sizes.

So if users want to avoid lots of tail data for hugetlbfs pages,
using FINCORE_PGOFF mode is recommended for them.

That allows us to handle regular files, hugetlbfs files and /proc/$pid/mem
consistently.

> Another option would be to have userspace pass in its desired
> granularity.  Such an interface could be used to find holes in a file
> fairly easily.  But, introduces a whole new set of issues, like what
> BMAP means if only a part of the granule is in-core, and do you need a
> new option to differentiate BMAP_AND vs. BMAP_OR operations.

I don't see exactly what you mention here, but I agree that it makes
more complexity and might not be easy to keep code maintenability.

> I honestly think we need to take a step back and enumerate what you're
> trying to do here before going any further.

OK, I try it. (Please correct/add if you find something I should)

What: typical usecases is like below:
 1. mincore()'s variant for page cache. Exporting residency information
    (PageUpdate) is required.
 2. Helping IO control from userspace. Exporting relevant page flags
    (PageDirty and PageWriteback, or others if needed) and NUMA node
    information is required.
 3. Error page check. This is an essential part of "error reporting" patchset
    I'm developing now, where I make error information sticky on page cache
    tree to let userspace take proper actions (the final goal is to avoid
    consuming corrupted data.) Exporting PageError is required.
 4. (debugging) Page offset to PFN translation. This is for debugging,
    so should be available only for privileged users.

How: attempt to do these better:
 - extensiblility. As we experience now on mincore(), Page residency
   information is not enough (for example to predict necessity of fsync.)
   We want to avoid adding new syscalls per future requirements of new
   information.
 - efficiency. For handling large (sparse) files and/or hugepages, BMAP
   type interface is not optimal, so "table" type interface is useful
   to avoid meaningless data transfer. 


Considering the objection for exporting bare page flags from Christoph,
I'm thinking that we had better export some "translated" page flags.
For example, we now only export residency info, so let's define it
as FINCORE_RESIDENCY bit, and let's define FINCORE_NEEDSYNC, which
makes kernel to export a bit of PageDirty && !PageWriteback.
Maybe we can combine them if we like, and if we do, the user buffer will
be filled with 2 bit entries per page on return.
This is extensible and the memory footprint is minimum.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
