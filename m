Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 14A435F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:45:05 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC][PATCH v3 2/6] mm, directio: fix fork vs direct-io race (read(2) side IOW gup(write) side)
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
	<20090414151652.C64D.A69D9226@jp.fujitsu.com>
	<20090414152500.C65F.A69D9226@jp.fujitsu.com>
Date: Tue, 14 Apr 2009 12:45:41 -0400
In-Reply-To: <20090414152500.C65F.A69D9226@jp.fujitsu.com> (KOSAKI Motohiro's
	message of "Tue, 14 Apr 2009 15:25:52 +0900 (JST)")
Message-ID: <x49ab6jyyiy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Zach Brown <zach.brown@oracle.com>, Andy Grover <andy.grover@oracle.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> Oops, I forgot some cc. resend it.
>
>> Subject: [PATCH] mm, directio: fix fork vs direct-io race
>> 
>> 
>> ChangeLog:
>> V2 -> V3
>>    o remove early decow logic
>> 
>> V1 -> V2
>>    o add dio+aio logic
>> 

[snip test programs]

>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Sugessted-by: Linus Torvalds <torvalds@osdl.org>
>> Cc: Hugh Dickins <hugh@veritas.com>
>> Cc: Andrew Morton <akpm@osdl.org>
>> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Jeff Moyer <jmoyer@redhat.com>
>> Cc: Zach Brown <zach.brown@oracle.com>
>> Cc: Andy Grover <andy.grover@oracle.com>
>> Cc: linux-fsdevel@vger.kernel.org
>> Cc: linux-mm@kvack.org
>> ---
>>  fs/direct-io.c            |   16 ++++++++++++++++
>>  include/linux/init_task.h |    1 +
>>  include/linux/mm_types.h  |    6 ++++++
>>  kernel/fork.c             |    3 +++
>>  4 files changed, 26 insertions(+)
>> 
>> Index: b/fs/direct-io.c
>> ===================================================================
>> --- a/fs/direct-io.c	2009-04-13 00:24:01.000000000 +0900
>> +++ b/fs/direct-io.c	2009-04-13 01:36:37.000000000 +0900
>> @@ -131,6 +131,9 @@ struct dio {
>>  	int is_async;			/* is IO async ? */
>>  	int io_error;			/* IO error in completion path */
>>  	ssize_t result;                 /* IO result */
>> +
>> +	/* fork exclusive stuff */
>> +	struct mm_struct *mm;
>>  };
>>  
>>  /*
>> @@ -244,6 +247,12 @@ static int dio_complete(struct dio *dio,
>>  		/* lockdep: non-owner release */
>>  		up_read_non_owner(&dio->inode->i_alloc_sem);
>>  
>> +	if (dio->rw == READ) {
>> +		BUG_ON(!dio->mm);
>> +		up_read_non_owner(&dio->mm->mm_pinned_sem);
>> +		mmdrop(dio->mm);
>> +	}
>> +
>>  	if (ret == 0)
>>  		ret = dio->page_errors;
>>  	if (ret == 0)
>> @@ -942,6 +951,7 @@ direct_io_worker(int rw, struct kiocb *i
>>  	ssize_t ret = 0;
>>  	ssize_t ret2;
>>  	size_t bytes;
>> +	struct mm_struct *mm;
>>  
>>  	dio->inode = inode;
>>  	dio->rw = rw;
>> @@ -960,6 +970,12 @@ direct_io_worker(int rw, struct kiocb *i
>>  	spin_lock_init(&dio->bio_lock);
>>  	dio->refcount = 1;
>>  
>> +	if (rw == READ) {
>> +		mm = dio->mm = current->mm;
>> +		atomic_inc(&mm->mm_count);
>> +		down_read_non_owner(&mm->mm_pinned_sem);
>> +	}
>> +

So, if you're continuously submitting async read I/O, you will starve
out the fork() call indefinitely.  I agree that you want to allow
multiple O_DIRECT I/Os to go on at once, but I'm not sure this is the
right way forward.

I have to weigh in and say I much prefer the patches posted by Nick and
Andrea.  They were much more contained and had negligible performance
impact.

Have you done any performance measurements on this patch series?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
