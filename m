Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 12D4B6B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 17:42:34 -0400 (EDT)
Date: Thu, 20 Sep 2012 14:42:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] memory-hotplug: fix zone stat mismatch
Message-Id: <20120920144232.a3e8b60f.akpm@linux-foundation.org>
In-Reply-To: <1348123405-30641-1-git-send-email-minchan@kernel.org>
References: <1348123405-30641-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, 20 Sep 2012 15:43:25 +0900
Minchan Kim <minchan@kernel.org> wrote:

> During memory-hotplug, I found NR_ISOLATED_[ANON|FILE]
> are increasing so that kernel are hang out.
> 
> The cause is that when we do memory-hotadd after memory-remove,
> __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
> although vm_stat_diff of all CPU still have value.
> 
> In addtion, when we offline all pages of the zone, we reset them
> in zone_pcp_reset without drain so that we lost zone stat item.
> 

Here's what I ended up with for a changelog:

: During memory-hotplug, I found NR_ISOLATED_[ANON|FILE] are increasing,
: causing the kernel to hang.  When the system doesn't have enough free
: pages, it enters reclaim but never reclaim any pages due to
: too_many_isolated()==true and loops forever.
: 
: The cause is that when we do memory-hotadd after memory-remove,
: __zone_pcp_update() clears a zone's ZONE_STAT_ITEMS in setup_pageset()
: although the vm_stat_diff of all CPUs still have values.
: 
: In addtion, when we offline all pages of the zone, we reset them in
: zone_pcp_reset without draining so we loss some zone stat item.


As memory hotplug seems fairly immature and broken, I'm thinking
there's no point in backporting this into -stable.  And I don't *think*
we really need it in 3.6 either?  (It doesn't apply cleanly to current
mainline anyway - I didn't check why).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
