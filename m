Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 118E46B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 16:42:46 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id u57so6439997wes.3
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:42:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x8si55488632wju.127.2014.07.08.13.42.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 13:42:45 -0700 (PDT)
Date: Tue, 8 Jul 2014 16:41:32 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 1/3] mm: introduce fincore()
Message-ID: <20140708204132.GA16195@nhori.redhat.com>
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404756006-23794-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <53BAEE95.50807@intel.com>
 <20140708190326.GA28595@nhori>
 <53BC49C2.8090409@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BC49C2.8090409@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Kees Cook <kees@outflux.net>

On Tue, Jul 08, 2014 at 12:42:58PM -0700, Dave Hansen wrote:
> On 07/08/2014 12:03 PM, Naoya Horiguchi wrote:
> >> > The biggest question for me, though, is whether we want to start
> >> > designing these per-page interfaces to consider different page sizes, or
> >> > whether we're going to just continue to pretend that the entire world is
> >> > 4k pages.  Using FINCORE_BMAP on 1GB hugetlbfs files would be a bit
> >> > silly, for instance.
> > I didn't answer this question, sorry.
> > 
> > In my option, hugetlbfs pages should be handled as one hugepage (not as
> > many 4kB pages) to avoid lots of meaningless data transfer, as you pointed
> > out. And the current patch already works like that.
> 
> Just reading the code, I don't see any way that pc_shift gets passed
> down in to the do_fincore() loop.

No need to pass it down because operations over page cache tree use
page index internally to identify the in-file position and doesn't care
about page size. In 2MB hugetlbfs file, for example, index 1 means
byte offset 2MB (not offset 4kB.) So radix_tree_for_each_slot() runs
iter.index like 0 -> 1 -> 2 ... (instead of 0 -> 512 -> 1024 ...)

>  I don't see it getting reflected in
> to 'nr' or 'nr_pages' in there, and I can't see how:
> 
> 	jump = iter.index - fc->pgstart - nr;
> 
> can possibly be right since iter.index is being kept against the offset
> in the userspace buffer (4k pages) and 'nr' and fc->pgstart are
> essentially done in the huge page size.

... so all of iter.index, fc->pgstart, and nr is the same unit,
index (in hugepage size.) 
This is a pure index calculation, and do_fincore() is exactly the same
between 4kB pages and hugetlbfs pages.

> If you had a 2-page 1GB-hpage_size() hugetlbfs file, you would only have
> two pages in the radix tree, and only two iterations of
> radix_tree_for_each_slot().

Correct.

>  It would only set the first two bytes of a
> 256k BMAP buffer since only two pages were encountered in the radix tree.

Hmm, this example shows me a problem, thanks.

If the user knows the fd is for 1GB hugetlbfs file, it just prepares
the 2 bytes buffer, so no problem.
But if the user doesn't know whether the fd is from hugetlbfs file,
the user must prepare the large buffer, though only first few bytes
are used. And the more problematic is that the user could interpret
the data in buffer differently:
  1. only the first two 4kB-pages are loaded in the 2GB range,
  2. two 1GB-pages are loaded.
So for such callers, fincore() must notify the relevant page size
in some way on return.
Returning it via fincore_extra is my first thought but I'm not sure
if it's elegant enough.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
