Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3676B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:52:52 -0400 (EDT)
Received: by mail-bk0-f46.google.com with SMTP id v15so808884bkz.33
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:52:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id co3si1850880bkc.221.2014.03.27.08.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 08:52:50 -0700 (PDT)
Date: Thu, 27 Mar 2014 16:52:48 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf] Postgresql performance problems with IO latency,
 especially during fsync()
Message-ID: <20140327155248.GG18118@quack.suse.cz>
References: <20140326191113.GF9066@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140326191113.GF9066@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@alap3.anarazel.de, andres@2ndquadrant.com

  Hello,

On Wed 26-03-14 20:11:13, Andres Freund wrote:
> At LSF/MM there was a slot about postgres' problems with the kernel. Our
> top#1 concern is frequent slow read()s that happen while another process
> calls fsync(), even though we'd be perfectly fine if that fsync() took
> ages.
> The "conclusion" of that part was that it'd be very useful to have a
> demonstration of the problem without needing a full blown postgres
> setup. I've quickly hacked something together, that seems to show the
> problem nicely.
  Thanks a lot for the program!

> For a bit of context: lwn.net/SubscriberLink/591723/940134eb57fcc0b8/
> and the "IO Scheduling" bit in
> http://archives.postgresql.org/message-id/20140310101537.GC10663%40suse.de
> 
> The tools output looks like this:
> gcc -std=c99 -Wall -ggdb ~/tmp/ioperf.c -o ioperf && ./ioperf
> ...
> wal[12155]: avg: 0.0 msec; max: 0.0 msec
> commit[12155]: avg: 0.2 msec; max: 15.4 msec
> wal[12155]: avg: 0.0 msec; max: 0.0 msec
> read[12157]: avg: 0.2 msec; max: 9.4 msec
> ...
> read[12165]: avg: 0.2 msec; max: 9.4 msec
> wal[12155]: avg: 0.0 msec; max: 0.0 msec
> starting fsync() of files
> finished fsync() of files
> read[12162]: avg: 0.6 msec; max: 2765.5 msec
> 
> So, the average read time is less than one ms (SSD, and about 50% cached
> workload). But once another backend does the fsync(), read latency
> skyrockets.
> 
> A concurrent iostat shows the problem pretty clearly:
> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s	avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> sda               1.00     0.00 6322.00  337.00    51.73     4.38	17.26     2.09    0.32    0.19    2.59   0.14  90.00
> sda               0.00     0.00 6016.00  303.00    47.18     3.95	16.57     2.30    0.36    0.23    3.12   0.15  94.40
> sda               0.00     0.00 6236.00 1059.00    49.52    12.88	17.52     5.91    0.64    0.20    3.23   0.12  88.40
> sda               0.00     0.00  105.00 26173.00     0.89   311.39	24.34   142.37    5.42   27.73    5.33   0.04 100.00
> sda               0.00     0.00   78.00 27199.00     0.87   324.06	24.40   142.30    5.25   11.08    5.23   0.04 100.00
> sda               0.00     0.00   10.00 33488.00     0.11   399.05	24.40   136.41    4.07  100.40    4.04   0.03 100.00
> sda               0.00     0.00 3819.00 10096.00    31.14   120.47	22.31    42.80    3.10    0.32    4.15   0.07  96.00
> sda               0.00     0.00 6482.00  346.00    52.98     4.53	17.25     1.93    0.28    0.20    1.80   0.14  93.20
> 
> While the fsync() is going on (or the kernel decides to start writing
> out aggressively for some other reason) the amount of writes to the disk
> is increased by two orders of magnitude. Unsurprisingly with disastrous
> consequences for read() performance. We really want a way to pace the
> writes issued to the disk more regularly.
> 
> The attached program right now can only be configured by changing some
> details in the code itself, but I guess that's not a problem. It will
> upfront allocate two files, and then start testing. If the files already
> exists it will use them.
> 
> Possible solutions:
> * Add a fadvise(UNDIRTY), that doesn't stall on a full IO queue like
>   sync_file_range() does.
> * Make IO triggered by writeback regard IO priorities and add it to
>   schedulers other than CFQ
> * Add a tunable that allows limiting the amount of dirty memory before
>   writeback on a per process basis.
> * ...?
> 
> If somebody familiar with buffered IO writeback is around at LSF/MM, or
> rather collab, Robert and I will be around for the next days.
  I guess I'm your guy, at least for the writeback part. I have some
insight in the block layer as well although there are better experts around
here. But I at least know whom to catch if there's some deeply intricate
problem ;)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
