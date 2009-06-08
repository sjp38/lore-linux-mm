Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 040046B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:37:34 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E2C8F82C4DD
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 12:14:09 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id G1SJdw4KYgSR for <linux-mm@kvack.org>;
	Mon,  8 Jun 2009 12:14:05 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 73FA382C4DB
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 12:14:02 -0400 (EDT)
Date: Mon, 8 Jun 2009 11:34:06 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
 citizen
In-Reply-To: <20090608091201.953724007@intel.com>
Message-ID: <alpine.DEB.1.10.0906081126260.5754@gentwo.org>
References: <20090608091044.880249722@intel.com> <20090608091201.953724007@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jun 2009, Wu Fengguang wrote:

> 1.2) test scenario
>
> - nfsroot gnome desktop with 512M physical memory
> - run some programs, and switch between the existing windows
>   after starting each new program.

Is there a predefined sequence or does this vary between tests? Scripted?

What percentage of time is saved in the test after due to the
modifications?
Around 20%?

> (1) begin:     shortly after the big read IO starts;
> (2) end:       just before the big read IO stops;
> (3) restore:   the big read IO stops and the zsh working set restored
> (4) restore X: after IO, switch back and forth between the urxvt and firefox
>                windows to restore their working set.

Any action done on the firefox sessions? Or just switch to a firefox
session that needs to redraw?

> The above console numbers show that
>
> - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
>   I'd attribute that improvement to the mmap readahead improvements :-)

So there are other effects,,, You not measuring the effect only this
patchset?

> - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
>   That's a huge improvement - which means with the VM_EXEC protection logic,
>   active mmap pages is pretty safe even under partially cache hot streaming IO.

Looks good.

> - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
>   dropped pages are mostly inactive ones. The patch has almost no impact in
>   this aspect, that means it won't unnecessarily increase memory pressure.
>   (In contrast, your 20% mmap protection ratio will keep them all, and
>   therefore eliminate the extra 41 major faults to restore working set
>   of zsh etc.)

Good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
