Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDBA6B0038
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 07:26:52 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so3222235wib.5
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 04:26:51 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lh1si2837094wjb.88.2015.02.04.04.26.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Feb 2015 04:26:50 -0800 (PST)
Date: Wed, 4 Feb 2015 13:26:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/swapfile.c: use spin_lock_bh with swap_lock to avoid
 deadlocks
Message-ID: <20150204122648.GD29434@dhcp22.suse.cz>
References: <1422894328-23051-1-git-send-email-pasi.sjoholm@jolla.com>
 <20150203131437.GA8914@dhcp22.suse.cz>
 <54D15E47.8020007@jolla.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54D15E47.8020007@jolla.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasi =?iso-8859-1?Q?Sj=F6holm?= <pasi.sjoholm@jolla.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pasi =?iso-8859-1?Q?Sj=F6holm?= <pasi.sjoholm@jollamobile.com>

On Wed 04-02-15 01:48:23, Pasi Sjoholm wrote:
> On 03.02.2015 15:14, Michal Hocko wrote:
> >> It is possible to get kernel in deadlock-state if swap_lock is not locked
> >> with spin_lock_bh by calling si_swapinfo() simultaneously through
> >> timer_function and registered vm shinker callback-function.
> >>
> >> BUG: spinlock recursion on CPU#0, main/2447
> >> lock: swap_lock+0x0/0x10, .magic: dead4ead, .owner: main/2447, .owner_cpu: 0
> >> [<c010b938>] (unwind_backtrace+0x0/0x11c) from [<c03e9be0>] (do_raw_spin_lock+0x48/0x154)
> >> [<c03e9be0>] (do_raw_spin_lock+0x48/0x154) from [<c0226e10>] (si_swapinfo+0x10/0x90)
> >> [<c0226e10>] (si_swapinfo+0x10/0x90) from [<c04d7e18>] (timer_function+0x24/0x258)
> > Who is calling si_swapinfo from timer_function? AFAICS the vanilla
> > kernel doesn't do that. Or am I missing something?
> 
> Nothing in vanilla kernel, but "memnotify"
> (https://lkml.org/lkml/2012/1/17/182) together with modified
> lowmemorykiller (drivers/staging/android/lowmemorykiller.c) which takes
> in account also the available swap (calling si_swapinfo as well) will
> cause the deadlock.
> 
> Memnotify uses timer (with backoff) for checking the memory pressure
> which can be then used to let the processes itself adjust their memory
> pressure before getting killed by the modified lowmemorykiller.

We are not usually changing the core kernel for an out of tree
functionality. So NAK to this patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
