Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 47B1B6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 18:59:16 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so6398749wgg.34
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 15:59:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fk8si1714905wib.80.2014.01.27.15.59.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 15:59:15 -0800 (PST)
Date: Tue, 28 Jan 2014 00:59:13 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/fs: don't keep pages when receiving a pending SIGKILL
 in __get_user_pages()
Message-ID: <20140127235913.GC7020@quack.suse.cz>
References: <52D65568.6080106@huawei.com>
 <alpine.DEB.2.02.1401151508370.29404@chino.kir.corp.google.com>
 <52D7D7AE.8070108@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <52D7D7AE.8070108@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: David Rientjes <rientjes@google.com>, Li Zefan <lizefan@huawei.com>, robin.yb@huawei.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 16-01-14 20:59:26, Xishi Qiu wrote:
> On 2014/1/16 7:15, David Rientjes wrote:
> 
> > On Wed, 15 Jan 2014, Xishi Qiu wrote:
> > 
> >> In the process IO direction, dio_refill_pages will call get_user_pages_fast 
> >> to map the page from user space. If ret is less than 0 and IO is write, the 
> >> function will create a zero page to fill data. This may work for some file 
> >> system, but in some device operate we prefer whole write or fail, not half 
> >> data half zero, e.g. fs metadata, like inode, identy.
> >> This happens often when kill a process which is doing direct IO. Consider 
> >> the following cases, the process A is doing IO process, may enter __get_user_pages 
> >> function, if other processes send process A SIG_KILL, A will enter the 
> >> following branches 
> >> 		/*
> >> 		 * If we have a pending SIGKILL, don't keep faulting
> >> 		 * pages and potentially allocating memory.
> >> 		 */
> >> 		if (unlikely(fatal_signal_pending(current)))
> >> 			return i ? i : -ERESTARTSYS;
> >> Return current pages. direct IO will write the pages, the subsequent pages 
> >> which cana??t get will use zero page instead. 
> >> This patch will modify this judgment, if receive SIG_KILL, release pages and 
> >> return an error. Direct IO will find no blocks_available and return error 
> >> direct, rather than half IO data and half zero page.
> >>
> >> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> >> Signed-off-by: Bin Yang <robin.yb@huawei.com>
> > 
> > It's scary to change the behavior of gup when some callers may want the 
> > exact opposite of what you're intending here, which is sane fallback by 
> > mapping the zero page.  In fact, gup never does put_page() itself and 
> > __get_user_pages() always returns the number of pages pinned and may not 
> > equal what is passed.
> > 
> > So, this definitely isn't the right solution for a special-case direct IO.  
> > Instead, it would be better to code this directly in the caller and 
> > compare the return value with nr_pages in dio_refill_pages() and then do 
> > the put_page() itself before falling back to ZERO_PAGE().
> 
> Hi Rientjes,
> You are right, we should not change the behavior of gup.
> I have a question, if we only get a part of the pages from get_user_pages_fast(),
> shall we write them to the disk? or add a check before write?
> I'm not familiar with fs.
  It is OK to write as many pages as you get and then bail out from direct
IO. OTOH if you are sending a SIGKILL to an application, you probably want
to kill it as soon as possible and sending IO can take some time. So in my
opinion it is more desirable to just drop page references we've got in
dio_refill_pages() and bail out immediately.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
