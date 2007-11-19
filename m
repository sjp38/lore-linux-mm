Date: Mon, 19 Nov 2007 18:39:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: page_referenced() and VM_LOCKED
Message-Id: <20071119183942.614771c2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <16909246.1195259556869.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com>
	<473D1BC9.8050904@google.com>
	<20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com>
	<16909246.1195259556869.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Hugh Dickins <hugh@veritas.com>, Ethan Solomita <solo@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Nov 2007 09:32:36 +0900 (JST)
kamezawa.hiroyu@jp.fujitsu.com wrote:

> >> > I would've thought the point was to treat locked pages as active, never
> >> > pushing them into the inactive list, but since that's not quite what's
> >> > happening I was hoping someone could give me a clue.
> >
> >Rik and Lee and others have proposed that we keep VM_LOCKED pages
> >off both active and inactive lists: that seems a better way forward.
> >
> agreed.
> 
> >> Then, "VM_LOCKED & not referenced" anon page is added to swap cache
> >> (before pushed back to active list)
> >> 
> >> Seems intended ?
> >
> >Not intended, no.  Rather a waste of swap.  How about this patch?
> >
> seems nice. I'd like to do some test in the next week,
> 
your patch helps the kernel to avoid a waste of Swap.

Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

==
I tested your patch on x86_64/6GiB memory, + 2.6.24-rc3.
mlock 5GiB and create 4GiB file by"dd".

[before patch]
MemTotal:      6072620 kB
MemFree:         50540 kB
Buffers:          4508 kB
Cached:         724828 kB
SwapCached:    5146960 kB
Active:        2683964 kB
Inactive:      3198752 kB

[after patch]
MemTotal:      6072620 kB
MemFree:         17112 kB
Buffers:          6816 kB
Cached:         744880 kB
SwapCached:      21724 kB
Active:        5175828 kB
Inactive:       744956 kB

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
