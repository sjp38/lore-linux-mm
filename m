Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3830280282
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 05:03:19 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id i12so4745159plk.5
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 02:03:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q74sor115882pfd.135.2018.01.06.02.03.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jan 2018 02:03:19 -0800 (PST)
Date: Sat, 6 Jan 2018 19:03:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm: ratelimit end_swap_bio_write() error
Message-ID: <20180106100313.GA527@tigerII.localdomain>
References: <20180106043407.25193-1-sergey.senozhatsky@gmail.com>
 <20180106094124.GB16576@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180106094124.GB16576@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On (01/06/18 10:41), Michal Hocko wrote:
> On Sat 06-01-18 13:34:07, Sergey Senozhatsky wrote:
> > Use the ratelimited printk() version for swap-device write error
> > reporting. We can use ZRAM as a swap-device, and the tricky part
> > here is that zsmalloc() stores compressed objects in memory, thus
> > it has to allocates pages during swap-out. If the system is short
> > on memory, then we begin to flood printk() log buffer with the
> > same "Write-error on swap-device XXX" error messages and sometimes
> > simply lockup the system.
> 
> Should we print an error in such a situation at all? Write-error
> certainly sounds scare and it suggests something went really wrong.
> My understading is that zram failed swap-out is not critical and
> therefore the error message is not really useful.

I don't mind to get rid of it. up to you :)

> Or what should an admin do when seeing it?

zsmalloc allocation is just one possibility; an error in
compressing algorithm is another one, yet is rather unlikely.
most likely it's OOM which can cause problems. but in any case
it's sort of unclear what should be done. an error can be a
temporary one or a fatal one, just like in __swap_writepage()
case. so may be both write error printk()-s can be dropped.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
