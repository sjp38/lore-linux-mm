Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 65F856B014C
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 10:43:53 -0400 (EDT)
Date: Tue, 21 Jun 2011 16:43:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm: completely disable THP by
 transparent_hugepage=never
Message-ID: <20110621144346.GQ20843@redhat.com>
References: <20110620165844.GA9396@suse.de>
 <4DFF7E3B.1040404@redhat.com>
 <4DFF7F0A.8090604@redhat.com>
 <4DFF8106.8090702@redhat.com>
 <4DFF8327.1090203@redhat.com>
 <4DFF84BB.3050209@redhat.com>
 <4DFF8848.2060802@redhat.com>
 <20110620182558.GF4749@redhat.com>
 <20110620192117.GG20843@redhat.com>
 <4E00192E.70901@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E00192E.70901@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 12:08:14PM +0800, Cong Wang wrote:
> The thing is that we can save ~10K by adding 3 lines of code as this
> patch showed, where else in kernel can you save 10K by 3 lines of code?
> (except some kfree() cases, of course) So, again, why not have it? ;)

Because you could save it with a more complicated patch that doesn't
cripple down functionality.

Sure you can save a ton more ram with one liner patches, just search
the callers of alloc_large_system_hash and reduce the number of
entries everywhere. Are you using dhash_entries=1 ihash_entries=1?
That alone would save a ton more than ~10k so you should add it to
command line if it isn't there but there are other hashes like these
that don't have dhash_entries parameters. You could add
khugepaged_hash_slots parameter too for example and set it == 1 with a
parameter to avoid crippling down functionality, that wouldn't even
increase complexity. Those kind of approaches that don't cripple down
features, are ok. Remvoing sysfs register is not ok and there's no
need of adding a =0 parameter when you can achieve the memory saving
without totally losing functionality.

I booted with 128m ram and I get 128KB (not ~8KB) allocated in the
dentry hash, 65KB allocated in the inode hash, 65KB in the TCP
established hash, 8KB in the route cache hash, 262KB in the bind hash,
10KB in the UDP hash, you can all reduce those to a few hundred bytes
and it'll still work just fine. So yeah with one liner patches you can
surely achieve more than this ~8KB gain, and with dhash_entries=1
ihash_entries=1 you'll already save hugely more than by booting with
transparent_hugepage=0 that avoids registering in sysfs and cripple
down functionality. If you make the khugepaged slots hash configurable
in size (keeping the current default) with a new param it will
_increase_ functionality as it will also allow to _increase_ its size
on huge systems or in special configurations that may benefit from a
larger hash.

Again if you want to optimize this ~8KB gain, I recommend to add a
param to make the hash size dynamic not to prevent the feature to ever
be enabled again, so by making the code more complex at least it will
also be useful if we want to increase the size hash at boot time (not
only to decrease it).

I guess however you may run into command line stringsize limit if you
add things like dhash_entries=1 for every single hash in the kernel...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
