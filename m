Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 137866B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:00:08 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so2584319pde.27
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 05:00:07 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ai8si7008932pad.154.2014.01.16.05.00.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 05:00:06 -0800 (PST)
Message-ID: <52D7D7AE.8070108@huawei.com>
Date: Thu, 16 Jan 2014 20:59:26 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/fs: don't keep pages when receiving a pending SIGKILL
 in __get_user_pages()
References: <52D65568.6080106@huawei.com> <alpine.DEB.2.02.1401151508370.29404@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401151508370.29404@chino.kir.corp.google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Li Zefan <lizefan@huawei.com>, robin.yb@huawei.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2014/1/16 7:15, David Rientjes wrote:

> On Wed, 15 Jan 2014, Xishi Qiu wrote:
> 
>> In the process IO direction, dio_refill_pages will call get_user_pages_fast 
>> to map the page from user space. If ret is less than 0 and IO is write, the 
>> function will create a zero page to fill data. This may work for some file 
>> system, but in some device operate we prefer whole write or fail, not half 
>> data half zero, e.g. fs metadata, like inode, identy.
>> This happens often when kill a process which is doing direct IO. Consider 
>> the following cases, the process A is doing IO process, may enter __get_user_pages 
>> function, if other processes send process A SIG_KILL, A will enter the 
>> following branches 
>> 		/*
>> 		 * If we have a pending SIGKILL, don't keep faulting
>> 		 * pages and potentially allocating memory.
>> 		 */
>> 		if (unlikely(fatal_signal_pending(current)))
>> 			return i ? i : -ERESTARTSYS;
>> Return current pages. direct IO will write the pages, the subsequent pages 
>> which can?t get will use zero page instead. 
>> This patch will modify this judgment, if receive SIG_KILL, release pages and 
>> return an error. Direct IO will find no blocks_available and return error 
>> direct, rather than half IO data and half zero page.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> Signed-off-by: Bin Yang <robin.yb@huawei.com>
> 
> It's scary to change the behavior of gup when some callers may want the 
> exact opposite of what you're intending here, which is sane fallback by 
> mapping the zero page.  In fact, gup never does put_page() itself and 
> __get_user_pages() always returns the number of pages pinned and may not 
> equal what is passed.
> 
> So, this definitely isn't the right solution for a special-case direct IO.  
> Instead, it would be better to code this directly in the caller and 
> compare the return value with nr_pages in dio_refill_pages() and then do 
> the put_page() itself before falling back to ZERO_PAGE().

Hi Rientjes,
You are right, we should not change the behavior of gup.
I have a question, if we only get a part of the pages from get_user_pages_fast(),
shall we write them to the disk? or add a check before write?
I'm not familiar with fs.

dio_refill_pages()
	get_user_pages_fast()

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
