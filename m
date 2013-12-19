Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AD54B6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 14:14:50 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so1492885pdj.36
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:14:50 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id gx4si3312899pbc.81.2013.12.19.11.14.47
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 11:14:48 -0800 (PST)
Message-ID: <52B345A3.6090700@sr71.net>
Date: Thu, 19 Dec 2013 11:14:43 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
References: <20131213235903.8236C539@viggo.jf.intel.com>	<20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org>	<52AF9EB9.7080606@sr71.net>	<0000014301223b3e-a73f3d59-8234-48f1-9888-9af32709a879-000000@email.amazonses.com>	<52B23CAF.809@sr71.net> <20131218164109.5e169e258378fac44ec5212d@linux-foundation.org>
In-Reply-To: <20131218164109.5e169e258378fac44ec5212d@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Pekka Enberg <penberg@kernel.org>

On 12/18/2013 04:41 PM, Andrew Morton wrote:
> So your scary patch series which shrinks struct page while retaining
> the cmpxchg_double() might reclaim most of this loss?

Well, this is cool.  Except for 1 case out of 14 (1024 bytes with the
alloc all / free all loops), my patched kernel either outperforms or
matches both of the existing cases.

To recap, we have two workloads, essentially the time to free an "old"
kmalloc which is not cache-warm (mode=0) and the time to free one which
is warm since it was just allocated (mode=1).

This is tried for 3 different kernel configurations:
1. The default today, SLUB with a 64-byte 'struct page' using cmpxchg16
2. Same kernel source as (1), but with SLUB's compile-time options
   changed to disable CMPXCHG16 and not align 'struct page'
3. Patched kernel to internally align th SLUB data so that we can both
   have an unaligned 56-byte 'struct page' and use the CMPXCHG16
   optimization.

> https://docs.google.com/spreadsheet/ccc?key=0AgUCVXtr5IwedDNXb1FLNEFqVHdSNDF6YktYZTBndEE&usp=sharing

I'll respin the patches a bit and send out another version with some
small updates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
