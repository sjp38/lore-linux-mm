Date: Sat, 28 Jan 2006 09:16:42 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
Message-ID: <20060128081641.GB1605@elf.ucw.cz>
References: <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com> <43D953C4.5020205@us.ibm.com> <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com> <43D95A2E.4020002@us.ibm.com> <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com> <43D96633.4080900@us.ibm.com> <Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com> <43D96A93.9000600@us.ibm.com> <20060127025126.c95f8002.pj@sgi.com> <43DAC222.4060805@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43DAC222.4060805@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Paul Jackson <pj@sgi.com>, clameter@engr.sgi.com, linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

I'll probably regret getting into this discussion, but:

> > Or Alan's suggested revival
> > of the old code to drop non-critical network patches in duress.
> 
> Dropping non-critical packets is still in our plan, but I don't think that
> is a FULL solution.  As we mentioned before on that topic, you can't tell
> if a packet is critical until AFTER you receive it, by which point it has
> already had an skbuff (hopefully) allocated for it.  If your network
> traffic is coming in faster than you can receive, examine, and drop
> non-critical packets you're hosed.  

Why? You run out of atomic memory, start dropping the packets before
they even enter the kernel memory, and process backlog in the
meantime. Other hosts realize you are dropping packets and slow down,
or, if they are malicious, you just end up consistently dropping 70%
of packets. But that's okay.

> I still think some sort of reserve pool
> is necessary to give the networking stack a little breathing room when
> under both memory pressure and network load.

"Lets throw some memory there and hope it does some good?" Eek? What
about auditing/fixing the networking stack, instead?

> >  * this doesn't really solve the problem (network can still starve)
> 
> Only if the pool is not large enough.  One can argue that sizing the pool
> appropriately is impossible (theoretical incoming traffic over a GigE card
> or two for a minute or two is extremely large), but then I guess we
> shouldn't even try to fix the problem...?

And what problem are you trying to fix, anyway? Last time I asked I
got reply around some strange clustering solution that absolutely has
to survive two minutes. And no, your patches do not even solve that,
because sizing the pool is impossible. 
								Pavel
-- 
Thanks, Sharp!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
