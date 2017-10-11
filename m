Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECBAF6B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:07:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v78so2741070pgb.4
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 01:07:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s1si9658270pge.122.2017.10.11.01.06.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 01:07:00 -0700 (PDT)
Date: Wed, 11 Oct 2017 10:06:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171011080658.GK3667@quack2.suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878tgisyo6.fsf@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Tue 10-10-17 10:25:13, Andi Kleen wrote:
> Jan Kara <jack@suse.cz> writes:
> 
> > when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
> > have noticed a regression in bonnie++ benchmark when deleting files.
> > Eventually we have tracked this down to a fact that page cache truncation got
> > slower by about 10%. There were both gains and losses in the above interval of
> > kernels but we have been able to identify that commit 83929372f629 "filemap:
> > prepare find and delete operations for huge pages" caused about 10% regression
> > on its own.
> 
> It's odd that just checking if some pages are huge should be that
> expensive, but ok ..

Yeah, I was surprised as well but profiles were pretty clear on this - part
of the slowdown was caused by loads of page->_compound_head (PageTail()
and page_compound() use that) which we previously didn't have to load at
all, part was in hpage_nr_pages() function and its use.

> > Patch 1 is an easy speedup of cancel_dirty_page(). Patches 2-6 refactor page
> > cache truncation code so that it is easier to batch radix tree operations.
> > Patch 7 implements batching of deletes from the radix tree which more than
> > makes up for the original regression.
> >
> > What do people think about this series?
> 
> Batching locks is always a good idea. You'll likely see far more benefits
> under lock contention on larger systems.
> 
> From a quick read it looks good to me.
> 
> Reviewed-by: Andi Kleen <ak@linux.intel.com>

Thanks for having a look!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
