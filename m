Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABAC6B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 13:16:52 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p7FHGmmU030295
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:16:48 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by wpaz33.hot.corp.google.com with ESMTP id p7FHFX3D012912
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:16:47 -0700
Received: by qyk36 with SMTP id 36so1143029qyk.16
        for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:16:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110815134846.GB13534@localhost>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
	<1313189245-7197-2-git-send-email-curtw@google.com>
	<20110815134846.GB13534@localhost>
Date: Mon, 15 Aug 2011 10:16:38 -0700
Message-ID: <CAO81RMYmxRiGpEjLGyjKNeNxXg8UJDuVosNdHGKt70gezTjxGw@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Fengguang:

Thanks for looking at this.

On Mon, Aug 15, 2011 at 6:48 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Curt,
>
> Some thoughts about the interface..before dipping into the code.
>
> On Sat, Aug 13, 2011 at 06:47:25AM +0800, Curt Wohlgemuth wrote:
>> Add a new file, /proc/writeback/stats, which displays
>
> That's creating a new top directory in /proc. Do you have plans for
> adding more files under it?

Good question.  We have several files under /proc/writeback in our
kernels that we created at various times, some of which are probably
no longer useful, but others seem to be.  For example:
  - congestion: prints # of calls, # of jiffies slept in
congestion_wait() / io_schedule_timeout() from various call points
  - threshold_dirty : prints the current global FG threshold
  - threshold_bg : prints the current global BG threshold
  - pages_cleaned : prints the # pages sent to writeback -- same as
'nr_written' in /proc/vmstat (ours was earlier :-( )
  - pages_dirtied (same as nr_dirtied in /proc/vmstat)
  - prop_vm_XXX : print shift/events from vm_completions and vm_dirties

I'm not sure right now if global FG/BG thresholds appear anywhere in a
3.1 kernel; if so, the two threshold files above are superfluous.  So
are the pages_cleaned/dirtied.  The prop_vm files have not proven
useful to me.  I think the congestion file has a lot of value,
especially in an IO-less throttling world...

>
>> machine global data for how many pages were cleaned for
>> which reasons. =A0It also displays some additional counts for
>> various writeback events.
>>
>> These data are also available for each BDI, in
>> /sys/block/<device>/bdi/writeback_stats .
>
>> Sample output:
>>
>> =A0 =A0page: balance_dirty_pages =A0 =A0 =A0 =A0 =A0 2561544
>> =A0 =A0page: background_writeout =A0 =A0 =A0 =A0 =A0 =A0 =A05153
>> =A0 =A0page: try_to_free_pages =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> =A0 =A0page: sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A00
>> =A0 =A0page: kupdate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01027=
23
>> =A0 =A0page: fdatawrite =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01228779
>> =A0 =A0page: laptop_periodic =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> =A0 =A0page: free_more_memory =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0page: fs_free_space =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> =A0 =A0periodic writeback =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0377
>> =A0 =A0single inode wait =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 0
>> =A0 =A0writeback_wb wait =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 1
>
> That's already useful data, and could be further extended (in
> future patches) to answer questions like "what's the writeback
> efficiency in terms of effective chunk size?"
>
> So in future there could be lines like
>
> =A0 =A0pages: balance_dirty_pages =A0 =A0 =A0 =A0 =A0 2561544
> =A0 =A0chunks: balance_dirty_pages =A0 =A0 =A0 =A0 =A0XXXXXXX
> =A0 =A0works: balance_dirty_pages =A0 =A0 =A0 =A0 =A0 XXXXXXX
>
> or even derived lines like
>
> =A0 =A0pages_per_chunk: balance_dirty_pages =A0 =A0 =A0 =A0 XXXXXXX
> =A0 =A0pages_per_work: balance_dirty_pages =A0 =A0 =A0 =A0 =A0XXXXXXX
>
> Another question is, how can the display format be script friendly?
> The current form looks not easily parse-able at least for "cut"..

I suppose you mean because of the variable number of tokens.  Yeah,
this can be hard.  Of course, I always just use "awk '{print $NF}'"
and it works for me :-) .  But I'd be happy to change these to use a
consistent # of args.

Thanks,
Curt


> Thanks,
> Fengguang
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
