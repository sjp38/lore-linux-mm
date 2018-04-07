Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEB96B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 22:28:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k2so1625365pfi.23
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 19:28:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l75si8961502pfj.375.2018.04.06.19.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 19:28:50 -0700 (PDT)
Date: Fri, 6 Apr 2018 19:28:49 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: find_swap_entry sparse cleanup
Message-ID: <20180407022849.GA24377@bombadil.infradead.org>
References: <ffad6db6-85b1-59b2-bc5e-5492d1c175ac@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffad6db6-85b1-59b2-bc5e-5492d1c175ac@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org

On Fri, Apr 06, 2018 at 03:13:45PM -0700, Mike Kravetz wrote:
> As part of restructuring code for memfd, I want clean up all the
> sparse warnings in mm/shmem.c.  Most are straight forward, but I
> am not sure about find_swap_entry.  Specifically the code:
> 
> 	rcu_read_lock();
> 	radix_tree_for_each_slot(slot, root, &iter, 0) {
> 		if (*slot == item) {
> 			found = iter.index;
> 			break;
> 		}
> 		checked++;
> 		if ((checked % 4096) != 0)
> 			continue;
> 		slot = radix_tree_iter_resume(slot, &iter);
> 		cond_resched_rcu();
> 	}
> 	rcu_read_unlock();
> 
> The complaint is about that (*slot == item) comparison.
> 
> My first thought was to do the radix_tree_deref_slot(),
> radix_tree_exception(), radix_tree_deref_retry() thing.
> However, I was concerned that swap entries (which this routine
> is looking for) are stored as exception entries?  So, perhaps
> this should just use rcu_dereference_raw()?
> 
> Suggestions would be appreciated.
> 
> And, yes I do know that the XArray code would replace all this.

I'm happy to help clean this up in advance of the XArray code going in ...

This loop is actually buggy in two or three different ways.  Here's how
it should have looked:

@@ -1098,13 +1098,18 @@ static void shmem_evict_inode(struct inode *inode)
 static unsigned long find_swap_entry(struct radix_tree_root *root, void *item)
 {
        struct radix_tree_iter iter;
-       void **slot;
+       void __rcu **slot;
        unsigned long found = -1;
        unsigned int checked = 0;
 
        rcu_read_lock();
        radix_tree_for_each_slot(slot, root, &iter, 0) {
-               if (*slot == item) {
+               void *entry = radix_tree_deref_slot(slot);
+               if (radix_tree_deref_retry(entry)) {
+                       slot = radix_tree_iter_retry(&iter);
+                       continue;
+               }
+               if (entry == item) {
                        found = iter.index;
                        break;
                }
