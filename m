Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 558006B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:40:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 204so3712876wmy.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:40:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 30si146571wri.162.2017.05.31.08.40.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 08:40:23 -0700 (PDT)
Date: Wed, 31 May 2017 08:40:10 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [RFC v2 01/10] mm: Deactivate mmap_sem assert
Message-ID: <20170531154010.GA28615@linux-80c1.suse>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1495624801-8063-2-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1495624801-8063-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi Laurent!

On Wed, 24 May 2017, Laurent Dufour wrote:

>When mmap_sem will be moved to a range lock, some assertion done in
>the code will have to be reviewed to work with the range locking as
>well.
>
>This patch disables these assertions for the moment but it has be
>reviewed later once the range locking API will provide the dedicated
>services.

Lets not do this; we should _at least_ provide the current checks
we already have. The following should be a (slower) equivalent once
we have the interval_tree_iter_first() optimization sorted out.

int range_is_locked(struct range_lock_tree *tree, struct range_lock *lock)
{
	unsigned long flags;
	struct interval_tree_node *node;

	spin_lock_irqsave(&tree->lock, flags);
	node = interval_tree_iter_first(&tree->root, lock->node.start,
					lock->node.last);
	spin_unlock_irqrestore(&tree->lock, flags);

	return node != NULL;
}
EXPORT_SYMBOL_GPL(range_is_locked);

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
