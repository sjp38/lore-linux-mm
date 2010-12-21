Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8CBDD6B0089
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 00:59:59 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id oBL5xubO015901
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 21:59:56 -0800
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by wpaz5.hot.corp.google.com with ESMTP id oBL5xsOQ020609
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 21:59:55 -0800
Received: by pvb32 with SMTP id 32so787588pvb.21
        for <linux-mm@kvack.org>; Mon, 20 Dec 2010 21:59:54 -0800 (PST)
Date: Mon, 20 Dec 2010 21:59:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] writeback: skip balance_dirty_pages() for in-memory fs
In-Reply-To: <20101217112111.GA8323@localhost>
Message-ID: <alpine.LSU.2.00.1012202127310.16112@tigran.mtv.corp.google.com>
References: <20101213144646.341970461@intel.com> <20101213150329.002158963@intel.com> <20101217021934.GA9525@localhost> <alpine.LSU.2.00.1012162239270.23229@sister.anvils> <20101217112111.GA8323@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010, Wu Fengguang wrote:

> This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.
> 
> It also prevents
> 
> [  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
> 
> in the balance_dirty_pages tracepoint, which will call
> 
> 	dev_name(mapping->backing_dev_info->dev)
> 
> but shmem_backing_dev_info.dev is NULL.
> 
> CC: Hugh Dickins <hughd@google.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Whilst I do like this change, and I do think it's the right thing to do
(given that the bdi has explicitly opted out of what it then got into),
I've a sneaking feeling that something somewhere may show a regression
from it.  IIRC, there were circumstances in which it actually did
(inadvertently) end up throttling the tmpfs writing - if there were
too many dirty non-tmpfs pages around??

What am I saying?!  I think I'm asking you to look more closely at what
actually used to happen, and be more explicit about the behavior you're
stopping here - although the patch is mainly code optimization, there
is some functional change I think.  (You do mention throttling on
tmpfs/ramfs, but the way it worked out wasn't straightforward.)

I'd better not burble on for a third paragraph!

Hugh

> ---
>  mm/page-writeback.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-12-17 19:09:19.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-12-17 19:09:22.000000000 +0800
> @@ -899,6 +899,9 @@ void balance_dirty_pages_ratelimited_nr(
>  {
>  	struct backing_dev_info *bdi = mapping->backing_dev_info;
>  
> +	if (!bdi_cap_account_dirty(bdi))
> +		return;
> +
>  	current->nr_dirtied += nr_pages_dirtied;
>  
>  	if (unlikely(!current->nr_dirtied_pause))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
