Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2451A6B003B
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 05:21:23 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id ii20so4175517qab.2
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 02:21:22 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ik2si10730739qab.12.2013.11.26.02.21.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Nov 2013 02:21:22 -0800 (PST)
Date: Tue, 26 Nov 2013 11:20:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 6/9] mm + fs: store shadow entries in page cache
Message-ID: <20131126102053.GJ10022@twins.programming.kicks-ass.net>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-7-git-send-email-hannes@cmpxchg.org>
 <20131125231716.GJ8803@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125231716.GJ8803@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 26, 2013 at 10:17:16AM +1100, Dave Chinner wrote:
> void truncate_inode_pages_final(struct address_space *mapping)
> {
> 	mapping_set_exiting(mapping);
> 	if (inode->i_data.nrpages || inode->i_data.nrshadows) {
> 		/*
> 		 * spinlock barrier to ensure all modifications are
> 		 * complete before we do the final truncate
> 		 */
> 		spin_lock_irq(&mapping->tree_lock);
> 		spin_unlock_irq(&mapping->tree_lock);

	spin_unlock_wait() ?

Its cheaper, but prone to starvation; its typically useful when you're
waiting for the last owner to go away and know there won't be any new
ones around.

> 		truncate_inode_pages_range(mapping, 0, (loff_t)-1);
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
