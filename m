Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 354BA6B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 11:46:35 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id e11so3275459bkh.23
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 08:46:34 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cg7si12508878bkc.75.2013.11.27.08.46.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 08:46:34 -0800 (PST)
Date: Wed, 27 Nov 2013 11:45:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 6/9] mm + fs: store shadow entries in page cache
Message-ID: <20131127164544.GC3556@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-7-git-send-email-hannes@cmpxchg.org>
 <20131125231716.GJ8803@dastard>
 <20131126102053.GJ10022@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131126102053.GJ10022@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 26, 2013 at 11:20:53AM +0100, Peter Zijlstra wrote:
> On Tue, Nov 26, 2013 at 10:17:16AM +1100, Dave Chinner wrote:
> > void truncate_inode_pages_final(struct address_space *mapping)
> > {
> > 	mapping_set_exiting(mapping);
> > 	if (inode->i_data.nrpages || inode->i_data.nrshadows) {
> > 		/*
> > 		 * spinlock barrier to ensure all modifications are
> > 		 * complete before we do the final truncate
> > 		 */
> > 		spin_lock_irq(&mapping->tree_lock);
> > 		spin_unlock_irq(&mapping->tree_lock);
> 
> 	spin_unlock_wait() ?
> 
> Its cheaper, but prone to starvation; its typically useful when you're
> waiting for the last owner to go away and know there won't be any new
> ones around.

The other side is reclaim plucking pages one-by-one from the address
space in LRU order.  It'd be preferable to not starve the truncation
side, because it is much more efficient at getting rid of those pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
