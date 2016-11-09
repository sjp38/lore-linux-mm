Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 400C16B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 18:35:01 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id n6so113540961qtd.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 15:35:01 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id f22si1363865qkh.118.2016.11.09.15.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Nov 2016 15:34:59 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 8ec5ce05
	for <linux-mm@kvack.org>;
	Wed, 9 Nov 2016 23:32:56 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 923c2545 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Wed, 9 Nov 2016 23:32:55 +0000 (UTC)
Received: by mail-lf0-f44.google.com with SMTP id t196so177109846lff.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 15:34:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1611092227200.3501@nanos>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
 <alpine.DEB.2.20.1611092227200.3501@nanos>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 10 Nov 2016 00:34:54 +0100
Message-ID: <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

Hey Thomas,

On Wed, Nov 9, 2016 at 10:40 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> That preempt_disable() prevents merily preemption as the name says, but it
> wont prevent softirq handlers from running on return from interrupt. So
> what's the point?

Oh, interesting. Okay, then in that case the proposed define wouldn't
be useful for my purposes. What clever tricks do I have at my
disposal, then?

>> If not, do you have a better solution for me (which doesn't
>> involve using kmalloc or choosing a different crypto primitive)?
>
> What's wrong with using kmalloc?

It's cumbersome and potentially slow. This is crypto code, where speed
matters a lot. Avoiding allocations is usually the lowest hanging
fruit among optimizations. To give you some idea, here's a somewhat
horrible solution using kmalloc I hacked together: [1]. I'm not to
happy with what it looks like, code-wise, and there's around a 16%
slowdown, which isn't nice either.

[1] https://git.zx2c4.com/WireGuard/commit/?h=jd/curve25519-kmalloc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
