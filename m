Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id DC4566B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 07:42:26 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so12316165pac.25
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 04:42:26 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id xl4si30087845pab.5.2014.07.02.04.42.25
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 04:42:26 -0700 (PDT)
Message-ID: <53B3EF6E.8000806@cn.fujitsu.com>
Date: Wed, 2 Jul 2014 19:39:26 +0800
From: Xiaoguang Wang <wangxg.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
References: <53ACD20B.2030601@cn.fujitsu.com> <alpine.LSU.2.11.1406302056510.12406@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406302056510.12406@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, chrubis@suse.cz

Hi,

On 07/01/2014 12:18 PM, Hugh Dickins wrote:
> On Fri, 27 Jun 2014, Xiaoguang Wang wrote:
>> Hi maintainers,
> 
> That's not me, but I'll answer with my opinion.

Sure, thanks, Any opinion or suggestions will be appreciated :)
> 
>>
>> In August 2008, there was a discussion about 'Corruption with O_DIRECT and unaligned user buffers',
>> please have a look at this url: http://thread.gmane.org/gmane.linux.file-systems/27358
> 
> Whereas (now the truth can be told!) "someone wishing to remain anonymous"
> in that thread was indeed me.  Then as now, disinclined to spend time on it.
> 
>>
>> The attached test program written by Tim has been added to LTP, please see this below url:
>> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/io/direct_io/dma_thread_diotest.c
>>
>>
>> Now I tested this program in kernel 3.16.0-rc1+, it seems that the date corruption still exists. Meanwhile
>> there is also such a section in open(2)'s manpage warning that O_DIRECT I/Os should never be run
>> concurrently with the fork(2) system call. Please see below section:
>>
>>     O_DIRECT I/Os should never be run concurrently with the fork(2) system call, if the memory buffer
>>     is a private mapping (i.e., any mapping created with the mmap(2) MAP_PRIVATE flag; this includes
>>     memory allocated on the heap and statically allocated buffers).  Any such I/Os, whether  submitted
>>     via an asynchronous I/O interface or from another thread in the process, should be completed before
>>     fork(2) is called.  Failure to do so can result in data corruption and undefined behavior in parent
>>     and child processes.  This restriction does not apply when the memory buffer for  the  O_DIRECT
>>     I/Os  was  created  using shmat(2) or mmap(2) with the MAP_SHARED flag.  Nor does this restriction
>>     apply when the memory buffer has been advised as MADV_DONTFORK with madvise(2), ensuring that it will
>>     not be available to the child after fork(2).
>>
>> Hmm, so I'd like to know whether you have some plans to fix this bug, or this is not considered as a
>> bug, it's just a programming specification that we should avoid doing fork() while we are having O_DIRECT
>> file operation with non-page aligned IO, thanks.
>>
>> Steps to run this attached program:
>> 1. ./dma_thread  # create temp files
>> 2. ./dma_thread -a 512 -w 8 $ alignment is 512 and create 8 threads.
> 
> I regard it, then and now, as a displeasing limitation;
> but one whose fix would cause more trouble than it's worth.

Yeah, I see. Once Andrea had a patch to fix this, but it would slow down fork().
> 
> I thought we settled long ago on MADV_DONTFORK as an imperfect but
> good enough workaround.  Not everyone will agree.  I certainly have
> no plans to go further myself.
OK, I still want to thanks for your response.

Currently I don't have much knowledge about mm, sorry, so I'd like to know whether someone
has some opinion or plan to fix this issue, thanks.

Regards,
Xiaoguang Wang

> 
> Hugh
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
