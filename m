Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 101C26B0069
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 13:42:00 -0400 (EDT)
Date: Tue, 5 Jun 2012 13:41:57 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: write-behind on streaming writes
Message-ID: <20120605174157.GC28556@redhat.com>
References: <20120528114124.GA6813@localhost>
 <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost>
 <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
 <20120530032129.GA7479@localhost>
 <20120605172302.GB28556@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605172302.GB28556@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Jun 05, 2012 at 01:23:02PM -0400, Vivek Goyal wrote:
> On Wed, May 30, 2012 at 11:21:29AM +0800, Fengguang Wu wrote:
> 
> [..]
> > (2) comes from the use of _WAIT_ flags in
> > 
> >         sync_file_range(..., SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER);
> > 
> > Each sync_file_range() syscall will submit 8MB write IO and wait for
> > completion. That means the async write IO queue constantly swing
> > between 0 and 8MB fillness at the frequency (100MBps / 8MB = 12.5ms).
> > So on every 12.5ms, the async IO queue runs empty, which gives any
> > pending read IO (from firefox etc.) a chance to be serviced. Nice
> > and sweet breaks!
> 
> I doubt that async IO queue is empty for 12.5ms. We wait for previous
> range to finish (index-1) and have already started the IO on next 8MB
> of pages. So effectively that should keep 8MB of async IO in
> queue (until and unless there are delays from user space side). So reason
> for latency improvement might be something else and not because async
> IO queue is empty for some time.

With sync_file_range() test, we can have 8MB of IO in flight. Without that
I think we can have more at times and that might be the reason for latency
improvement.

I see that CFQ has code to allow deeper NCQ depth if there is only a single
writer. So once a reader comes along it might find tons of async IO
already in flight. sync_file_range() will limit that in flight IO hence
the latency improvement. So if we have multiple dd doing sync_file_range()
then probably this latency improvement should go away.

I will run some tests to verify if my understanding about deeper queue
depths in case of single writer is correct or not.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
