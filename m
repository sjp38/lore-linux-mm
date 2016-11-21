Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D19556B04F8
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 11:31:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so395670340pgc.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 08:31:04 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id w5si23453653pgj.87.2016.11.21.08.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 Nov 2016 08:31:03 -0800 (PST)
Date: Mon, 21 Nov 2016 08:30:58 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161121163058.o2bob4kdyumv6txz@merlins.org>
References: <20161121154336.GD19750@merlins.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161121154336.GD19750@merlins.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vbabka@suse.cz

On Mon, Nov 21, 2016 at 07:43:36AM -0800, Marc MERLIN wrote:
> Howdy,
> 
> As a followup to https://plus.google.com/u/0/+MarcMERLIN/posts/A3FrLVo3kc6
> 
> http://pastebin.com/yJybSHNq and http://pastebin.com/B6xEH4Dw
> show a system with plenty of RAM (24GB) falling over and killing inoccent
> user space apps, a few hours after I start a 9TB copy between 2 raid5 arrays 
> both hosting bcache, dmcrypt and btrfs (yes, that's 3 layers under btrfs)
> 
> This kind of stuff worked until 4.6 if I'm not mistaken and started failing
> with 4.8 (I didn't try 4.7)
> 
> I tried applying
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9f7e3387939b036faacf4e7f32de7bb92a6635d6
> to 4.8.8 and it didn't help
> http://pastebin.com/2LUicF3k

My apologies. I'm actually wrong on that one bit.
That patch didn't actually apply on my kernel and I didn't end up
testing it, due to the failure/revert, it was just another test of the
same 4.8.8, so a worthless test.

That part of the patch is not compatible with 4.8.8:
--- mm/compaction.c
+++ mm/compaction.c
@@ -1660,7 +1664,8 @@
 		.classzone_idx = classzone_idx,
 		.direct_compaction = true,
 		.whole_zone = (prio == MIN_COMPACT_PRIORITY),
-		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY)
+		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
+		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);

Anyway, for now I'm going to test 
https://marc.info/?l=linux-mm&m=147423605024993
for real now (on top of 4.8.8)

If you'd like me to re-test the compaction patch with 4.8.8, please give
me one that is compatible with 4.8.8 but in the meantime, I'll try that
2nd patch on 4.8.8 and report back.

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
