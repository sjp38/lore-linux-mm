Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA21194
	for <linux-mm@kvack.org>; Thu, 19 Sep 2002 01:19:47 -0700 (PDT)
Message-ID: <3D89889C.F5868818@digeo.com>
Date: Thu, 19 Sep 2002 01:19:40 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.35-mm1
References: <3D858515.ED128C76@digeo.com> <E17rw5X-0000vG-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lse-tech@lists.sourceforge.net" <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> On Monday 16 September 2002 09:15, Andrew Morton wrote:
> > A 4x performance regression in heavy dbench testing has been fixed. The
> > VM was accidentally being fair to the dbench instances in page reclaim.
> > It's better to be unfair so just a few instances can get ahead and submit
> > more contiguous IO.  It's a silly thing, but it's what I meant to do anyway.
> 
> Curious... did the performance hit show anywhere other than dbench?

Other benchmarky tests would have suffered, but I did not check.

I have logic in there which is designed to throttle heavy writers
within the page allocator, as well as within balance_dirty_pages.
basically:

	generic_file_write()
	{
		current->backing_dev_info = mapping->backing_dev_info;
		alloc_page()
		current->backing_dev_info = 0;
	}

	shrink_list()
	{
		if (PageDirty(page)) {
			if (page->mapping->backing_dev_info == current->backing_dev_info)
				blocking_write(page->mapping);
			else
				nonblocking_write(page->mapping);
		}
	}


What this says is "if this task is prepared to block against this
page's queue, then write the dirty data, even if that would block".

This means that all the dbench instances will write each other's
dirty data as it comes off the tail of the LRU.  Which provides
some additional throttling, and means that we don't just refile
the page.

But the logic was not correctly implemented.  The dbench instances
were performing non-blocking writes.  This meant that all 64 instances
were cheerfully running all the time, submitting IO all over the disk.
The /proc/meminfo:Writeback figure never even hit a megabyte.  That
number tells us how much memory is currently in the request queue.
Clearly, it was very fragmented.

By forcing the dbench instance to block on the queue, particular instances
were able to submit decent amounts of IO.  The `Writeback' figure went
back to around 4 megabytes, because the individual requests were
larger - more merging.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
