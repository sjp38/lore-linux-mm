Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 003366B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 23:43:56 -0400 (EDT)
Date: Wed, 11 May 2011 20:51:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
Message-Id: <20110511205110.354fa05e.akpm@linux-foundation.org>
In-Reply-To: <20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
	<20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, 12 May 2011 10:35:03 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > What (user-visible) problem is this patchset solving?
> > 
> > IOW, what is the current behaviour, what is wrong with that behaviour
> > and what effects does the patchset have upon that behaviour?
> > 
> > The sole answer from the above is "latency spikes".  Anything else?
> > 
> 
> I think this set has possibility to fix latency spike. 
> 
> For example, in previous set, (which has tuning knobs), do a file copy
> of 400M file under 400M limit.
> ==
> 1) == hard limit = 400M ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx                
> real    0m7.353s
> user    0m0.009s
> sys     0m3.280s
> 
> 2) == hard limit 500M/ hi_watermark = 400M ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx
> 
> real    0m6.421s
> user    0m0.059s
> sys     0m2.707s
> ==
> and in both case, memory usage after test was 400M.

I'm surprised that reclaim consumed so much CPU.  But I guess that's a
200,000 page/sec reclaim rate which sounds high(?) but it's - what -
15,000 CPU clocks per page?  I don't recall anyone spending much effort
on instrumenting and reducing CPU consumption in reclaim.

Presumably there will be no improvement in CPU consumption on
uniprocessor kernels or in single-CPU containers.  More likely a
deterioration.


ahem.

Copying a 400MB file in a non-containered kernel on this 8GB machine
with old, slow CPUs takes 0.64 seconds systime, 0.66 elapsed.  Five
times less than your machine.  Where the heck did all that CPU time go?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
