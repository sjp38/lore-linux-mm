Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5A46B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 07:51:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so26675644pgd.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:51:01 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 19si52624363pfz.127.2016.12.14.04.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 04:51:00 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id x23so2402549pgx.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:51:00 -0800 (PST)
Date: Wed, 14 Dec 2016 21:50:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214125050.GC2883@tigerII.localdomain>
References: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
 <201612142037.EED00059.VJMOFLtSOQFFOH@I-love.SAKURA.ne.jp>
 <20161214123644.GE16064@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214123644.GE16064@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On (12/14/16 13:36), Petr Mladek wrote:
[..]
> [*] The async printk patchset is flying around in many
>     modifications for years. I am more optimistic after
>     the discussions on the last Kernel Summit. Anyway,
>     it will not be in mainline before 4.12.
> 
> [**] printk_deferred() only puts massages into the log
>      buffer. It does not call
>      console_trylock()/console_unlock(). Therefore,
>      it is always "fast".

a small addition,

as a side effect, printk_deferred()  guarantees  that we will
attempt to console_unlock() from IRQ. CPU's pending bit stays
set until we run the irq work list on that CPU, per-CPU irq
work stays queued in per-CPU irq work list.

so, yes, printk_deferred() adds messages to logbuf, but in
exchange it says:
    "I promise I will try to do console_unlock() from IRQ".

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
