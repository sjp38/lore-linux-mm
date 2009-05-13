Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 05CC26B00AF
	for <linux-mm@kvack.org>; Tue, 12 May 2009 20:45:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D0jrjc030359
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 09:45:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C87C45DE62
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:45:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB4F445DD79
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:45:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA7621DB8041
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:45:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67FBD1DB803B
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:45:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped pages from reclaim
In-Reply-To: <alpine.DEB.1.10.0905121650090.14226@qirst.com>
References: <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com>
Message-Id: <20090513084306.5874.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 09:45:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> All these expiration modifications do not take into account that a desktop
> may sit idle for hours while some other things run in the background (like
> backups at night or updatedb and other maintenance things). This still
> means that the desktop will be usuable in the morning.

Have you seen this phenomenom?
I always use linux desktop for development. but I haven't seen it.
perhaps I have no luck. I really want to know reproduce way.

Please let me know reproduce way.


> I have had some success with a patch that protects a pages in the file
> cache from being unmapped if the mapped pages are below a certain
> percentage of the file cache. Its another VM knob to define the percentage
> though.
> 
> 
> Subject: Do not evict mapped pages
> 
> It is quite annoying when important executable pages of the user interface
> are evicted from memory because backup or some other function runs and no one
> is clicking any buttons for awhile. Once you get back to the desktop and
> try to click a link one is in for a surprise. It can take quite a long time
> for the desktop to recover from the swap outs.
> 
> This patch ensures that mapped pages in the file cache are not evicted if there
> are a sufficient number of unmapped pages present. A similar technique is
> already in use under NUMA for zone reclaim. The same method can be used to
> protect mapped pages from reclaim.

note: (a bit offtopic)

some Nehalem machine has long node distance and enabled zone reclaim mode.
but it cause terrible result.

it only works on large numa.

> 
> The percentage of file backed pages protected is set via
> /proc/sys/vm/file_mapped_ratio. This defaults to 20%.

Why do you think typical mapped ratio is less than 20% on desktop machine?

Some desktop component (e.g. V4L, GEM, some game) use tons mapped page.
but in the other hand, another some desktop user only use browser.
So we can't assume typical mapped ratio on desktop, IMHO.

Plus, typical desktop user don't set any sysctl value.

key point is access-once vs access-many.
I don't think mapped ratio is good approximation value.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
