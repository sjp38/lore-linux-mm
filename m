Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 133F16B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 05:04:08 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p0JA41Hi002571
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 02:04:01 -0800
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by wpaz5.hot.corp.google.com with ESMTP id p0JA3x1a010091
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 02:03:59 -0800
Received: by pvg13 with SMTP id 13so108762pvg.10
        for <linux-mm@kvack.org>; Wed, 19 Jan 2011 02:03:58 -0800 (PST)
Date: Wed, 19 Jan 2011 02:03:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
In-Reply-To: <20110119114735.aea5698f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1101190200120.3623@chino.kir.corp.google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com> <1294956035-12081-3-git-send-email-yinghan@google.com> <20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
 <alpine.DEB.2.00.1101181227220.18781@chino.kir.corp.google.com> <AANLkTi=oFTf9pLKdBU4wXm4tTsWjH+E2q9d5_nm_7gt9@mail.gmail.com> <20110119095650.02db87e0.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1101181831110.25382@chino.kir.corp.google.com>
 <20110119114735.aea5698f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011, KAMEZAWA Hiroyuki wrote:

> I know.
> 
> THIS PATCH's min_free_kbytes is not the same to ZONE's one. It's just a
> trigger. This patch's one is not used to limit charge() or for handling
> gfp_mask.
> (We can assume it's always GFP_HIGHUSER_MOVABLE or GFP_USER in some cases.)
> 
> So, I wrote the name of 'min_free_kbytes' in _this_ patch is a source of
> confusion. I don't recommend to use such name in _this_ patch.
> 

Agree with respect to memcg min_free_kbytes.  I think it would be 
preferrable, however, to have a single tunable for which oom killed tasks 
may access a privileged pool of memory to avoid the aforementioned DoS and 
base all other watermarks off that value just like it happens for the 
global case.  Your point about throttling cpu for background reclaim is 
also a good one: I think we should be able to control the aggressiveness 
of memcg background reclaim with an additional property of memcg where a 
child memcg cannot be more aggressive than a parent, but I think the 
watermark should be internal to the subsystem itself and, perhaps, based 
on the user tunable that determines how much memory is accessible by only 
oom killed tasks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
