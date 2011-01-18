Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB186B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:36:16 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p0IKaDFK018973
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:36:14 -0800
Received: from pvc22 (pvc22.prod.google.com [10.241.209.150])
	by hpaq14.eem.corp.google.com with ESMTP id p0IKZNNa011835
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:36:05 -0800
Received: by pvc22 with SMTP id 22so10445pvc.27
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:36:05 -0800 (PST)
Date: Tue, 18 Jan 2011 12:36:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
In-Reply-To: <AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1101181227220.18781@chino.kir.corp.google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com> <1294956035-12081-3-git-send-email-yinghan@google.com> <20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011, Ying Han wrote:

> I agree that "min_free_kbytes" concept doesn't apply well since there
> is no notion of "reserved pool" in memcg. I borrowed it at the
> beginning is to add a tunable to the per-memcg watermarks besides the
> hard_limit.

You may want to add a small amount of memory that a memcg may allocate 
from in oom conditions, however: memory reserves are allocated per-zone 
and if the entire system is oom and that includes several dozen memcgs, 
for example, they could all be contending for the same memory reserves.  
It would be much easier to deplete all reserves since you would have 
several tasks allowed to allocate from this pool: that's not possible 
without memcg since the oom killer is serialized on zones and does not 
kill a task if another oom killed task is already detected in the 
tasklist.

I think it would be very trivial to DoS the entire machine in this way: 
set up a thousand memcgs with tasks that have core_state, for example, and 
trigger them to all allocate anonymous memory up to their hard limit so 
they oom at the same time.  The machine should livelock with all zones 
having 0 pages free.

> I read the
> patch posted from Satoru Moriya "Tunable watermarks", and introducing
> the per-memcg-per-watermark tunable
> sounds good to me. Might consider adding it to the next post.
> 

Those tunable watermarks were nacked for a reason: they are internal to 
the VM and should be set to sane values by the kernel with no intevention 
needed by userspace.  You'd need to show why a memcg would need a user to 
tune its watermarks to trigger background reclaim and why that's not 
possible by the kernel and how this is a special case in comparsion to the 
per-zone watermarks used by the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
