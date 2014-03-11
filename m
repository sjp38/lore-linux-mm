Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 282B66B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 17:45:27 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so136119pbb.14
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:45:26 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id sh5si252884pbc.80.2014.03.11.14.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 14:45:26 -0700 (PDT)
Message-ID: <1394574323.2786.45.camel@buesod1.americas.hpqcorp.net>
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 11 Mar 2014 14:45:23 -0700
In-Reply-To: <531F79F7.5090201@oracle.com>
References: <531F6689.60307@oracle.com>
			<1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
		 <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
		 <531F75D1.3060909@oracle.com>
	 <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
	 <531F79F7.5090201@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2014-03-11 at 17:02 -0400, Sasha Levin wrote:
> On 03/11/2014 04:47 PM, Davidlohr Bueso wrote:
> >> Bingo! With the above patch:
> >> >
> >> >[  243.565794] kernel BUG at mm/vmacache.c:76!
> >> >[  243.566720] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> >> >[  243.568048] Dumping ftrace buffer:
> >> >[  243.568740]    (ftrace buffer empty)
> >> >[  243.569481] Modules linked in:
> >> >[  243.570203] CPU: 10 PID: 10073 Comm: trinity-c332 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00010-g1f812cb-dirty #143
> > and this is also part of the DEBUG_PAGEALLOC + trinity combo! I suspect
> > the root cause it the same as Fengguang's report.
> 
> The BUG still happens without DEBUG_PAGEALLOC.

Any idea what trinity itself is doing?

Could you add the following, I just want to make sure the bug isn't
being caused by an overflow:

diff --git a/mm/vmacache.c b/mm/vmacache.c
index add3162..abb85cc 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -17,6 +17,8 @@ void vmacache_flush_all(struct mm_struct *mm)
 {
        struct task_struct *g, *p;
 
+       WARN_ON_ONCE(1);
+
        rcu_read_lock();
        for_each_process_thread(g, p) {
                /*


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
