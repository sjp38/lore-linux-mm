Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90AB26B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 13:59:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so3847918wmd.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:59:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si10843911wmf.274.2017.10.11.10.59.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 10:59:49 -0700 (PDT)
Date: Wed, 11 Oct 2017 18:59:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171011175945.nmlkso3fi6kqmhnu@suse.de>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
 <20171011080658.GK3667@quack2.suse.cz>
 <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Wed, Oct 11, 2017 at 10:34:47AM -0700, Dave Hansen wrote:
> On 10/11/2017 01:06 AM, Jan Kara wrote:
> >>> when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
> >>> have noticed a regression in bonnie++ benchmark when deleting files.
> >>> Eventually we have tracked this down to a fact that page cache truncation got
> >>> slower by about 10%. There were both gains and losses in the above interval of
> >>> kernels but we have been able to identify that commit 83929372f629 "filemap:
> >>> prepare find and delete operations for huge pages" caused about 10% regression
> >>> on its own.
> >> It's odd that just checking if some pages are huge should be that
> >> expensive, but ok ..
> > Yeah, I was surprised as well but profiles were pretty clear on this - part
> > of the slowdown was caused by loads of page->_compound_head (PageTail()
> > and page_compound() use that) which we previously didn't have to load at
> > all, part was in hpage_nr_pages() function and its use.
> 
> Well, page->_compound_head is part of the same cacheline as the rest of
> the page, and the page is surely getting touched during truncation at
> _some_ point.  The hpage_nr_pages() might cause the cacheline to get
> loaded earlier than before, but I can't imagine that it's that expensive.

Profiles appear to disagree but regardless of the explanation, the fact
is that the series improves truncation quite a bit on my tests. From three
separate machines running bonnie, I see the following gains.

                                      4.14.0-rc4             4.14.0-rc4
                                         vanilla          janbatch-v1r1
Hmean     SeqCreate del      21313.45 (   0.00%)    24963.95 (  17.13%)
Hmean     RandCreate del     19974.03 (   0.00%)    23377.66 (  17.04%)

                                      4.14.0-rc4             4.14.0-rc4
                                         vanilla          janbatch-v1r1
Hmean     SeqCreate del       4408.80 (   0.00%)     5074.91 (  15.11%)
Hmean     RandCreate del      4161.52 (   0.00%)     4879.15 (  17.24%)

                                      4.14.0-rc4             4.14.0-rc4
                                         vanilla          janbatch-v1r1
Hmean     SeqCreate del      11639.73 (   0.00%)    13648.20 (  17.26%)
Hmean     RandCreate del     10979.90 (   0.00%)    12818.99 (  16.75%)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
