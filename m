Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 676C16B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 16:59:06 -0400 (EDT)
Date: Tue, 20 Aug 2013 13:59:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/9] lib: radix-tree: radix_tree_delete_item()
Message-Id: <20130820135903.22edb28c2f43e0b77bf085eb@linux-foundation.org>
In-Reply-To: <1376767883-4411-2-git-send-email-hannes@cmpxchg.org>
References: <1376767883-4411-1-git-send-email-hannes@cmpxchg.org>
	<1376767883-4411-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, 17 Aug 2013 15:31:15 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Provide a function that does not just delete an entry at a given
> index, but also allows passing in an expected item.  Delete only if
> that item is still located at the specified index.
> 
> This is handy when lockless tree traversals want to delete entries as
> well because they don't have to do an second, locked lookup to verify
> the slot has not changed under them before deleting the entry.
> 
> ...
>
> -void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
> +void *radix_tree_delete_item(struct radix_tree_root *root,
> +			     unsigned long index, void *item)

radix-tree is an exported-to-modules API, so I guess we should do this
so others don't need to..

--- a/lib/radix-tree.c~lib-radix-tree-radix_tree_delete_item-fix
+++ a/lib/radix-tree.c
@@ -1393,6 +1393,7 @@ void *radix_tree_delete_item(struct radi
 out:
 	return slot;
 }
+EXPORT_SYMBOL(radix_tree_delete_item);
 
 /**
  *	radix_tree_delete    -    delete an item from a radix tree
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
