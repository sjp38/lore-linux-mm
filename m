Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB016B04A0
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:17:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k126so158933wmd.5
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:17:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 69si1608845wrk.16.2018.01.03.16.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 16:17:56 -0800 (PST)
Date: Wed, 3 Jan 2018 16:17:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also
 eof
Message-Id: <20180103161753.8b22d32d640f6e0be4119081@linux-foundation.org>
In-Reply-To: <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
	<8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
	<20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "??????(Caspar)" <jinli.zjl@alibaba-inc.com>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "??????(??????)" <zhiche.yy@alibaba-inc.com>, ?????? <shidao.ytt@alibaba-inc.com>

On Wed, 3 Jan 2018 10:48:00 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Jan 03, 2018 at 02:53:43PM +0800, ??????(Caspar) wrote:
> > 
> > 
> > > ?? 2017??12??23????12:16?????? <shidao.ytt@alibaba-inc.com> ??????
> > > 
> > > From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>
> > > 
> > > in commit 441c228f817f7 ("mm: fadvise: document the
> > > fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
> > > explained why partial pages should be preserved instead of discarded
> > > when using fadvise(FADV_DONTNEED), however the actual codes to calcuate
> > > end_index was unexpectedly wrong, the code behavior didn't match to the
> > > statement in comments; Luckily in another commit 18aba41cbf
> > > ("mm/fadvise.c: do not discard partial pages with POSIX_FADV_DONTNEED")
> > > Oleg Drokin fixed this behavior
> > > 
> > > Here I come up with a new idea that actually we can still discard the
> > > last parital page iff the page-unaligned endbyte is also the end of
> > > file, since no one else will use the rest of the page and it should be
> > > safe enough to discard.
> > 
> > +akpm...
> > 
> > Hi Mel, Andrew:
> > 
> > Would you please take a look at this patch, to see if this proposal
> > is reasonable enough, thanks in advance!
> > 
> 
> I'm backlogged after being out for the Christmas. Superficially the patch
> looks ok but I wondered how often it happened in practice as we already
> would discard files smaller than a page on DONTNEED. It also requires
> that the system call get the exact size of the file correct and would not
> discard if the off + len was past the end of the file for whatever reason
> (e.g. a stat to read the size, a truncate in parallel and fadvise using
> stale data from stat) and that's why the patch looked like it might have
> no impact in practice. Is the patch known to help a real workload or is
> it motivated by a code inspection?

The current whole-pages-only logic was introduced (accidentally, I
think) by yours truly when fixing a bug in the initial fadvise()
commit in 2003. 

https://kernel.opensuse.org/cgit/kernel/commit/?h=v2.6.0-test4&id=7161ee20fea6e25a32feb91503ca2b7c7333c886

Namely:

: invalidate_mapping_pages() takes start/end, but fadvise is currently passing
: it start/len.
: 
: 
: 
:  mm/fadvise.c |    8 ++++++--
:  1 files changed, 6 insertions(+), 2 deletions(-)
: 
: diff -puN mm/fadvise.c~fadvise-fix mm/fadvise.c
: --- 25/mm/fadvise.c~fadvise-fix	2003-08-14 18:16:12.000000000 -0700
: +++ 25-akpm/mm/fadvise.c	2003-08-14 18:16:12.000000000 -0700
: @@ -26,6 +26,8 @@ long sys_fadvise64(int fd, loff_t offset
:  	struct inode *inode;
:  	struct address_space *mapping;
:  	struct backing_dev_info *bdi;
: +	pgoff_t start_index;
: +	pgoff_t end_index;
:  	int ret = 0;
:  
:  	if (!file)
: @@ -65,8 +67,10 @@ long sys_fadvise64(int fd, loff_t offset
:  	case POSIX_FADV_DONTNEED:
:  		if (!bdi_write_congested(mapping->backing_dev_info))
:  			filemap_flush(mapping);
: -		invalidate_mapping_pages(mapping, offset >> PAGE_CACHE_SHIFT,
: -				(len >> PAGE_CACHE_SHIFT) + 1);
: +		start_index = offset >> PAGE_CACHE_SHIFT;
: +		end_index = (offset + len + PAGE_CACHE_SIZE - 1) >>
: +						PAGE_CACHE_SHIFT;
: +		invalidate_mapping_pages(mapping, start_index, end_index);
:  		break;
:  	default:
:  		ret = -EINVAL;
: 

So I'm not sure that the whole "don't discard partial pages" thing is
well-founded and I see no reason why we cannot alter it.

So, thinking caps on: why not just discard them?  After all, that's
what userspace asked us to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
