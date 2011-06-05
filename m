Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6D7356B0104
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 03:54:07 -0400 (EDT)
Date: Sun, 5 Jun 2011 15:54:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Setting of the PageReadahed bit
Message-ID: <20110605075403.GA18000@localhost>
References: <20110603115519.GI4061@linux.intel.com>
 <BANLkTimc7wTyn0sVn+4OCL45_MOqhyV=QhJqV-GgXt_p290KwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTimc7wTyn0sVn+4OCL45_MOqhyV=QhJqV-GgXt_p290KwA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm <linux-mm@kvack.org>

On Sat, Jun 04, 2011 at 11:15:38AM +0800, Hugh Dickins wrote:
> On Fri, Jun 3, 2011 at 4:55 AM, Matthew Wilcox <willy@linux.intel.com> wrote:
> > The exact definition of PageReadahead doesn't seem to be documented
> > anywhere. A I'm assuming it means "This page was not directly requested;
> > it is being read for prefetching purposes", exactly like the READA
> > semantics.
> >
> > If my interpretation is correct, then the implementation in
> > __do_page_cache_readahead is wrong:
> >
> > A  A  A  A  A  A  A  A if (page_idx == nr_to_read - lookahead_size)
> > A  A  A  A  A  A  A  A  A  A  A  A SetPageReadahead(page);
> >
> > It'll only set the PageReadahead bit on one page. A The patch below fixes
> > this ... if my understanding is correct.
> 
> Incorrect I believe: it's a trigger to say, when you get this far,
> it's time to think about kicking off the next read.

That's right. PG_readahead is set to trigger the _next_ ASYNC readahead.

> >
> > If my understanding is wrong, then how are readpage/readpages
> > implementations supposed to know that the VM is only prefetching these
> > pages, and they're not as important as metadata (dependent) reads?
> 
> I don't think they do know at present; but I can well imagine there
> may be advantage in them knowing.

__do_page_cache_readahead() don't know whether the _current_ readahead
IO is an ASYNC one.

page_cache_async_readahead() calls ondemand_readahead() with
hit_readahead_marker=true. It's possible to further pass this
information into __do_page_cache_readahead() and ->readpage/readpages.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
