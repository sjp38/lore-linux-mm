Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 655E76B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:00:02 -0500 (EST)
Received: by ywp17 with SMTP id 17so245386ywp.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 05:59:58 -0800 (PST)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH 7/7] mm: compaction: Introduce sync-light migration for use by compaction
Date: Tue, 22 Nov 2011 21:59:24 +0800
References: <1321900608-27687-1-git-send-email-mgorman@suse.de> <20111122101451.GJ19415@suse.de> <20111122115427.GA8058@quack.suse.cz>
In-Reply-To: <20111122115427.GA8058@quack.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201111222159.24987.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Shaohua Li <shaohua.li@intel.com>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tuesday 22 November 2011 19:54:27 Jan Kara wrote:
> On Tue 22-11-11 10:14:51, Mel Gorman wrote:
> > On Tue, Nov 22, 2011 at 02:56:51PM +0800, Shaohua Li wrote:
> > > On Tue, 2011-11-22 at 02:36 +0800, Mel Gorman wrote:
> > > on the other hand, MIGRATE_SYNC_LIGHT now waits for pagelock and buffer
> > > lock, so could wait on page read. page read and page out have the same
> > > latency, why takes them different?
> > > 
> > 
> > That's a very reasonable question.
> > 
> > To date, the stalls that were reported to be a problem were related to
> > heavy writing workloads. Workloads are naturally throttled on reads
> > but not necessarily on writes and the IO scheduler priorities sync
> > reads over writes which contributes to keeping stalls due to page
> > reads low.  In my own tests, there have been no significant stalls
> > due to waiting on page reads. I accept this may be because the stall
> > threshold I record is too low.
> > 
> > Still, I double checked an old USB copy based test to see what the
> > compaction-related stalls really were.
> > 
> > 58 seconds	waiting on PageWriteback
> > 22 seconds	waiting on generic_make_request calling ->writepage
> > 
> > These are total times, each stall was about 2-5 seconds and very rough
> > estimates. There were no other sources of stalls that had compaction
> > in the stacktrace I'm rerunning to gather more accurate stall times
> > and for a workload similar to Andrea's and will see if page reads
> > crop up as a major source of stalls.
>   OK, but the fact that reads do not stall may pretty much depend on the
> behavior of the underlying IO scheduler and we probably don't want to rely
> on it's behavior too closely. So if you are going to treat reads in a
> special way, check with NOOP or DEADLINE io schedulers that read-stalls
> are not a problem with them as well.

Compared to the IO scheduler, I actually expect this behavior is more related
to these two facts:

1) Due to the IO direction , most pages to be read are still in disk,
while most pages to be write are in memory. 

2) And as Mel explained, read trends to be sync, write trends to be async,
so for decent IO schedulers, no matter what they differ in each other, 
should almost agree no favoring read more than write. 

So that amounts to the following calculation that is important to the 
statistical stall time for the compaction:

     page_nr *  average_stall_window_time

where average_stall_window_time is the window for a page between 
NotUptoDate ---> UptoDate or Dirty --> Clean. And page_nr is the
number of pages in stall window for read or write.

So for general cases, 
Fact 1) may ensure that the page_nr is smaller for read, while
fact 2) may ensure the same for average_locking_window_time. 

I am not sure this will be the same case for all workloads, 
don't know if Mel has tested large readahead workloads which 
has more async read IOs and less writebacks. 

But theoretically I expect things are not that bad even for large
readahead, because readahead is triggered by the readahead TAG in
linear order, which means for a process to generating readahead IO,
its speed is still somewhat govened by the read IO speed. While
for a process writing to a file mapped memory area, it may well
exceed the speed of its backing-store writing speed. 


Aside from that, I think the relation between page locking and 
page read is not 1-to-1, in other words, there maybe quite some
transient page locking is caused by mmap and then page fault into 
already good-state pages requiring no IO at all. For these 
transient page lockings I think it's reasonable to have light 
waiting. 

Correct me please, if sth is wrong in my reasoning. :)


Thanks

Nai

> 
> 								Honza
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
