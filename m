Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5187D6B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 13:18:55 -0400 (EDT)
Date: Tue, 5 Jun 2012 13:18:51 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: write-behind on streaming writes
Message-ID: <20120605171851.GA28556@redhat.com>
References: <20120528114124.GA6813@localhost>
 <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost>
 <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
 <20120530032129.GA7479@localhost>
 <20120605010148.GE4347@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605010148.GE4347@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Jun 05, 2012 at 11:01:48AM +1000, Dave Chinner wrote:
> On Wed, May 30, 2012 at 11:21:29AM +0800, Fengguang Wu wrote:
> > Linus,
> > 
> > On Tue, May 29, 2012 at 10:35:46AM -0700, Linus Torvalds wrote:
> > > On Tue, May 29, 2012 at 8:57 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> > > I just suspect that we'd be better off teaching upper levels about the
> > > streaming. I know for a fact that if I do it by hand, system
> > > responsiveness was *much* better, and IO throughput didn't go down at
> > > all.
> > 
> > Your observation of better responsiveness may well be stemmed from
> > these two aspects:
> > 
> > 1) lower dirty/writeback pages
> > 2) the async write IO queue being drained constantly
> > 
> > (1) is obvious. For a mem=4G desktop, the default dirty limit can be
> > up to (4096 * 20% = 819MB). While your smart writer effectively limits
> > dirty/writeback pages to a dramatically lower 16MB.
> > 
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
> > 
> > I suspect (2) contributes *much more* than (1) to desktop responsiveness.
> 
> Almost certainly, especially with NCQ devices where even if the IO
> scheduler preempts the write queue immediately, the device might
> complete the outstanding 31 writes before servicing the read which
> is issued as the 32nd command....

CFQ does preempt async IO once sync IO gets queued.

> 
> So NCQ depth is going to play a part here as well.

Yes NCQ depth does contribute primarily to READ latencies in presence of
async IO. I think disk drivers and disk firmware should also participate in 
prioritizing READs over pending WRITEs to improve the situation.

IO scheduler can only do so much. CFQ already tries hard to keep pending
async queue depth low and that results in lower throughput many a times
(as compared to deadline).

In fact CFQ tries so hard to prioritize SYNC IO over async IO, that I have
often heard cases of WRITEs being starved and people facing "task blocked
for 120 second warnings".

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
