Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 26C276B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 05:34:06 -0400 (EDT)
Subject: Re: kmemleak: Early log buffer exceeded
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090623212648.GA9502@localdomain.by>
References: <20090623212648.GA9502@localdomain.by>
Content-Type: text/plain
Date: Wed, 24 Jun 2009 10:35:05 +0100
Message-Id: <1245836105.16283.13.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-23 at 22:26 +0100, Sergey Senozhatsky wrote:
> I can see on my both machines
> 
> [    0.000135] kmemleak: Early log buffer exceeded
[...]
> mm/kmemleak.c
> static struct early_log early_log[200];
> 
> static void log_early(int op_type, const void *ptr, size_t size,
>                       int min_count, unsigned long offset, size_t length)
> {
> ...
>         if (crt_early_log >= ARRAY_SIZE(early_log)) {
>                 print  Early log buffer exceeded;
>                 call dump_stack, etc.
> 
> So, my questions are:
> 1. Is 200 really enough? Why 200 not 512, 1024 (for example)?

It seems that in your case it isn't. It is fine on the machines I tested
it on but choosing this figure wasn't too scientific.

I initially had it bigger and marked with the __init attribute to free
it after initialisation but this was causing (harmless) section mismatch
warnings.

What kind of hardware do you have?

> 2. When (crt_early_log >= ARRAY_SIZE(early_log)) == 1 we just can see stack.
> Since we have "full" early_log maybe it'll be helpfull to see it?

I recall allocating this dynamically didn't work properly but I'll give
it another try. Otherwise, I can make it configurable and print a better
message (probably without the stack dump).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
