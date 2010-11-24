Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 157F86B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 05:43:36 -0500 (EST)
Date: Wed, 24 Nov 2010 18:43:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 03/13] writeback: per-task rate limit on
 balance_dirty_pages()
Message-ID: <20101124104331.GA6096@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042849.650810571@intel.com>
 <1290594187.2072.440.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290594187.2072.440.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 06:23:07PM +0800, Peter Zijlstra wrote:
> On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> > +       if (unlikely(current->nr_dirtied >= current->nr_dirtied_pause ||
> > +                    bdi->dirty_exceeded)) {
> > +               balance_dirty_pages(mapping, current->nr_dirtied);
> > +               current->nr_dirtied = 0;
> >         } 
> 
> Was it a conscious choice to use
>   current->nr_dirtied = 0
> over 
>   current->nr_dirtied -= current->nr_dirtied_pause
> ?
> 
> The former will cause a drift in pause times due to truncation of the
> excess.

It should be fine in either way, as long as the "truncated" number is
passed to balance_dirty_pages():

+               balance_dirty_pages(mapping, current->nr_dirtied);
+               current->nr_dirtied = 0;

or

+               balance_dirty_pages(mapping, current->nr_dirtied_pause);
+               current->nr_dirtied -= current->nr_dirtied_pause;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
