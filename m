Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 8A1736B005D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 01:33:31 -0500 (EST)
Message-ID: <50C03BF8.7050508@parallels.com>
Date: Thu, 06 Dec 2012 10:32:24 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory changes
References: <50B8F2F4.6000508@parallels.com> <20121203144310.7ccdbeb4.akpm@linux-foundation.org> <50BD86DE.6050700@parallels.com> <20121204152121.e5c33938.akpm@linux-foundation.org> <1354666628.6733.227.camel@calx> <20121204162411.700d4954.akpm@linux-foundation.org> <1354667937.6733.233.camel@calx> <50BF198D.3030509@parallels.com> <20121205140602.1d8340a8.akpm@linux-foundation.org>
In-Reply-To: <20121205140602.1d8340a8.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>

>> For what is required for checkpoint-restore is -- we want to query the kernel
>> for "what pages has been written to since moment X". But this "moment X" is
>> a little bit more tricky than just "mark all pages r/o". Consider we're doing
>> this periodically. So when defining the moment X for the 2nd time we should
>> query the "changed" state and remap the respective page r/o atomically. Full
>> snapshot is actually not required, since we don't need to keep the old copy
>> of a page that is written to. Just a sign, that this page was modified is OK.
> 
> How is all this going to work, btw?  What is the interface to query
> page states and set them read-only?  How will dirty pagecache and dirty
> swapcache be handled?  And anonymous memory?

To begin with -- currently criu dumps lots of information about process by 
injecting a parasite code into the process [1] and working on the process
state as if it was this very process dumping himself.

That said, the proposed in this set API is about to be used like this:

1. A daemon is started, that turns tracing on, enables proposed mmu.* events
   and starts listening for them.
2. The parasite code gets injected into target task. This parasite knows
   which mapping(s) we're about to take to the image.
3. The parasite first sends the needed pages [2] to the image file.
4. Then parasite calls the proposed madvise(MADV_TRACE) on the mapping. When
   called, the respective mapping is marked with VM_TRACE bit and all the
   pages are remaped in ro.
5. After this parasite can be removed and the target task is continued.

If after this a process writes to some page the #PF occurs and the respective
event is send via tracing engine. Next time, when we want to take incremental
dump, we repeat steps 2 through 5, with a small change -- in step 3 parasite
requests the daemon from step 1 which pages has been changes since last time
and dumps only those into new image.

The state of swapcache (clean or dirty) doesn't matter in this case. If the
page is in swap and pte contains swap entry, we'll note this from pagemap file
and will take the page into image in the first pass. If later a process writes
to the page it will go through do_swap_page -> do_wp_page and the modification
event will be sent and caught by daemon from step 1.

The pagecache is completely out of the scope since criu doesn't dump the
contents of file mappings and doesn't snapshot filesystem state. It only
works with process' state. Filesystem state, that corresponds to process state
should be created with other means, e.g. lvm snapshot or rsync while tasks
are stopped. I've tried to explain this in more details here [3].


Thanks,
Pavel

[1] http://lwn.net/Articles/454304/
[2] Looking a the /proc/PID/pagemap file
[3] https://plus.google.com/103175467322423551911/posts/UAtVKaQcKsx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
