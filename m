Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 301BB600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 09:03:36 -0400 (EDT)
Date: Sun, 1 Aug 2010 21:03:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100801130300.GA19523@localhost>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
 <1280497020-22816-7-git-send-email-mel@csn.ul.ie>
 <20100730150601.199c5618.akpm@linux-foundation.org>
 <20100801115640.GA18943@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100801115640.GA18943@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, pvz@pvz.pp.se, bgamari@gmail.com, larppaxyz@gmail.com, seanj@xyke.com, kernel-bugs.dev1world@spamgourmet.com, akatopaz@gmail.com, frankrq2009@gmx.com, thomas.pi@arcor.de, spawels13@gmail.com, vshader@gmail.com, rockorequin@hotmail.com, ylalym@gmail.com, theholyettlz@googlemail.com, hassium@yandex.ru
List-ID: <linux-mm.kvack.org>

On Sun, Aug 01, 2010 at 07:56:40PM +0800, Wu Fengguang wrote:
> > Sigh.  We have sooo many problems with writeback and latency.  Read
> > https://bugzilla.kernel.org/show_bug.cgi?id=12309 and weep.  Everyone's
> > running away from the issue and here we are adding code to solve some
> > alleged stack-overflow problem which seems to be largely a non-problem,
> > by making changes which may worsen our real problems.
> 
> I'm sweeping bug 12309. Most people reports some data writes, though
> relative few explicitly stated memory pressure is another necessary
> condition.

#14: Per von Zweigbergk
Ubuntu 2.6.27 slowdown when copying 25MB/s USB stick to 10 MB/s SSD.

KOSAKI and my patches won't fix 2.6.27, since it only do
congestion_wait() and wait_on_page_writeback() for order>3
allocations. There may be more bugs there.

#24: Per von Zweigbergk
The encryption of the SSD very significantly increases the problem.

This is expected. Data encryption roughly doubles page consumption
speed (there may be temp buffers allocated/dropped quickly), hence
vmscan pressure.

#26: Per von Zweigbergk
Disabling swap makes the terminal launch much faster while copying;
However Firefox and vim hang much more aggressively and frequently
during copying.

It's interesting to see processes behave differently. Is this
reproducible at all?

#34: Ben Gamari
There is evidence that x86-64 is a factor here.

Because x86-64 does order-1 page allocation in fork() and consumes
more memory (larger user space code/data)?

#36: Lari Temmes
Go from usable to totally unusable when switching from
a SMP kernel to a UP kernel on a single CPU laptop

He should be testing 2.6.28. I'm not aware of known bugs there.

#47: xyke
Renicing pdflush -10 had some great improvement on basic
responsiveness.

It sure helps :)

Too much (old) messages there. I'm hoping some of the still active
bug reporters to test the following patches (they are for the -mmotm
tree, need to unindent code for Linus's tree) and see if there are
any improvements.

http://lkml.org/lkml/2010/8/1/40
http://lkml.org/lkml/2010/8/1/45

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
