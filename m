Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B28926B007E
	for <linux-mm@kvack.org>; Thu, 12 May 2016 13:27:25 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so27151203lfq.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 10:27:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 198si12447767wmj.9.2016.05.12.10.27.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 10:27:24 -0700 (PDT)
Date: Thu, 12 May 2016 19:27:22 +0200
From: Jan Kara <jack@suse.cz>
Subject: Use after free in workingset LRU handling
Message-ID: <20160512172722.GC30647@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

Hello,

when testing recent DAX fixes, I was puzzled by shadow_lru_isolate()
barfing on radix tree nodes attached to DAX mappings (as DAX mappings have
no shadow entries and I took care to not insert radix tree nodes for such
mappings into workingset_shadow_nodes LRU list. After some investigation, I
think there is a use after free issue in the handling of radix tree nodes
by workingset code. The following seems to be possible:

Radix tree node is created, is has two page pointers for indices 0 and 1.

Page pointer for index 0 gets replaced with a shadow entry, radix tree
node gets inserted into workingset_shadow_nodes

Truncate happens removing page at index 1, __radix_tree_delete_node() in
page_cache_tree_delete() frees the radix tree node (as it has only single
entry at index 0 and thus we can shrink the tree) while it is still in LRU
list!

Am I missing something? I'm not sure how to best fix this issue since the
shrinking / expanding of the radix tree is fully under control of
lib/radix-tree.c which is completely agnostic to the private_list used by
mm/workingset.c... Maybe we'd need some callback when radix tree node gets
freed?

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
