Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBCE6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 00:19:45 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so9315575pdb.25
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 21:19:45 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id xw3si13310332pab.89.2014.06.30.21.19.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 21:19:44 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so9353717pde.6
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 21:19:44 -0700 (PDT)
Date: Mon, 30 Jun 2014 21:18:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
In-Reply-To: <53ACD20B.2030601@cn.fujitsu.com>
Message-ID: <alpine.LSU.2.11.1406302056510.12406@eggly.anvils>
References: <53ACD20B.2030601@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiaoguang Wang <wangxg.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, chrubis@suse.cz

On Fri, 27 Jun 2014, Xiaoguang Wang wrote:
> Hi maintainers,

That's not me, but I'll answer with my opinion.

> 
> In August 2008, there was a discussion about 'Corruption with O_DIRECT and unaligned user buffers',
> please have a look at this url: http://thread.gmane.org/gmane.linux.file-systems/27358

Whereas (now the truth can be told!) "someone wishing to remain anonymous"
in that thread was indeed me.  Then as now, disinclined to spend time on it.

> 
> The attached test program written by Tim has been added to LTP, please see this below url:
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/io/direct_io/dma_thread_diotest.c
> 
> 
> Now I tested this program in kernel 3.16.0-rc1+, it seems that the date corruption still exists. Meanwhile
> there is also such a section in open(2)'s manpage warning that O_DIRECT I/Os should never be run
> concurrently with the fork(2) system call. Please see below section:
> 
>     O_DIRECT I/Os should never be run concurrently with the fork(2) system call, if the memory buffer
>     is a private mapping (i.e., any mapping created with the mmap(2) MAP_PRIVATE flag; this includes
>     memory allocated on the heap and statically allocated buffers).  Any such I/Os, whether  submitted
>     via an asynchronous I/O interface or from another thread in the process, should be completed before
>     fork(2) is called.  Failure to do so can result in data corruption and undefined behavior in parent
>     and child processes.  This restriction does not apply when the memory buffer for  the  O_DIRECT
>     I/Os  was  created  using shmat(2) or mmap(2) with the MAP_SHARED flag.  Nor does this restriction
>     apply when the memory buffer has been advised as MADV_DONTFORK with madvise(2), ensuring that it will
>     not be available to the child after fork(2).
> 
> Hmm, so I'd like to know whether you have some plans to fix this bug, or this is not considered as a
> bug, it's just a programming specification that we should avoid doing fork() while we are having O_DIRECT
> file operation with non-page aligned IO, thanks.
> 
> Steps to run this attached program:
> 1. ./dma_thread  # create temp files
> 2. ./dma_thread -a 512 -w 8 $ alignment is 512 and create 8 threads.

I regard it, then and now, as a displeasing limitation;
but one whose fix would cause more trouble than it's worth.

I thought we settled long ago on MADV_DONTFORK as an imperfect but
good enough workaround.  Not everyone will agree.  I certainly have
no plans to go further myself.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
