From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001061836.KAA95195@google.engr.sgi.com>
Subject: Re: [RFC] [RFT] [PATCH] memory zone balancing
Date: Thu, 6 Jan 2000 10:36:03 -0800 (PST)
In-Reply-To: <200001061528.HAA05974@pizda.ninka.net> from "David S. Miller" at Jan 06, 2000 07:28:19 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: mingo@chiara.csoma.elte.hu, andrea@suse.de, torvalds@transmeta.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
>    Date:   Thu, 6 Jan 2000 17:05:41 +0100 (CET)
>    From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
> 
>    i think this is pretty much 'type-dependent'. In earlier versions
>    of the zone allocator i added a zone->memory_balanced() function
>    (but removed it later because it first needed the things your patch
>    adds). Then every zone can decide for itself wether it's
>    balanced. Eg. the DMA zone is rather critical and we want to keep
>    it free aggressively (part of that is already achieved by placing
>    it at the end of the zone chain), the highmem zone might not need
>    any balancing at all, the normal zone wants some high/low watermark
>    stuff.

After thinking about this more, I came to the conclusion that the
ZONE_BALANCED macro is just a quick way of checking whether we are
_really_ unbalanced. If so, then we need to see if we are really 
unbalanced, and do appropriate freeing. To determine whether a zone 
is _really_ unbalanced, I need to look at the number of free pages 
in the lower order zones too, then compare against the zone's water
marks. Ie, the "balancing" is not just about the absolute number of
free pages in the zone, but rather in the class that the zone 
represents.

I am waiting to see if Linus takes in my previous patch, before 
puting too much work into the balancing heuristics.

> 
> Let's be careful not to design any balancing heuristics which will
> fall apart on architectures where only one zone ever exists (because
> GFP_DMA is completely meaningless).

Yes, with all different types of machines out there, we need to be 
able to provide enough hooks to the arch code to tune the watermarks and
balancing frequency. Luckily, the zone structure is exposed via the
pg_data_t, so this should be no problem. Some sysctls are probably also 
called for.

Kanoj
> 
> Later,
> David S. Miller
> davem@redhat.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
