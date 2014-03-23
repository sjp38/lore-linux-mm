Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id BC6676B00F5
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:35:41 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so4555416pad.0
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:35:41 -0700 (PDT)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id m8si7381804pbd.116.2014.03.23.12.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 12:33:07 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so4557017pbc.10
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:33:05 -0700 (PDT)
Date: Sun, 23 Mar 2014 12:32:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC v4] mm: prototype: rid swapoff of quadratic complexity
In-Reply-To: <20140321194141.GA14361@kelleynnn-virtual-machine>
Message-ID: <alpine.LSU.2.11.1403231218530.22062@eggly.anvils>
References: <20140321194141.GA14361@kelleynnn-virtual-machine>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>
Cc: linux-mm@kvack.org, riel@surriel.com, riel@redhat.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On Fri, 21 Mar 2014, Kelley Nielsen wrote:

> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
> 
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.
> 
> Improvement
> 
> Time took by swapoff on a swap partition containing about 240M of data,
> with about 1.1G free memory and about 520M swap available. Swap
> partition was on a laptop with a hard disk drive (not SSD).
> 
> Present implementation....about 13.8s
> Prototype.................about  5.5s

I haven't studied the patch yet (and won't manage to do so in the week
ahead), nor examined its performance; but I have taken it out for a
spin, and I'm impressed by its robustness - swap being as racy as it
is, I had expected plenty of trouble, but very little - well done.

Just three little self-explanatory fixes needed so far, all down
at the out_put end: please fold in to your next version whenever.

Hugh

--- 3.14-rc7-kn/mm/swapfile.c	2014-03-22 12:22:46.420136358 -0700
+++ linux/mm/swapfile.c	2014-03-23 07:29:59.852002968 -0700
@@ -1479,12 +1479,14 @@ out_put:
 		 * that we must not delete, since it may not have been written
 		 * out to swap yet.
 		 */
+		lock_page(page);
 		if (PageSwapCache(page) &&
-		    likely(page_private(page) == entry.val)){
-			lock_page(page);
+		    likely(page_private(page) == entry.val)) {
+			wait_on_page_writeback(page);
 			delete_from_swap_cache(page);
-			unlock_page(page);
 		}
+		unlock_page(page);
+		page_cache_release(page);
 	}
 out:
 	return retval;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
