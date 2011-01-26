Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 05FB48D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 17:29:54 -0500 (EST)
Date: Wed, 26 Jan 2011 14:29:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
Message-Id: <20110126142909.0b710a0c.akpm@linux-foundation.org>
In-Reply-To: <xr9362tbl83f.fsf@gthelen.mtv.corp.google.com>
References: <1296030555-3594-1-git-send-email-gthelen@google.com>
	<20110126170713.GA2401@cmpxchg.org>
	<xr93y667lgdm.fsf@gthelen.mtv.corp.google.com>
	<20110126183023.GB2401@cmpxchg.org>
	<xr9362tbl83f.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2011 12:32:04 -0800
Greg Thelen <gthelen@google.com> wrote:

> > That being said, does this have any practical impact at all?  I mean,
> > this code runs when the cgroup limit is breached.  But if the number
> > of allowed pages (not bytes!) can not fit into 32 bits, it means you
> > have a group of processes using more than 16T.  On a 32-bit machine.
> 
> The value of this patch is up for debate.  I do not have an example
> situation where this truncation causes the wrong thing to happen.  I
> suppose it might be possible for a racing update to
> memory.limit_in_bytes which grows the limit from a reasonable (example:
> 100M) limit to a large limit (example 1<<45) could benefit from this
> patch.  I admit that this case seems pathological and may not be likely
> or even worth bothering over.  If neither the memcg nor the oom
> maintainers want the patch, then feel free to drop it.  I just noticed
> the issue and thought it might be worth addressing.

Ah.  I was scratching my head over that.

In zillions of places the kernel assumes that a 32-bit kernel has less
than 2^32 pages of memory, so the code as it stands is, umm, idiomatic.

But afaict the only way the patch makes a real-world difference is if
res_counter_read_u64() is busted?

And, as you point out, res_counter_read_u64() is indeed busted on
32-bit machines.  It has 25 callsites in mm/memcontrol.c - has anyone
looked at the implications of this?  What happens in all those
callsites if the counter is read during a count rollover?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
