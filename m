Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 70DB36B0099
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 18:48:27 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wp4so11208616obc.10
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:48:27 -0800 (PST)
Received: from smtp100.ord1c.emailsrvr.com (smtp100.ord1c.emailsrvr.com. [108.166.43.100])
        by mx.google.com with ESMTPS id c132si4621500oib.141.2015.02.03.15.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 15:48:26 -0800 (PST)
Message-ID: <54D15E47.8020007@jolla.com>
Date: Wed, 04 Feb 2015 01:48:23 +0200
From: =?windows-1252?Q?Pasi_Sj=F6holm?= <pasi.sjoholm@jolla.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/swapfile.c: use spin_lock_bh with swap_lock to avoid
 deadlocks
References: <1422894328-23051-1-git-send-email-pasi.sjoholm@jolla.com> <20150203131437.GA8914@dhcp22.suse.cz>
In-Reply-To: <20150203131437.GA8914@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?windows-1252?Q?Pasi_Sj=F6holm?= <pasi.sjoholm@jollamobile.com>

On 03.02.2015 15:14, Michal Hocko wrote:
>> It is possible to get kernel in deadlock-state if swap_lock is not locked
>> with spin_lock_bh by calling si_swapinfo() simultaneously through
>> timer_function and registered vm shinker callback-function.
>>
>> BUG: spinlock recursion on CPU#0, main/2447
>> lock: swap_lock+0x0/0x10, .magic: dead4ead, .owner: main/2447, .owner_cpu: 0
>> [<c010b938>] (unwind_backtrace+0x0/0x11c) from [<c03e9be0>] (do_raw_spin_lock+0x48/0x154)
>> [<c03e9be0>] (do_raw_spin_lock+0x48/0x154) from [<c0226e10>] (si_swapinfo+0x10/0x90)
>> [<c0226e10>] (si_swapinfo+0x10/0x90) from [<c04d7e18>] (timer_function+0x24/0x258)
> Who is calling si_swapinfo from timer_function? AFAICS the vanilla
> kernel doesn't do that. Or am I missing something?

Nothing in vanilla kernel, but "memnotify"
(https://lkml.org/lkml/2012/1/17/182) together with modified
lowmemorykiller (drivers/staging/android/lowmemorykiller.c) which takes
in account also the available swap (calling si_swapinfo as well) will
cause the deadlock.

Memnotify uses timer (with backoff) for checking the memory pressure
which can be then used to let the processes itself adjust their memory
pressure before getting killed by the modified lowmemorykiller.

Br,
Pasi






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
