Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9A4436B00E7
	for <linux-mm@kvack.org>; Wed,  9 May 2012 08:53:22 -0400 (EDT)
Date: Wed, 9 May 2012 13:37:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2 v2] Flexible proportions for BDIs
Message-ID: <20120509113720.GC5092@quack.suse.cz>
References: <1336084760-19534-1-git-send-email-jack@suse.cz>
 <20120507144344.GA13983@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120507144344.GA13983@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, peterz@infradead.org

  Hello,

On Mon 07-05-12 22:43:44, Wu Fengguang wrote:
> On Fri, May 04, 2012 at 12:39:18AM +0200, Jan Kara wrote:
> >   this is the second iteration of my patches for flexible proportions. Since
> > previous submission, I've converted BDI proportion calculations to use flexible
> > proportions so now we can test proportions in kernel. Fengguang, can you give
> > them a run in your JBOD setup? You might try to tweak VM_COMPLETIONS_PERIOD_LEN
> > if things are fluctuating too much... I'm not yet completely decided how to set
> > that constant. Thanks!
> 
> Kara, I've got some results and it's working great. Overall performance
> remains good. The default VM_COMPLETIONS_PERIOD_LEN = 0.5s is obviously
> too small, so I tried increasing it to 3s and then 8s. Results for xfs
> (which has most fluctuating IO completions and ditto for bdi_setpoint)
> are attached. The XFS result of vanilla 3.3 is also attached. The
> graphs are all for case bay/JBOD-2HDD-thresh=1000M/xfs-10dd.
  Thanks for testing! I agree that 0.5s period is probably on the low end.
OTOH 8s seems a bit too much. Consider two bdi's with vastly different
speeds - say their throughput ratio is 1:32 (e.g. an USB stick and a raid
backed storage). When you write to the fast storage, then stop and start
writing to the USB stick, then it will take 5 periods for bdi writeout
ratio to become 1:1 and another 4-5 periods to be close to real current
situation which is no IO to storage 100% io to USB stick. So with 8s period
this will give you total transition time ~80s with seems like too much to
me.
 
> Look at the gray "bdi setpoint" lines. The
> VM_COMPLETIONS_PERIOD_LEN=8s kernel is able to achieve roughly the
> same stable bdi_setpoint as the vanilla kernel, while being able to
> adapt to the balanced bdi_setpoint much more fast (actually now the
> bdi_setpoint is immediately close to the balanced value when
> balance_dirty_pages() starts throttling, while the vanilla kernel
> takes about 20 seconds for bdi_setpoint to grow up).
  Which graph is from which kernel? All four graphs have the same name so
I'm not sure...

  The faster (almost immediate) initial adaptation to bdi's writeout fraction
is mostly an effect of better normalization with my patches. Although it is
pleasant, it happens just at the moment when there is a small number of
periods with non-zero number of events. So more important for practice is
in my opininion to compare transition of computed fractions when workload
changes (i.e. we start writing to one bdi while writing to another bdi or
so).

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
