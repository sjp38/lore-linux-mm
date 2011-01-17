Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF788D0039
	for <linux-mm@kvack.org>; Sun, 16 Jan 2011 21:31:03 -0500 (EST)
Date: Sun, 16 Jan 2011 18:30:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: hunting an IO hang
Message-Id: <20110116183000.cc632557.akpm@linux-foundation.org>
In-Reply-To: <1295229722-sup-6494@think>
References: <1295225684-sup-7168@think>
	<AANLkTikBamG2NG6j-z9fyTx=mk6NXFEE7LpB5z9s6ufr@mail.gmail.com>
	<4D339C87.30100@fusionio.com>
	<1295228148-sup-7379@think>
	<AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
	<AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
	<1295229722-sup-6494@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

(lots of cc's added)

On Sun, 16 Jan 2011 21:07:40 -0500 Chris Mason <chris.mason@oracle.com> wrote:

> Excerpts from Linus Torvalds's message of 2011-01-16 20:53:04 -0500:
> > .. except I actually didn't add Andrew to the cc after all.
> > 
> > NOW I did.
> > 
> > Oh, and if you can repeat this and bisect it, it would obviously be
> > great. But that sounds rather painful.
> 
> Ok, so I've got 3 different problems in 3 totally different areas.
> I'm running w/kvm, but this VM is very stable with 2.6.37.  Running
> Linus' current git it goes boom in exotic ways, this time it was only on
> ext3, btrfs code never loaded.
> 
> Linus, if you're planning on rc1 tonight I'll send my pull request out
> the door.  Otherwise I'd prefer to fix this and send my pull after
> actually getting a long btrfs run on the current code.
> 
> Next up, CONFIG_DEBUG*, always an adventure on rc1 kernels ;)
> 
> WARNING: at lib/list_debug.c:57 list_del+0xc0/0xed()
> Hardware name: Bochs
> list_del corruption. next->prev should be ffffea000010cde0, but was ffff88007cff6bc8
> Modules linked in:
> Pid: 524, comm: kswapd0 Not tainted 2.6.37-josef+ #180
> Call Trace:
>  [<ffffffff8106ec94>] ? warn_slowpath_common+0x85/0x9d
>  [<ffffffff8106ed4f>] ? warn_slowpath_fmt+0x46/0x48
>  [<ffffffff81263d6c>] ? list_del+0xc0/0xed
>  [<ffffffff81106d9d>] ? migrate_pages+0x26f/0x357
>  [<ffffffff81100e18>] ? compaction_alloc+0x0/0x2dc
>  [<ffffffff8110150d>] ? compact_zone+0x391/0x5c4
>  [<ffffffff81101905>] ? compact_zone_order+0xc2/0xd1
>  [<ffffffff815c321e>] ? _raw_spin_unlock+0xe/0x10
>  [<ffffffff810dc446>] ? kswapd+0x5c8/0x88f
>  [<ffffffff810dbe7e>] ? kswapd+0x0/0x88f
>  [<ffffffff81089ce8>] ? kthread+0x82/0x8a
>  [<ffffffff810347d4>] ? kernel_thread_helper+0x4/0x10
>  [<ffffffff81089c66>] ? kthread+0x0/0x8a
>  [<ffffffff810347d0>] ? kernel_thread_helper+0x0/0x10
> ---[ end trace 5c6b7933d16b301f ]---

uh-oh.  Does disabling CONFIG_COMPACTION make this go away (requires
disabling CONFIG_TRANSPARENT_HUGEPAGE first).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
