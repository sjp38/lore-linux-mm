Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A382A6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 01:35:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 81so132017382pgh.3
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 22:35:33 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id v67si1207859pgv.147.2017.04.02.22.35.32
        for <linux-mm@kvack.org>;
        Sun, 02 Apr 2017 22:35:32 -0700 (PDT)
Date: Mon, 3 Apr 2017 14:35:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm/crypto: add tunable compression algorithm for zswap
Message-ID: <20170403053530.GA7463@bbox>
References: <20170401211813.15146-1-vbabka@suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170401211813.15146-1-vbabka@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Apr 01, 2017 at 11:18:13PM +0200, Vlastimil Babka wrote:
> Zswap (and zram) save memory by compressing pages instead of swapping them
> out. This is nice, but with traditional compression algorithms such as LZO,
> one cannot know, how well the data will compress, so the overal savings are
> unpredictable. This is further complicated by the choice of zpool
> implementation for managing the compressed pages. Zbud and z3fold are
> relatively simple, but cannot store more then 2 (zbud) or 3 (z3fold)
> compressed pages in a page. The rest of the page is wasted. Zsmalloc is more
> flexible, but also more complex.
> 
> Clearly things would be much easier if the compression ratio was predictable.
> But why stop at that - what if we could actually *choose* the compression
> ratio? This patch introduces a new compression algorithm that can do just
> that! It's called Tunable COmpression, or TCO for short.

That was totally same I had an idea since long time ago but I don't
have enough to dive into that.
Thanks for raising an issue!

> 
> In this prototype patch, it offers three predefined ratios, but nothing
> prevents more fine-grained settings, except the current crypto API (or my
> limited knowledge of it, but I'm guessing nobody really expected the
> compression ratio to be tunable). So by doing
> 
> echo tco50 > /sys/module/zswap/parameters/compressor
> 
> you get 50% compression ratio, guaranteed! This setting and zbud are just the
> perfect buddies, if you prefer the nice and simple allocator. Zero internal
> fragmentation!
> 
> Or,
> 
> echo tco30 > /sys/module/zswap/parameters/compressor
> 
> is a great match for z3fold, if you want to be smarter and save 50% memory
> over zbud, again with no memory wasted! But why stop at that? If you do
> 
> echo tco10 > /sys/module/zswap/parameters/compressor

It's a great idea but a problem is we have very limited allocators.
In short future, people might want z4fold, z8fold, z10fold and so on.
So, I suggest to make zbud generic so it can cover every zXfold allocators.

> 
> within the next hour, and choose zsmalloc, you will be able to neatly store
> 10 compressed pages within a single page! Yes, 90% savings!
> In the full version of this patch, you'll be able to set any ratio, so you
> can decide exactly how much money to waste on extra RAM instead of compressing
> the data. Let TCO cut down your system's TCO!
> 
> This RFC was not yet tested, but it compiles fine and mostly passes checkpatch
> so it must obviously work.

I did test and found sometime crash happens but it's hard to reproduce.
It seems it's easier to reprocue the problem with tco50.

Even though I stare at the code in detail, I can't find any bugs.
Hmm, If there is an update in your side, let me know it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
