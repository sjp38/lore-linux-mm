Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3B6456B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 16:40:04 -0400 (EDT)
Date: Wed, 8 Jun 2011 16:39:45 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup
 aware
Message-ID: <20110608203945.GF1150@redhat.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-12-git-send-email-gthelen@google.com>
 <20110607193835.GD26965@redhat.com>
 <xr93lixdv0df.fsf@gthelen.mtv.corp.google.com>
 <20110607210540.GB30919@redhat.com>
 <20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>

On Tue, Jun 07, 2011 at 09:02:21PM -0700, Greg Thelen wrote:

[..]
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

Ok, we seem to be mixing multiple things.

- First of all, i thought running apps in root group is very valid
  use case. Generally by default we run everything in root group and
  once somebody notices that an application or group of application
  is memory hog, that can be moved out in a cgroup of its own with
  upper limits.

- Secondly, root starvation issue is not present as long as we fall
  back to normal way of writting inodes once we have crossed dirty
  limit. But you had suggested that we move cgroup based writeout
  above so that we always use same scheme for writeout and that
  potentially will have root starvation issue.

- If we don't move it up, then atleast it will not work for CFQ IO
  controller.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
