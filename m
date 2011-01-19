Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC0896B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 19:50:16 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E6B2D3EE0C2
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:50:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC4CE45DE58
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:50:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B348245DE55
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:50:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3B541DB803E
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:50:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 687AF1DB8038
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:50:13 +0900 (JST)
Date: Wed, 19 Jan 2011 09:44:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
Message-Id: <20110119094416.80b717df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
	<1294956035-12081-3-git-send-email-yinghan@google.com>
	<20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 12:02:51 -0800
Ying Han <yinghan@google.com> wrote:

> On Thu, Jan 13, 2011 at 4:11 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >
> > Please explain your handling of 'hierarchy' in description.
> I haven't thought through the 'hierarchy' handling in this patchset
> which I will probably put more thoughts in the following
> posts. Do you have recommendations on handing the 'hierarchy' ?
> 

For example, assume a Hierarchy like following.

 A
  \
   B 

B's usage is accoutned into A, too. So, it's difficult to determine when
A's kswapd should run if
 - A's kswapd runs only against 'A'
 - A's kswapd just see information of A's LRU
 - B has its own kswapd...this means A has 2 kswapd.
.....


What I think are 2 options.

(1) having one kswapd per hierarchy, IOW, B will never have hierarchy.
or
(2) having kswapd per cgroup but it shares mutex. Parent's kswapd will
   never run if one of children's run.

(1) sounds slow and handling of children's watermark will be serialized.
(2) sounds we may have too much worker.

I like something between (1) and (2) ;)   sqrt(num_of_cgroup) of kswapd
is good ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
