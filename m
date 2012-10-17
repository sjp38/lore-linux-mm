Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id EEE496B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 22:53:26 -0400 (EDT)
Date: Wed, 17 Oct 2012 10:53:23 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Re: Re: [PATCH 1/5] mm/readahead: Check return value of
 read_pages
Message-ID: <20121017025323.GD13769@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <dcdfd8620ae632321a28112f5074cc3c78d05bde.1348309711.git.rprabhu@wnohang.net>
 <20120922124337.GA17562@localhost>
 <20120926012503.GA24218@Archie>
 <20120928115405.GA1525@localhost>
 <20121016174705.GC2826@Archie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016174705.GC2826@Archie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org

On Tue, Oct 16, 2012 at 11:17:05PM +0530, Raghavendra D Prabhu wrote:
> Hi,
> 
> 
> * On Fri, Sep 28, 2012 at 07:54:05PM +0800, Fengguang Wu <fengguang.wu@intel.com> wrote:
> >On Wed, Sep 26, 2012 at 06:55:03AM +0530, Raghavendra D Prabhu wrote:
> >>
> >>Hi,
> >>
> >>
> >>* On Sat, Sep 22, 2012 at 08:43:37PM +0800, Fengguang Wu <fengguang.wu@intel.com> wrote:
> >>>On Sat, Sep 22, 2012 at 04:03:10PM +0530, raghu.prabhu13@gmail.com wrote:
> >>>>From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> >>>>
> >>>>Return value of a_ops->readpage will be propagated to return value of read_pages
> >>>>and __do_page_cache_readahead.
> >>>
> >>>That does not explain the intention and benefit of this patch..
> >>
> >>I noticed that force_page_cache_readahead checks return value of
> >>__do_page_cache_readahead but the actual error if any is never
> >>propagated.
> >
> >force_page_cache_readahead()'s return value, in turn, is never used by
> >its callers..
> Yes, it is not called by its callers, however, since it is called in
> a loop, shouldn't we bail out if force_page_cache_readahead fails
> once? Without the appropriate return value, it will continue  and
> in
> 
> force_page_cache_readahead
> 
> 
> 		if (err < 0) {
> 			ret = err;
> 			break;
> 		}
> 
> 	is never hit.
> Nor does the other __do_page_cache_readahead() callers

That sounds all reasonable, but please don't change the meaning of
__do_page_cache_readahead()'s return value. It should always return
the number of new pages put to IO, which will be used by some
readahead tracing/accounting feature. So it will need another parameter
for passing the error code from ->readpages(). However since the major
filesystems always return 0 in ->readpages(), I'm not sure it worth
the efforts.

Thanks,
Fengguang

> >care about the error state. So until we find an actual user of the
> >error code, I'd recommend to avoid changing the current code.
> >
> >Thanks,
> >Fengguang
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
