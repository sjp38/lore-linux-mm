Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 850786B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:06:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z80so6383285pff.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 14:06:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a15si11350384pll.406.2017.10.11.14.06.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 14:06:17 -0700 (PDT)
Date: Wed, 11 Oct 2017 23:06:13 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171011210613.GQ3667@quack2.suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
 <20171011080658.GK3667@quack2.suse.cz>
 <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Wed 11-10-17 10:34:47, Dave Hansen wrote:
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

Then my intuition matches yours ;) but profiles disagree. That being said
I'm not really expert in CPU microoptimizations and profiling so feel free
to gather perf profiles yourself before and after commit 83929372f629 and
get better explanation of where the cost is - I would be really curious
what you come up with because the explanation I have disagrees with my
intuition as well...
								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
