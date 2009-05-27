Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 634786B005D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 02:25:01 -0400 (EDT)
Message-Id: <6.0.0.20.2.20090527151725.076b1038@172.19.0.2>
Date: Wed, 27 May 2009 15:20:40 +0900
From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
In-Reply-To: <20090527043601.GA26361@localhost>
References: <20090526193601.b825af5f.akpm@linux-foundation.org>
 <20090527035505.GA16916@localhost>
 <20090527130358.689C.A69D9226@jp.fujitsu.com>
 <20090527043601.GA26361@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>


At 13:36 09/05/27, Wu Fengguang wrote:
>On Wed, May 27, 2009 at 12:06:12PM +0800, KOSAKI Motohiro wrote:
>> > > Ah.  So it's likely to be some strange interaction with the RAID setup.
>> > 
>> > The normal case is, if page N become uptodate at time T(N), then
>> > T(N) <= T(N+1) holds. But for RAID, the data arrival time depends on
>> > runtime status of individual disks, which breaks that formula. So
>> > in do_generic_file_read(), just after submitting the async readahead IO
>> > request, the current page may well be uptodate, so the page won't be locked,
>> > and the block device won't be implicitly unplugged:
>> 
>> Hifumi-san, Can you get blktrace data and confirm Wu's assumption?
>
>To make the reasoning more obvious:
>
>Assume we just submitted readahead IO request for pages N ~ N+M, then
>        T(N) <= T(N+1)
>        T(N) <= T(N+2)
>        T(N) <= T(N+3)
>        ...
>        T(N) <= T(N+M)   (M = readahead size)
>So if the reader is going to block on any page in the above chunk,
>it is going to first block on page N.
>
>With RAID (and NFS to some degree), there is no strict ordering,
>so the reader is more likely to block on some random pages.
>
>In the first case, the effective async_size = M, in the second case,
>the effective async_size <= M. The more async_size, the more degree of
>readahead pipeline, hence the more low level IO latencies are hidden
>to the application.

I got your explanation especially about RAID specific matters.

>
>Thanks,
>Fengguang
>
>> 
>> > 
>> >                if (PageReadahead(page))
>> >                         page_cache_async_readahead()
>> >                 if (!PageUptodate(page))
>> >                                 goto page_not_up_to_date;
>> >                 //...
>> > page_not_up_to_date:
>> >                 lock_page_killable(page);
>> > 
>> > 
>> > Therefore explicit unplugging can help, so
>> > 
>> >         Acked-by: Wu Fengguang <fengguang.wu@intel.com> 
>> > 
>> > The only question is, shall we avoid the double unplug by doing this?
>> > 
>> > ---
>> >  mm/readahead.c |   10 ++++++++++
>> >  1 file changed, 10 insertions(+)
>> > 
>> > --- linux.orig/mm/readahead.c
>> > +++ linux/mm/readahead.c
>> > @@ -490,5 +490,15 @@ page_cache_async_readahead(struct addres
>> >  
>> >  	/* do read-ahead */
>> >  	ondemand_readahead(mapping, ra, filp, true, offset, req_size);
>> > +
>> > +	/*
>> > +	* Normally the current page is !uptodate and lock_page() will be
>> > +	* immediately called to implicitly unplug the device. However this
>> > +	* is not always true for RAID conifgurations, where data arrives
>> > +	* not strictly in their submission order. In this case we need to
>> > +	* explicitly kick off the IO.
>> > +	*/
>> > +	if (PageUptodate(page))
>> > +		blk_run_backing_dev(mapping->backing_dev_info, NULL);
>> >  }
>> >  EXPORT_SYMBOL_GPL(page_cache_async_readahead);

I am for this to avoid double unplug.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
