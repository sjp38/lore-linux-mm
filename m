Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C3BC6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 21:52:51 -0500 (EST)
Received: by yxe10 with SMTP id 10so1601760yxe.12
        for <linux-mm@kvack.org>; Wed, 16 Dec 2009 18:52:49 -0800 (PST)
Date: Thu, 17 Dec 2009 11:46:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Question about pte_offset_map_lock
Message-Id: <20091217114630.d353907a.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

It may be a dumb question.

As I read the code of pte_lock, I have a question. 
Now, there is pte_offset_map_lock following as. 

#define pte_offset_map_lock(mm, pmd, address, ptlp)     \
({                                                      \
        spinlock_t *__ptl = pte_lockptr(mm, pmd);       \
        pte_t *__pte = pte_offset_map(pmd, address);    \
        *(ptlp) = __ptl;                                \
        spin_lock(__ptl);                               \
        __pte;                                          \
})

Why do we grab the lock after getting __pte?
Is it possible that __pte might be changed before we grab the spin_lock?

Some codes in mm checks original pte by pte_same. 
There are not-checked cases in proc. As looking over the cases,
It seems no problem. But in future, new user of pte_offset_map_lock 
could mistake with that?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
