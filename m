Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8868D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:42:53 -0500 (EST)
Message-ID: <4D77E5E0.6010706@kernel.org>
Date: Wed, 09 Mar 2011 12:41:04 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH/v2] mm/memblock: Properly handle overlaps and fix error
 path
References: <1299466980.8833.973.camel@pasglop>
In-Reply-To: <1299466980.8833.973.camel@pasglop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, David Miller <davem@davemloft.net>

On 03/06/2011 07:03 PM, Benjamin Herrenschmidt wrote:
> Currently memblock_reserve() or memblock_free() don't handle overlaps
> of any kind. There is some special casing for coalescing exactly
> adjacent regions but that's about it.
> 
> This is annoying because typically memblock_reserve() is used to
> mark regions passed by the firmware as reserved and we all know
> how much we can trust our firmwares...
> 
> Also, with the current code, if we do something it doesn't handle
> right such as trying to memblock_reserve() a large range spanning
> multiple existing smaller reserved regions for example, or doing
> overlapping reservations, it can silently corrupt the internal
> region array, causing odd errors much later on, such as allocations
> returning reserved regions etc...
> 
> This patch rewrites the underlying functions that add or remove a
> region to the arrays. The new code is a lot more robust as it fully
> handles overlapping regions. It's also, imho, simpler than the previous
> implementation.
> 
> In addition, while doing so, I found a bug where if we fail to double
> the array while adding a region, we would remove the last region of
> the array rather than the region we just allocated. This fixes it too.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> Hopefully not damaged with a spurious bit of email header this
> time around... sorry about that.

works on my setups...

[    0.000000] Subtract (26 early reservations)
[    0.000000]   [000009a000-000009efff]
[    0.000000]   [000009f400-00000fffff]
[    0.000000]   [0001000000-0003495048]
...
before:
[    0.000000] Subtract (27 early reservations)
[    0.000000]   [000009a000-000009efff]
[    0.000000]   [000009f400-00000fffff]
[    0.000000]   [00000f85b0-00000f86b3]
[    0.000000]   [0001000000-0003495048]

Acked-by: Yinghai Lu <yinghai@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
