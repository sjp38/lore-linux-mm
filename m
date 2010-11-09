Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB406B0087
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:31:58 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oA9LVqJI006684
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:31:52 -0800
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by wpaz33.hot.corp.google.com with ESMTP id oA9LVWhD023225
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:31:51 -0800
Received: by pzk10 with SMTP id 10so532473pzk.24
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 13:31:51 -0800 (PST)
Date: Tue, 9 Nov 2010 13:31:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: fix unit mismatch in memcg oom limit
 calculation
In-Reply-To: <xr93iq068dyd.fsf@ninji.mtv.corp.google.com>
Message-ID: <alpine.DEB.2.00.1011091327420.7730@chino.kir.corp.google.com>
References: <20101109110521.GS23393@cmpxchg.org> <xr93iq068dyd.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010, Greg Thelen wrote:

> Johannes Weiner <hannes@cmpxchg.org> writes:
> 
> > Adding the number of swap pages to the byte limit of a memory control
> > group makes no sense.  Convert the pages to bytes before adding them.
> >
> > The only user of this code is the OOM killer, and the way it is used
> > means that the error results in a higher OOM badness value.  Since the
> > cgroup limit is the same for all tasks in the cgroup, the error should
> > have no practical impact at the moment.
> >
> > But let's not wait for future or changing users to trip over it.
> 
> Thanks for the fix.
> 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>
> 

Nice catch, but it's done in the opposite way: the oom killer doesn't use 
byte limits but page limits.  So this needs to be

	(res_counter_read_u64(&memcg->res, RES_LIMIT) >> PAGE_SHIFT) +
			total_swap_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
