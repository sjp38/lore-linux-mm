Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE586B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:01:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 96E4D3EE0C5
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:01:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BA5545DE5C
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:01:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F3A445DE56
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:01:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B109E08001
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:01:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD6CEE38002
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:00:59 +0900 (JST)
Date: Thu, 20 Oct 2011 10:59:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD] Isolated memory cgroups again
Message-Id: <20111020105950.fd04f58f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111020013305.GD21703@tiehlicka.suse.cz>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@HansenPartnership.com>

On Wed, 19 Oct 2011 18:33:09 -0700
Michal Hocko <mhocko@suse.cz> wrote:

> Hi all,
> this is a request for discussion (I hope we can touch this during memcg
> meeting during the upcoming KS). I have brought this up earlier this
> year before LSF (http://thread.gmane.org/gmane.linux.kernel.mm/60464).
> The patch got much smaller since then due to excellent Johannes' memcg
> naturalization work (http://thread.gmane.org/gmane.linux.kernel.mm/68724)
> which this is based on.

Yes, Johannes' work will make isolation smarter.


> I realize that this will be controversial but I would like to hear
> whether this is strictly no-go or whether we can go that direction (the
> implementation might differ of course).
> 
> The patch is still half baked but I guess it should be sufficient to
> show what I am trying to achieve.
> The basic idea is that memcgs would get a new attribute (isolated) which
> would control whether that group should be considered during global
> reclaim.
> This means that we could achieve a certain memory isolation for
> processes in the group from the rest of the system activity which has
> been traditionally done by mlocking the important parts of memory.
> This approach, however, has some advantages. First of all, it is a kind
> of all or nothing type of approach. Either the memory is important and
> mlocked or you have no guarantee that it keeps resident. 
> Secondly it is much more prone to OOM situation.
> Let's consider a case where a memory is evictable in theory but you
> would pay quite much if you have to get it back resident (pre calculated
> data from database - e.g. reports). The memory wouldn't be used very
> often so it would be a number one candidate to evict after some time.
> We would want to have something like a clever mlock in such a case which
> would evict that memory only if the cgroup itself gets under memory
> pressure (e.g. peak workload). This is not hard to do if we are not
> over committing the memory but things get tricky otherwise.
> With the isolated memcgs we get exactly such a guarantee because we would
> reclaim such a memory only from the hard limit reclaim paths or if the
> soft limit reclaim if it is set up.
> 
> Any thoughts comments?
> 

I can only say
 - it can be implemented in a clean way.
 - maybe customers wants it.
 - This kinds of "mlock" can be harmful and make system admin difficult.
 - I'm not sure there will be a chance for security issue, DOS attack.

Hmm...if the number of isolated pages can be shown in /proc/meminfo,
I'll not have strong NACK.

But I personally think we should make softlimit better rather than
adding new interface. If this feature can be archieved when setting
softlimit=UNLIMITED, it's simple. And Johannes' work will make this
easy to be implemented.
(total rewrite of softlimit should be required...I think.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
