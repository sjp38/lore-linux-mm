Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44C19280253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 06:41:11 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q128so179831199qkd.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:41:11 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id b83si3027426qkc.203.2016.11.10.03.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Nov 2016 03:41:09 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id b4136987
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 11:39:02 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id da43a2b4 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 11:39:01 +0000 (UTC)
Received: by mail-lf0-f45.google.com with SMTP id t196so187779255lff.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:41:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1611100959040.3501@nanos>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
 <alpine.DEB.2.20.1611092227200.3501@nanos> <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com>
 <alpine.DEB.2.20.1611100959040.3501@nanos>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 10 Nov 2016 12:41:04 +0100
Message-ID: <CAHmME9pHYA82M3iDNfDtDE96gFaZORSsEAn_KnePd3rhFioqHQ@mail.gmail.com>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

On Thu, Nov 10, 2016 at 10:03 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> If you want to go with that config, then you need
> local_bh_disable()/enable() to fend softirqs off, which disables also
> preemption.

Thanks. Indeed this is what I want.

>
>> What clever tricks do I have at my disposal, then?
>
> Make MIPS use interrupt stacks.

Yea, maybe I'll just implement this. It clearly is the most correct solution.
@MIPS maintainers: would you merge something like this if done well?
Are there reasons other than man-power why it isn't currently that
way?

> Does the slowdown come from the kmalloc overhead or mostly from the less
> efficient code?
>
> If it's mainly kmalloc, then you can preallocate the buffer once for the
> kthread you're running in and be done with it. If it's the code, then bad
> luck.

I fear both. GCC can optimize stack variables in ways that it cannot
optimize various memory reads and writes.

Strangely, the solution that appeals to me most at the moment is to
kmalloc (or vmalloc?) a new stack, copy over thread_info, and fiddle
with the stack registers. I don't see any APIs, however, for a
platform independent way of doing this. And maybe this is a horrible
idea. But at least it'd allow me to keep my stack-based code the
same...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
