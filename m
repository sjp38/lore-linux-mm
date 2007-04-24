From: Neil Brown <neilb@suse.de>
Date: Tue, 24 Apr 2007 12:58:12 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17965.29252.950216.971096@notabene.brown>
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
In-Reply-To: message from Peter Zijlstra on Friday April 20
References: <20070420155154.898600123@chello.nl>
	<20070420155503.608300342@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Friday April 20, a.p.zijlstra@chello.nl wrote:
> Scale writeback cache per backing device, proportional to its writeout speed.

So it works like this:

 We account for writeout in full pages.
 When a page has the Writeback flag cleared, we account that as a
 successfully retired write for the relevant bdi.
 By using floating averages we keep track of how many writes each bdi
 has retired 'recently' where the unit of time in which we understand
 'recently' is a single page written.

 We keep a floating average for each bdi, and a floating average for
 the total writeouts (that 'average' is, of course, 1.)

 Using these numbers we can calculate what faction of 'recently'
 retired writes were retired by each bdi (get_writeout_scale).

 Multiplying this fraction by the system-wide number of pages that are
 allowed to be dirty before write-throttling, we get the number of
 pages that the bdi can have dirty before write-throttling the bdi.

 I note that the same fraction is *not* applied to background_thresh.
 Should it be?  I guess not - there would be interesting starting
 transients, as a bdi which had done no writeout would not be allowed
 any dirty pages, so background writeout would start immediately,
 which isn't what you want... or is it?

 For each bdi we also track the number of (dirty, writeback, unstable)
 pages and do not allow this to exceed the limit set for this bdi.

 The calculations involving 'reserve' in get_dirty_limits are a little
 confusing.  It looks like you calculating how much total head-room
 there is for the bdi (pages that the system can still dirty - pages
 this bdi has dirty) and making sure the number returned in pbdi_dirty
 doesn't allow more than that to be used.  This is probably a
 reasonable thing to do but it doesn't feel like the right place.  I
 think get_dirty_limits should return the raw threshold, and
 balance_dirty_pages should do both tests - the bdi-local test and the
 system-wide test.

 Currently you have a rather odd situation where
+			if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
+				break;
 might included numbers obtained with bdi_stat_sum being compared with
 numbers obtained with bdi_stat.


 With these patches, the VM still (I think) assumes that each BDI has
 a reasonable queue limit, so that writeback_inodes will block on a
 full queue.  If a BDI has a very large queue, balance_dirty_pages
 will simply turn lots of DIRTY pages into WRITEBACK pages and then
 think "We've done our duty" without actually blocking at all.

 With the extra accounting that we now have, I would like to see
 balance_dirty_pages dirty pages wait until RECLAIMABLE+WRITEBACK is
 actually less than 'threshold'.  This would probably mean that we
 would need to support per-bdi background_writeout to smooth things
 out.  Maybe that it fodder for another patch-set.

 You set:
+	vm_cycle_shift = 1 + ilog2(vm_total_pages);

 Can you explain that?  My experience is that scaling dirty limits
 with main memory isn't what we really want.  When you get machines
 with very large memory, the amount that you want to be dirty is more
 a function of the speed of your IO devices, rather than the amount
 of memory, otherwise you can sometimes see large filesystem lags
 ('sync' taking minutes?)

 I wonder if it makes sense to try to limit the dirty data for a bdi
 to the amount that it can write out in some period of time - maybe 3
 seconds.  Probably configurable.  You seem to have almost all the
 infrastructure in place to do that, and I think it could be a
 valuable feature.

 At least, I think vm_cycle_shift should be tied (loosely) to 
   dirty_ratio * vm_total_pages
 ??

On the whole, looks good!

Thanks,
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
