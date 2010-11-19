Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9346B0085
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 06:39:30 -0500 (EST)
Date: Fri, 19 Nov 2010 12:39:10 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/6] memcg: make mem_cgroup_page_stat() return value
 unsigned
Message-ID: <20101119113910.GD24635@cmpxchg.org>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
 <1289294671-6865-7-git-send-email-gthelen@google.com>
 <20101112082921.GH9131@cmpxchg.org>
 <xr937hgixok4.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr937hgixok4.fsf@ninji.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 12, 2010 at 12:41:15PM -0800, Greg Thelen wrote:
> >> mem_cgroup_page_stat() has changed so it never returns
> >> error so convert the return value to the traditional page
> >> count type (unsigned long).
> >
> > This changelog feels a bit beside the point.
> >
> > What's really interesting is that we now don't consider negative sums
> > to be invalid anymore, but just assume zero!  There is a real
> > semantical change here.
> 
> Prior to this patch series mem_cgroup_page_stat() returned a negative
> value (specifically -EINVAL) to indicate that the current task was in
> the root_cgroup and thus the per-cgroup usage and limit counter were
> invalid.  Callers treated all negative values as an indication of
> root-cgroup message.
> 
> Unfortunately there was another way that mem_cgroup_page_stat() could
> return a negative value even when current was not in the root cgroup.
> Negative sums were a possibility due to summing of unsynchronized
> per-cpu counters.  These occasional negative sums would fool callers
> into thinking that the current task was in the root cgroup.
> 
> Would adding this description to the commit message address your
> concerns?

I'd just describe that summing per-cpu counters is racy, that we can
end up with negative results, and the only sensible handling of that
is to assume zero.

> > That the return type can then be changed to unsigned long is a nice
> > follow-up cleanup that happens to be folded into this patch.
> 
> Good point.  I can separate the change into two sub-patches:
> 1. use zero for a min-value (as described above)
> 2. change return value to unsigned

Sounds good.  You can just fold the previous patch (adjusting the
callsites) into 2, which should take care of the ordering problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
