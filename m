Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id C3C436B006C
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 16:48:13 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id z12so1818546lbi.4
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 13:48:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj9si5145627lad.108.2015.01.07.13.48.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 13:48:12 -0800 (PST)
Message-ID: <54ADA99A.90501@suse.cz>
Date: Wed, 07 Jan 2015 22:48:10 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Dirty pages underflow on 3.14.23
References: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com> <20150106150250.GA26895@phnom.home.cmpxchg.org> <alpine.LRH.2.02.1501061246400.16437@file01.intranet.prod.int.rdu2.redhat.com> <pan.2015.01.07.10.57.46@googlemail.com> <20150107212858.GA6664@hostway.ca>
In-Reply-To: <20150107212858.GA6664@hostway.ca>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Kirby <sim@hostway.ca>, Holger Hoffst?tte <holger.hoffstaette@googlemail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/07/2015 10:28 PM, Simon Kirby wrote:
> On Wed, Jan 07, 2015 at 10:57:46AM +0000, Holger Hoffst?tte wrote:
> 
>> On Tue, 06 Jan 2015 12:54:43 -0500, Mikulas Patocka wrote:
>> 
>> > I can't reprodce it. It happened just once.
>> > 
>> > That patch is supposed to fix an occasional underflow by a single page -
>> > while my meminfo showed underflow by 22952KiB (5738 pages).
>> 
>> You are probably looking for:
>> commit 835f252c6debd204fcd607c79975089b1ecd3472
>> "aio: fix uncorrent dirty pages accouting when truncating AIO ring buffer"
>> 
>> It definitely went into 3.14.26, don't know about 3.16.x.
> 
> I can confirm that a MySQL shutdown/restart triggers it for me, even
> immediately following a fresh boot:
> 
> # uname -a ; grep '^nr_dirty ' /proc/vmstat; /etc/init.d/mysql restart; \
>              grep '^nr_dirty ' /proc/vmstat
> Linux blue 3.16.6-blue #51 Mon Oct 20 14:00:47 PDT 2014 i686 GNU/Linux
> nr_dirty 13
> [ ok ] Stopping MySQL database server: mysqld.
> [ ok ] Starting MySQL database server: mysqld . ..
> [info] Checking for tables which need an upgrade, are corrupt or were not closed cleanly..
> nr_dirty 4294967245
> 
> Hmm...A possibly-related issue...Before trying this, after a fresh boot,
> /proc/vmstat showed:
> 
> nr_alloc_batch 4294541205

This can happen, and not be a problem in general. However, there was a fix
abe5f972912d086c080be4bde67750630b6fb38b in 3.17 for a potential performance
issue if this counter overflows on single processor configuration. It was marked
stable, but the 3.16 series was discontinued before the fix could be backported.
So if you are on single-core, you might hit the performance issue.

> and after the restart, it shows:
> 
> nr_alloc_batch 161
> 
> ...anyway, git cherry-pick ce4b66be6cd964e84363afd4a603633dd061b3b8 on
> 3.16.6 tree does seem to fix nr_dirty from underflowing...Yay!

Great!

> Still, nr_alloc_batch reads as 4294254379 after MySQL restart, and now
> seems to stay up there.

Hm if it stays there, then you are probably hitting the performance issue. Look
at /proc/zoneinfo, which zone has the underflow. It means this zone will get
unfair amount of allocations, while others may contain stale data and would be
better candidates.

> Simon-
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
