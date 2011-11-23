Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 844186B00B2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 06:39:44 -0500 (EST)
Date: Wed, 23 Nov 2011 12:39:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 7/7] mm: compaction: Introduce sync-light migration for
 use by compaction
Message-ID: <20111123113939.GC9775@quack.suse.cz>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
 <20111122101451.GJ19415@suse.de>
 <20111122115427.GA8058@quack.suse.cz>
 <201111222159.24987.nai.xia@gmail.com>
 <20111122191302.GF8058@quack.suse.cz>
 <CAPQyPG6EComwoD7+SS7qDqU-G5OYrHbAWJG0gfmJPh9_2N=RZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPQyPG6EComwoD7+SS7qDqU-G5OYrHbAWJG0gfmJPh9_2N=RZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shaohua.li@intel.com>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 23-11-11 06:44:23, Nai Xia wrote:
> >> So that amounts to the following calculation that is important to the
> >> statistical stall time for the compaction:
> >>
> >>      page_nr *  average_stall_window_time
> >>
> >> where average_stall_window_time is the window for a page between
> >> NotUptoDate ---> UptoDate or Dirty --> Clean. And page_nr is the
> >> number of pages in stall window for read or write.
> >>
> >> So for general cases,
> >> Fact 1) may ensure that the page_nr is smaller for read, while
> >> fact 2) may ensure the same for average_locking_window_time.
> >  Well, page_nr really depends on the load. If the workload is only reads,
> > clearly number of read pages is going to be higher than number of written
> > pages. Once workload does heavy writing, I agree number of pages under
> > writeback is likely going to be higher.
> 
> Think about process A linearly scans 100MB mapped file pages
> area for read, and another process B linearly writes to a same sized area.
> If there is no readahead, the read page in stall window in memory is only
> *one* page each time.
  Yes, I understand this. But in a situation where there is *no* process
writing and *hundred* processes reading, you clearly have more pages locked
for reading than for writing. All I wanted to say is that your broad
statement that the number of pages read from disk is lower than the number
of pages written is not true in general. It depends on the workload.

> However, 100MB dirty pages can be hold in memory
> waiting to be write which may stall the compaction for fallback_migrate_page().
> Even for buffer_migrate_page() these pages are much more likely to get locked
> by other behaviors like you said for IO submission,etc.
> 
> I was not sure about readahead, of course,  I only theoretically
> expected its still not
> comparable to the totally async write behavior.
> 
> >
> >> I am not sure this will be the same case for all workloads,
> >> don't know if Mel has tested large readahead workloads which
> >> has more async read IOs and less writebacks.
> >>
> >> But theoretically I expect things are not that bad even for large
> >> readahead, because readahead is triggered by the readahead TAG in
> >> linear order, which means for a process to generating readahead IO,
> >> its speed is still somewhat govened by the read IO speed. While
> >> for a process writing to a file mapped memory area, it may well
> >> exceed the speed of its backing-store writing speed.
> >>
> >>
> >> Aside from that, I think the relation between page locking and
> >> page read is not 1-to-1, in other words, there maybe quite some
> >> transient page locking is caused by mmap and then page fault into
> >> already good-state pages requiring no IO at all. For these
> >> transient page lockings I think it's reasonable to have light
> >> waiting.
> >  Definitely there are other lockings than for read. E.g. to write a page,
> > we lock it first, submit IO (which can actually block waiting for request
> > to get freed), set PageWriteback, and unlock the page. And there are more
> > transient ones like you mention above...
> 
> Yes, you are right.
> But I think we were talking about distinguishing page locking from page read
> IO?
> 
> Well, I might also want to suggest that do an early dirty test before
> taking the lock...but, I expect page NotUpToDate is much more likely an
> indication that we are going to block for IO on the following page lock.
> Dirty test is not that strong. Do you agree ?
  Yes, I agree with this.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
