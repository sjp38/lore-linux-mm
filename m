Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB916B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 15:30:14 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id s68so212732701ywg.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:30:14 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id j129si18103558ywe.259.2016.11.30.12.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 12:30:13 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id s68so15490139ywg.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:30:13 -0800 (PST)
Date: Wed, 30 Nov 2016 15:30:11 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161130203011.GB15989@htj.duckdns.org>
References: <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org>
 <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Marc MERLIN <marc@merlins.org>, Kent Overstreet <kent.overstreet@gmail.com>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Hello,

On Wed, Nov 30, 2016 at 10:14:50AM -0800, Linus Torvalds wrote:
> Tejun/Kent - any way to just limit the workqueue depth for bcache?
> Because that really isn't helping, and things *will* time out and
> cause those problems when you have hundreds of IO's queued on a disk
> that likely as a write iops around ~100..

Yeah, easily.  I'm assuming it's gonna be the bcache_wq allocated in
from bcache_init().  It's currently using 0 as @max_active and it can
set to be any arbitrary number.  It'd be a very crude way to control
what looks like a buffer bloat with IOs tho.  We can make it a bit
more granular by splitting workqueues per bcache instance / purpose
but for the long term the right solution seems to be hooking into
writeback throttling mechanism that block layer just grew recently.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
