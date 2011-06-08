Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E03956B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 00:10:27 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D7A8B3EE0B5
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 13:10:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB5B645DE5B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 13:10:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BCE945DE56
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 13:10:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E174EF8005
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 13:10:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4479C1DB8046
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 13:10:23 +0900 (JST)
Date: Wed, 8 Jun 2011 13:03:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup
 aware
Message-Id: <20110608130315.0a365dbb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-12-git-send-email-gthelen@google.com>
	<20110607193835.GD26965@redhat.com>
	<xr93lixdv0df.fsf@gthelen.mtv.corp.google.com>
	<20110607210540.GB30919@redhat.com>
	<20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>

On Tue, 7 Jun 2011 21:02:21 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Tue, Jun 7, 2011 at 5:18 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 7 Jun 2011 17:05:40 -0400
> > Vivek Goyal <vgoyal@redhat.com> wrote:
> >
> >> On Tue, Jun 07, 2011 at 01:43:08PM -0700, Greg Thelen wrote:
> >> > Vivek Goyal <vgoyal@redhat.com> writes:
> >> >
> >> > > On Fri, Jun 03, 2011 at 09:12:17AM -0700, Greg Thelen wrote:
> >> > >> When the system is under background dirty memory threshold but a cgroup
> >> > >> is over its background dirty memory threshold, then only writeback
> >> > >> inodes associated with the over-limit cgroup(s).
> >> > >>
> >> > >
> >> > > [..]
> >> > >> -static inline bool over_bground_thresh(void)
> >> > >> +static inline bool over_bground_thresh(struct bdi_writeback *wb,
> >> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct writeback_control *wbc)
> >> > >> A {
> >> > >> A  A  A  A  A unsigned long background_thresh, dirty_thresh;
> >> > >>
> >> > >> A  A  A  A  A global_dirty_limits(&background_thresh, &dirty_thresh);
> >> > >>
> >> > >> - A  A  A  A return (global_page_state(NR_FILE_DIRTY) +
> >> > >> - A  A  A  A  A  A  A  A global_page_state(NR_UNSTABLE_NFS) > background_thresh);
> >> > >> + A  A  A  A if (global_page_state(NR_FILE_DIRTY) +
> >> > >> + A  A  A  A  A  A global_page_state(NR_UNSTABLE_NFS) > background_thresh) {
> >> > >> + A  A  A  A  A  A  A  A wbc->for_cgroup = 0;
> >> > >> + A  A  A  A  A  A  A  A return true;
> >> > >> + A  A  A  A }
> >> > >> +
> >> > >> + A  A  A  A wbc->for_cgroup = 1;
> >> > >> + A  A  A  A wbc->shared_inodes = 1;
> >> > >> + A  A  A  A return mem_cgroups_over_bground_dirty_thresh();
> >> > >> A }
> >> > >
> >> > > Hi Greg,
> >> > >
> >> > > So all the logic of writeout from mem cgroup works only if system is
> >> > > below background limit. The moment we cross background limit, looks
> >> > > like we will fall back to existing way of writting inodes?
> >> >
> >> > Correct. A If the system is over its background limit then the previous
> >> > cgroup-unaware background writeback occurs. A I think of the system
> >> > limits as those of the root cgroup. A If the system is over the global
> >> > limit than all cgroups are eligible for writeback. A In this situation
> >> > the current code does not distinguish between cgroups over or under
> >> > their dirty background limit.
> >> >
> >> > Vivek Goyal <vgoyal@redhat.com> writes:
> >> > > If yes, then from design point of view it is little odd that as long
> >> > > as we are below background limit, we share the bdi between different
> >> > > cgroups. The moment we are above background limit, we fall back to
> >> > > algorithm of sharing the disk among individual inodes and forget
> >> > > about memory cgroups. Kind of awkward.
> >> > >
> >> > > This kind of cgroup writeback I think will atleast not solve the problem
> >> > > for CFQ IO controller, as we fall back to old ways of writting back inodes
> >> > > the moment we cross dirty ratio.
> >> >
> >> > It might make more sense to reverse the order of the checks in the
> >> > proposed over_bground_thresh(): the new version would first check if any
> >> > memcg are over limit; assuming none are over limit, then check global
> >> > limits. A Assuming that the system is over its background limit and some
> >> > cgroups are also over their limits, then the over limit cgroups would
> >> > first be written possibly getting the system below its limit. A Does this
> >> > address your concern?
> >>
> >> Do you treat root group also as any other cgroup? If no, then above logic
> >> can lead to issue of starvation of root group inode. Or unfair writeback.
> >> So I guess it will be important to treat root group same as other groups.
> >>
> >
> > As far as I can say, you should not place programs onto ROOT cgroups if you need
> > performance isolation.
> 
> Agreed.
> 
> > From the code, I think if the system hits dirty_ratio, "1" bit of bitmap should be
> > set and background writeback can work for ROOT cgroup seamlessly.
> >
> > Thanks,
> > -Kame
> 
> Not quite.  The proposed patches do not set the "1" bit (css_id of
> root is 1).  mem_cgroup_balance_dirty_pages() (from patch 10/12)
> introduces the following balancing loop:
> +       /* balance entire ancestry of current's mem. */
> +       for (; mem_cgroup_has_dirty_limit(mem); mem =
> parent_mem_cgroup(mem)) {
> 
> The loop terminates when mem_cgroup_has_dirty_limit() is called for
> the root cgroup.  The bitmap is set in the body of the loop.  So the
> root cgroup's bit (bit 1) will never be set in the bitmap.  However, I
> think the effect is the same.  The proposed changes in this patch
> (11/12) have background writeback first checking if the system is over
> limit and if yes, then b_dirty inodes from any cgroup written.  This
> means that a small system background limit with an over-{fg or
> bg}-limit cgroup could cause other cgroups that are not over their
> limit to have their inodes written back.  In an system-over-limit
> situation normal system-wide bdi writeback is used (writing inodes in
> b_dirty order).  For those who want isolation, a simple rule to avoid
> this is to ensure that that sum of all cgroup background_limits is
> less than the system background limit.
> 

Hmm, should we add the rule ? 
How about disallowing to set dirty_ratio bigger than system's one ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
