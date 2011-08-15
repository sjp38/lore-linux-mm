Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 820646B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 14:56:18 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p7FIuAUm007969
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 11:56:10 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by hpaq2.eem.corp.google.com with ESMTP id p7FIu8b3000354
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 11:56:09 -0700
Received: by qyk2 with SMTP id 2so2886818qyk.15
        for <linux-mm@kvack.org>; Mon, 15 Aug 2011 11:56:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110815184023.GA16369@quack.suse.cz>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
	<1313189245-7197-2-git-send-email-curtw@google.com>
	<20110815134846.GB13534@localhost>
	<CAO81RMYmxRiGpEjLGyjKNeNxXg8UJDuVosNdHGKt70gezTjxGw@mail.gmail.com>
	<20110815184023.GA16369@quack.suse.cz>
Date: Mon, 15 Aug 2011 11:56:08 -0700
Message-ID: <CAO81RMbpK4ZE=4c5khSrGpzDrXbyynWp8QoFbUjMuHFeJtbDDw@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Jan:

On Mon, Aug 15, 2011 at 11:40 AM, Jan Kara <jack@suse.cz> wrote:
> On Mon 15-08-11 10:16:38, Curt Wohlgemuth wrote:
>> On Mon, Aug 15, 2011 at 6:48 AM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>> > Curt,
>> >
>> > Some thoughts about the interface..before dipping into the code.
>> >
>> > On Sat, Aug 13, 2011 at 06:47:25AM +0800, Curt Wohlgemuth wrote:
>> >> Add a new file, /proc/writeback/stats, which displays
>> >
>> > That's creating a new top directory in /proc. Do you have plans for
>> > adding more files under it?
>>
>> Good question. =A0We have several files under /proc/writeback in our
>> kernels that we created at various times, some of which are probably
>> no longer useful, but others seem to be. =A0For example:
>> =A0 - congestion: prints # of calls, # of jiffies slept in
>> congestion_wait() / io_schedule_timeout() from various call points
>> =A0 - threshold_dirty : prints the current global FG threshold
>> =A0 - threshold_bg : prints the current global BG threshold
>> =A0 - pages_cleaned : prints the # pages sent to writeback -- same as
>> 'nr_written' in /proc/vmstat (ours was earlier :-( )
>> =A0 - pages_dirtied (same as nr_dirtied in /proc/vmstat)
>> =A0 - prop_vm_XXX : print shift/events from vm_completions and vm_dirtie=
s
>>
>> I'm not sure right now if global FG/BG thresholds appear anywhere in a
>> 3.1 kernel; if so, the two threshold files above are superfluous. =A0So
>> are the pages_cleaned/dirtied. =A0The prop_vm files have not proven
>> useful to me. =A0I think the congestion file has a lot of value,
>> especially in an IO-less throttling world...
> =A0/sys/kernel/debug/bdi/<dev>/stats has BdiDirtyThresh, DirtyThresh, and
> BackgroundThresh. So we should already expose all you have in the thresho=
ld
> files.

Ah, right, I knew that and overlooked it.  I get confused looking at
lots of kernel versions and patches at the same time :-) .

> Regarding congestion_wait() statistics - do I get right that the numbers
> gathered actually depend on the number of threads using the congested
> device? They are something like
> =A0\sum_{over threads} time_waited_for_bdi
> How do you interpret the resulting numbers then?

I don't have it by thread; just stupidly as totals, like this:

calls: ttfp           11290
time: ttfp        558191
calls: shrink_inactive_list isolated       xxx
time : shrink_inactive_list isolated            xxx
calls: shrink_inactive_list lumpy reclaim       xxx
time : shrink_inactive_list lumpy reclaim          xxx
calls: balance_pgdat                                xxx
time : balance_pgdat                                xxx
calls: alloc_pages_high_priority                    xxx
time : alloc_pages_high_priority                    xxx
calls: alloc_pages_slowpath                         xxx
time : alloc_pages_slowpath                         xxx
calls: throttle_vm_writeout                         xxx
time : throttle_vm_writeout                         xxx
calls: balance_dirty_pages                          xxx
time : balance_dirty_pages                         xxx

Note that the "call" points above are from a very old (2.6.34 +
backports) kernel, but you get the idea.  We just wrap
congestion_wait() with a routine that takes a 'type' parameter; does
the congestion_wait(); and increments the appropriate 'call' stat, and
adds to the appropriate 'time' stat the return value from
congestion_wait().

For a given workload, you can get an idea for where congestion is
adding to delays.  I really think that for IO-less
balance_dirty_pages(), we need some insight into how long writer
threads are being throttled.  And tracepoints are great, but not
sufficient, IMHO.

Thanks,
Curt

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
>
>> >> machine global data for how many pages were cleaned for
>> >> which reasons. =A0It also displays some additional counts for
>> >> various writeback events.
>> >>
>> >> These data are also available for each BDI, in
>> >> /sys/block/<device>/bdi/writeback_stats .
>> >
>> >> Sample output:
>> >>
>> >> =A0 =A0page: balance_dirty_pages =A0 =A0 =A0 =A0 =A0 2561544
>> >> =A0 =A0page: background_writeout =A0 =A0 =A0 =A0 =A0 =A0 =A05153
>> >> =A0 =A0page: try_to_free_pages =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> >> =A0 =A0page: sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A00
>> >> =A0 =A0page: kupdate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01=
02723
>> >> =A0 =A0page: fdatawrite =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0122877=
9
>> >> =A0 =A0page: laptop_periodic =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
0
>> >> =A0 =A0page: free_more_memory =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
0
>> >> =A0 =A0page: fs_free_space =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0
>> >> =A0 =A0periodic writeback =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
377
>> >> =A0 =A0single inode wait =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0
>> >> =A0 =A0writeback_wb wait =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 1
>> >
>> > That's already useful data, and could be further extended (in
>> > future patches) to answer questions like "what's the writeback
>> > efficiency in terms of effective chunk size?"
>> >
>> > So in future there could be lines like
>> >
>> > =A0 =A0pages: balance_dirty_pages =A0 =A0 =A0 =A0 =A0 2561544
>> > =A0 =A0chunks: balance_dirty_pages =A0 =A0 =A0 =A0 =A0XXXXXXX
>> > =A0 =A0works: balance_dirty_pages =A0 =A0 =A0 =A0 =A0 XXXXXXX
>> >
>> > or even derived lines like
>> >
>> > =A0 =A0pages_per_chunk: balance_dirty_pages =A0 =A0 =A0 =A0 XXXXXXX
>> > =A0 =A0pages_per_work: balance_dirty_pages =A0 =A0 =A0 =A0 =A0XXXXXXX
>> >
>> > Another question is, how can the display format be script friendly?
>> > The current form looks not easily parse-able at least for "cut"..
>>
>> I suppose you mean because of the variable number of tokens. =A0Yeah,
>> this can be hard. =A0Of course, I always just use "awk '{print $NF}'"
>> and it works for me :-) . =A0But I'd be happy to change these to use a
>> consistent # of args.
>>
>> Thanks,
>> Curt
>>
>>
>> > Thanks,
>> > Fengguang
>> >
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
