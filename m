Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 464E96B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 18:14:09 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o2-v6so1873475plk.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 15:14:09 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u1-v6si10383307plj.409.2018.04.06.15.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 15:14:07 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: find_swap_entry sparse cleanup
Message-ID: <ffad6db6-85b1-59b2-bc5e-5492d1c175ac@oracle.com>
Date: Fri, 6 Apr 2018 15:13:45 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org


As part of restructuring code for memfd, I want clean up all the
sparse warnings in mm/shmem.c.  Most are straight forward, but I
am not sure about find_swap_entry.  Specifically the code:

	rcu_read_lock();
	radix_tree_for_each_slot(slot, root, &iter, 0) {
		if (*slot == item) {
			found = iter.index;
			break;
		}
		checked++;
		if ((checked % 4096) != 0)
			continue;
		slot = radix_tree_iter_resume(slot, &iter);
		cond_resched_rcu();
	}
	rcu_read_unlock();

The complaint is about that (*slot == item) comparison.

My first thought was to do the radix_tree_deref_slot(),
radix_tree_exception(), radix_tree_deref_retry() thing.
However, I was concerned that swap entries (which this routine
is looking for) are stored as exception entries?  So, perhaps
this should just use rcu_dereference_raw()?

Suggestions would be appreciated.

And, yes I do know that the XArray code would replace all this.
-- 
Mike Kravetz
