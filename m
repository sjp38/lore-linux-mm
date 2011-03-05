Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 842058D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 00:48:12 -0500 (EST)
Received: from rcsinet10.oracle.com (rcsinet10.oracle.com [148.87.113.121])
	by rcsinet14.oracle.com (Sentrion-MP-4.0.0/Sentrion-MP-4.0.0) with ESMTP id p255m8YK027573
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 5 Mar 2011 05:48:09 GMT
Message-ID: <4D71CE24.1090302@kernel.org>
Date: Fri, 04 Mar 2011 21:46:12 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC] memblock; Properly handle overlaps
References: <1299297946.8833.931.camel@pasglop>
In-Reply-To: <1299297946.8833.931.camel@pasglop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>

On 03/04/2011 08:05 PM, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> This is not fully tested yet (I'm toying with a little userspace
> test bench, it seems to work well so far but I haven't yet tested
> the cases with no-coalesce boundaries which at least ARM needs).
> 
> But it's good enough to get comments...
> 
> So currently, things like memblock_reserve() or memblock_free()
> don't deal well -at-all- with overlaps of all kinds. Some specific
> cases are handled but the code is clumsy and things will fall over
> in many cases.
> 
> This is annoying because typically memblock_reserve() is used to
> mark regions passed by the firmware as reserved and we all know
> how much we can trust our firmwares right ?
> 
> I have also a case I need to deal with on powerpc where the flat
> device-tree is fully enclosed within some other FW blob that has
> its own reserve map entry, so when I end up trying to reserve
> both, the current memblock code pukes.

did you try remove and add tricks?

diff --git a/mm/memblock.c b/mm/memblock.c
index 4618fda..ba4ffdc 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -453,6 +453,9 @@ long __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 
        BUG_ON(0 == size);
 
+       while (__memblock_remove(_rgn, base, size) >= 0)
+               ;
+
        return memblock_add_region(_rgn, base, size);
 }
 

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
