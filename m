Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 734356B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 18:16:00 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id q9so775045ykb.0
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 15:16:00 -0800 (PST)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id q69si7096228yhd.245.2014.01.15.15.15.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 15:15:59 -0800 (PST)
Received: by mail-yk0-f178.google.com with SMTP id 79so772461ykr.9
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 15:15:59 -0800 (PST)
Date: Wed, 15 Jan 2014 15:15:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/fs: don't keep pages when receiving a pending SIGKILL
 in __get_user_pages()
In-Reply-To: <52D65568.6080106@huawei.com>
Message-ID: <alpine.DEB.2.02.1401151508370.29404@chino.kir.corp.google.com>
References: <52D65568.6080106@huawei.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1550669836-1389827758=:29404"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Li Zefan <lizefan@huawei.com>, robin.yb@huawei.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1550669836-1389827758=:29404
Content-Type: TEXT/PLAIN; charset=windows-1252
Content-Transfer-Encoding: 8BIT

On Wed, 15 Jan 2014, Xishi Qiu wrote:

> In the process IO direction, dio_refill_pages will call get_user_pages_fast 
> to map the page from user space. If ret is less than 0 and IO is write, the 
> function will create a zero page to fill data. This may work for some file 
> system, but in some device operate we prefer whole write or fail, not half 
> data half zero, e.g. fs metadata, like inode, identy.
> This happens often when kill a process which is doing direct IO. Consider 
> the following cases, the process A is doing IO process, may enter __get_user_pages 
> function, if other processes send process A SIG_KILL, A will enter the 
> following branches 
> 		/*
> 		 * If we have a pending SIGKILL, don't keep faulting
> 		 * pages and potentially allocating memory.
> 		 */
> 		if (unlikely(fatal_signal_pending(current)))
> 			return i ? i : -ERESTARTSYS;
> Return current pages. direct IO will write the pages, the subsequent pages 
> which can?t get will use zero page instead. 
> This patch will modify this judgment, if receive SIG_KILL, release pages and 
> return an error. Direct IO will find no blocks_available and return error 
> direct, rather than half IO data and half zero page.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Signed-off-by: Bin Yang <robin.yb@huawei.com>

It's scary to change the behavior of gup when some callers may want the 
exact opposite of what you're intending here, which is sane fallback by 
mapping the zero page.  In fact, gup never does put_page() itself and 
__get_user_pages() always returns the number of pages pinned and may not 
equal what is passed.

So, this definitely isn't the right solution for a special-case direct IO.  
Instead, it would be better to code this directly in the caller and 
compare the return value with nr_pages in dio_refill_pages() and then do 
the put_page() itself before falling back to ZERO_PAGE().
--531381512-1550669836-1389827758=:29404--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
