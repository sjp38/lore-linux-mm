From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [uml-user] forkbomb into guest
Date: Mon, 14 May 2007 23:11:33 +0200
References: <4638.24.132.252.172.1178704676.squirrel@webmail.freaknet.org> <20070512085251.GB12571@c2.user-mode-linux.org> <20070512112809.GA13956@c2.user-mode-linux.org>
In-Reply-To: <20070512112809.GA13956@c2.user-mode-linux.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705142311.33936.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>, linux-mm@kvack.org
Cc: user-mode-linux-user@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On sabato 12 maggio 2007, Jeff Dike wrote:
> On Sat, May 12, 2007 at 04:52:51AM -0400, Jeff Dike wrote:
> > This might be better now with the irqstacks patchset I sent in.  This
> > was prompted by this problem (forks failing when there is free memory
> > - just not enough contiguous to get a kernel stack).
>
> Hmmm, I still get ooms from fork(), even though there appears to be
> enough contiguous memory:
>
> make invoked oom-killer: gfp_mask=0xd0, order=1, oomkilladj=0
> ...
> Normal: 27065*4kB 64*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
> 0*1024kB 0*2048kB 0*4096kB = 108788kB
>
> An order-1 allocation is failing even though there are 64 order-1
> groups available.
What's more, gfp_mask is __GFP_WAIT | __GFP_IO | __GFP_FS, i.e. GFP_KERNEL. 
This should be discussed with VM hackers I'd guess...

I guess you were running a serious stress test, right? If yes, after all that 
may be ok. To sum up what's below, it seems that 64 order-1 groups is below 
the zone->pages_xxx (min, low or high), and that's enough to cause an OOM.

I've given a basic look at the code and there is no obvious explaination. 
However, it seems that if you hit some memory watermark you may get the above 
(you can see their values in /proc/zoneinfo).

Also, there is a strangeness (for me) in zone_watermark_ok. Not only the total 
free memory must be above the chosen watermark, but also the memory available 
excluding lower-order memory must be above the same watermark.

Since you have about 100 M of free RAM and just 64*8+16 = 528 Kb of free ram 
on order 1+, the above situation may cause a failure.

What do you think of a report such as the above? Is my analisys correct?
-- 
Inform me of my mistakes, so I can add them to my list!
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
