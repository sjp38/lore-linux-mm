Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m0I5cPi6004853
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 21:38:25 -0800
Received: from py-out-1112.google.com (pyea73.prod.google.com [10.34.153.73])
	by zps36.corp.google.com with ESMTP id m0I5cOtE024180
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 21:38:24 -0800
Received: by py-out-1112.google.com with SMTP id a73so1165631pye.9
        for <linux-mm@kvack.org>; Thu, 17 Jan 2008 21:38:24 -0800 (PST)
Message-ID: <532480950801172138x44e06780w2b15464845b626fc@mail.gmail.com>
Date: Thu, 17 Jan 2008 21:38:24 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
In-Reply-To: <20080118050107.GS155259@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115080921.70E3810653@localhost> <400562938.07583@ustc.edu.cn>
	 <532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>
	 <20080118050107.GS155259@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Jan 17, 2008 9:01 PM, David Chinner <dgc@sgi.com> wrote:

First off thank you for the very detailed reply. This rocks and gives
me much to think about.

> On Thu, Jan 17, 2008 at 01:07:05PM -0800, Michael Rubin wrote:
> This seems suboptimal for large files. If you keep feeding in
> new least recently dirtied files, the large files will never
> get an unimpeded go at the disk and hence we'll struggle to
> get decent bandwidth under anything but pure large file
> write loads.

You're right. I understand now. I just  changed a dial on my tests,
ran it and found pdflush not keeping up like it should. I need to
address this.

> Switching inodes during writeback implies a seek to the new write
> location, while continuing to write the same inode has no seek
> penalty because the writeback is sequential.  It follows from this
> that allowing larges file a disproportionate amount of data
> writeback is desirable.
>
> Also, cycling rapidly through all the large files to write 4MB to each is
> going to cause us to spend time seeking rather than writing compared
> to cycling slower and writing 40MB from each large file at a time.
>
> i.e. servicing one large file for 100ms is going to result in higher
> writeback throughput than servicing 10 large files for 10ms each
> because there's going to be less seeking and more writing done by
> the disks.
>
> That is, think of large file writes like process scheduler batch
> jobs - bulk throughput is what matters, so the larger the time slice
> you give them the higher the throughput.
>
> IMO, the sort of result we should be looking at is a
> writeback design that results in cycling somewhat like:
>
>         slice 1: iterate over small files
>         slice 2: flush large file 1
>         slice 3: iterate over small files
>         slice 4: flush large file 2
>         ......
>         slice n-1: flush large file N
>         slice n: iterate over small files
>         slice n+1: flush large file N+1
>
> So that we keep the disk busy with a relatively fair mix of
> small and large I/Os while both are necessary.

I am getting where you are coming from. But if we are going to make
changes to optimize for seeks maybe we need to be more aggressive in
write back in how we organize both time and location. Right now AFAIK
there is no attention to location in the writeback path.

>         The higher the bandwidth of the device, the more frequently
>         we need to be servicing the inodes with large amounts of
>         dirty data to be written to maintain write throughput at a
>         significant percentage of the device capability.
>

Could you expand that to say it's not the inodes of large files but
the ones with data that we can exploit locality? Often large files are
fragmented. Would it make more sense to pursue cracking the inodes and
grouping their blocks's locations? Or is this all overkill and should
be handled at a lower level like the elevator?

> BTW, it needs to be recognised that if we are under memory pressure
> we can clean much more memory in a short period of time by writing
> out all the large files first. This would clearly benefit the system
> as a whole as we'd get the most pages available for reclaim as
> possible in a short a time as possible. The writeback algorithm
> should really have a mode that allows this sort of flush ordering to
> occur....

I completely agree.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
