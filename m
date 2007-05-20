Date: Sun, 20 May 2007 22:38:08 +0200 (MEST)
From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
In-Reply-To: <20070520161159.GD22452@vanheusden.com>
Message-ID: <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr>
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com>
 <Pine.LNX.4.61.0705180825280.3231@yvahk01.tjqt.qr> <200705181347.14256.ak@suse.de>
 <Pine.LNX.4.61.0705190946430.9015@yvahk01.tjqt.qr> <20070520001418.GJ14578@vanheusden.com>
 <464FC6AA.2060805@cosmosbay.com> <20070520112111.GN14578@vanheusden.com>
 <20070520090809.4f42d71d@freepuppy> <20070520161159.GD22452@vanheusden.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Andi Kleen <ak@suse.de>, Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 20 2007 18:12, Folkert van Heusden wrote:
>> >  
>> > +	if (unlikely(sig == SIGQUIT || sig == SIGILL  || sig == SIGTRAP ||
>> > +	    sig == SIGABRT || sig == SIGBUS  || sig == SIGFPE  ||
>> > +	    sig == SIGSEGV || sig == SIGXCPU || sig == SIGXFSZ ||
>> > +	    sig == SIGSYS  || sig == SIGSTKFLT))
>> > +	{
>> > +		printk(KERN_WARNING "Sig %d send to %d owned by %d.%d (%s)\n",
>> > +			sig, t->pid, t->uid, t->gid, t->comm);
>> > +	}
>> > +
>> >  	/*
>> >  	 * fast-pathed signals for kernel-internal things like SIGSTOP
>> >  	 * or SIGKILL.
>> 
>> Would turning that into a switch() generate better code.

Yes, this time.

>Doubt it: in the worst case you still nee to check for each possibility.
>Furthermore a.f.a.i.k. with switch you cannot do 'unlinkely()'.

With if(), it generates a ton of "CMP, JE" instructions.
With switch(), I would assume gcc transforms it into using
a jump table (aka "JMP [table+sig]")

I tried it: with switch(), gcc transforms this into a
bitmap comparison ("MOV eax, 1; SHL eax, sig; TEST eax, 0x830109f8"),
which seems even cheaper than a jump table.


	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
