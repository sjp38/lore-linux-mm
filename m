Message-ID: <379795533.26423@ustc.edu.cn>
Date: Tue, 22 May 2007 08:59:03 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: [RFC 10/16] Variable Order Page Cache: Readahead fixups
Message-ID: <20070522005903.GA6184@mail.ustc.edu.cn>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com> <20070423064937.5458.59638.sendpatchset@schroedinger.engr.sgi.com> <20070425113613.GF19942@skynet.ie> <Pine.LNX.4.64.0704250854420.24530@schroedinger.engr.sgi.com> <379744113.16390@ustc.edu.cn> <Pine.LNX.4.64.0705210947450.25871@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705210947450.25871@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Dave Hansen <hansendc@us.ibm.com>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

On Mon, May 21, 2007 at 09:53:18AM -0700, Christoph Lameter wrote:
> On Mon, 21 May 2007, Fengguang Wu wrote:
> 
> > > I am not sure how to solve that one yet. With the above fix we stay at the 
> > > 2M sized readahead. As the compound order increases so the number of pages
> > > is reduced. We could keep the number of pages constant but then very high
> > > orders may cause a excessive use of memory for readahead.
> > 
> > Do we need to support very high orders(i.e. >2MB)?
> 
> Yes actually we could potentially be using up to 1 TB page size on our 
> new machines that can support several petabytes of RAM. But the read 
> ahead is likely irrelevant in that case. And this is an extreme case that 
> will be rarely used but a customer has required that we will be able to 
> handle such a situation. I think 2-4 megabytes may be more typical.

hehe, 1TB page size is amazing.

> > If not, we can define a MAX_PAGE_CACHE_SIZE=2MB, and limit page orders
> > under that threshold. Now large readahead can be done in
> > MAX_PAGE_CACHE_SIZE chunks.
> 
> Maybe we can just logarithmically decrease the pages for readahead? 
> Readahead should possibly depend on the overall memory of the machine. If 
> the machine has several terabytes of main memory then a couple megs of 
> readahead may be necessary.

Readahead size can be easily scale down by:

 void file_ra_state_init(struct file_ra_state *ra, struct address_space *mapping)
 {
-       ra->ra_pages = mapping->backing_dev_info->ra_pages;
+       ra->ra_pages = DIV_ROUND_UP(mapping->backing_dev_info->ra_pages,
+                                   page_cache_size(mapping));
        ra->prev_index = -1;
 }


But it's not about simply decreasing/disabling readahead.

The problem is, we at least bring in one page at a time.
It's not a problem for 2-4MB page sizes.
But to support page size up to 1TB, this behavior must be changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
