Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18855
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 18:49:44 -0400
Date: Wed, 7 Apr 1999 00:49:18 +0200 (CEST)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <199904062240.PAA12189@piglet.twiddle.net>
Message-ID: <Pine.LNX.3.96.990407004419.11327A-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@twiddle.net>
Cc: sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, David Miller wrote:

>    #define log2(x) \
> 
> Look at the code just the 'i' in question will output :-)
> 
>      mov    inode, %o0
>      srlx   %o0, 3, %o4
> 
> So on sparc64 atleast, it amounts to "inode >> 3".  So:

(yep it's the same on x86 too, given sizeof(struct inode) == 0x110) 

> (sizeof(struct inode) & ~ (sizeof(struct inode) - 1))
> 
> is 8 on sparc64.  The 'i' construct is just meant to get rid of the
> "non significant" lower bits of the inode pointer and it does so very
> nicely. :-)

but it's not just the lower 3 bits that are unsignificant. It's 8
unsignificant bits. (8.1 actually :) It should be 'inode >> 8' (which is
done by the log2 solution). Unless i'm misunderstanding something. The
thing we are AFAIU trying to avoid is 'x/sizeof(inode)', which can be a
costy division. So i've substituted it with
'x/nearest_power_of_2(sizeof(inode))' which is just as good in getting rid
of insignificant bits. 

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
