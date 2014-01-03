Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CB0D66B0036
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 17:18:19 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so14506909pab.33
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 14:18:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id dv5si47012667pbb.73.2014.01.03.14.18.18
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 14:18:18 -0800 (PST)
Date: Fri, 3 Jan 2014 14:18:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
Message-Id: <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org>
In-Reply-To: <20140103180147.6566F7C1@viggo.jf.intel.com>
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, penberg@kernel.org, cl@linux-foundation.org

On Fri, 03 Jan 2014 10:01:47 -0800 Dave Hansen <dave@sr71.net> wrote:

> This is a minor update from the last version.  The most notable
> thing is that I was able to demonstrate that maintaining the
> cmpxchg16 optimization has _some_ value.
> 
> Otherwise, the code changes are just a few minor cleanups.
> 
> ---
> 
> SLUB depends on a 16-byte cmpxchg for an optimization which
> allows it to not disable interrupts in its fast path.  This
> optimization has some small but measurable benefits:
> 
> 	http://lkml.kernel.org/r/52B345A3.6090700@sr71.net

So really the only significant benefit from the cmpxchg16 is with
cache-cold eight-byte kmalloc/kfree?  8% faster in this case?  But with
cache-hot kmalloc/kfree the benefit of cmpxchg16 is precisely zero.

This is really weird and makes me suspect a measurement glitch.

Even if this 8% is real, it's unclear that it's worth all the
complexity the cmpxchg16 adds.

It would be really useful (hint :)) if we were to know exactly where
that 8% is coming from - perhaps it's something which is not directly
related to the cmpxchg16, and we can fix it separately.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
