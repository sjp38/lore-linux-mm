Message-ID: <45E064FF.8010000@trash.net>
Date: Sat, 24 Feb 2007 17:17:03 +0100
From: Patrick McHardy <kaber@trash.net>
MIME-Version: 1.0
Subject: Re: [PATCH 18/29] netfilter: notify about NF_QUEUE vs emergency	skbs
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>	 <20070221144843.299254000@taijtu.programming.kicks-ass.net>	 <45E05954.8050204@trash.net> <1172332010.28579.6.camel@lappy>
In-Reply-To: <1172332010.28579.6.camel@lappy>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Sat, 2007-02-24 at 16:27 +0100, Patrick McHardy wrote:
> 
>>> 	} else if ((verdict & NF_VERDICT_MASK)  == NF_QUEUE) {
>>>+		if (unlikely((*pskb)->emergency)) {
>>>+			printk(KERN_ERR "nf_hook: NF_QUEUE encountered for "
>>>+					"emergency skb - skipping rule.\n");
>>>+			goto next_hook;
>>>+		}
>>
>>If I'm not mistaken any skb on the receive side might get
>>allocated from the reserve. I don't see how the user could
>>avoid this except by not using queueing at all.
> 
> 
> Well, the rules could be setup so that the storage path will never hit
> the queue.


Sure, but other packets might still get allocated from the
reserve and trigger this.

>>I think the user should just exclude packets necessary for
>>swapping from queueing manually, based on IP addresses,
>>port numbers or something like that.
> 
> 
> Indeed, this patch will just warn the user that he did something very
> wrong and should avoid this situation.
> 
> Perhaps skipping is not the proper action, but dropping them will most
> certainly freeze the box. Either way seems unlucky. Might as well stick
> BUG() in there :-(.


At this point we don't know whether the packet is destined for
a SOCK_VMIO socket or not. The only thing we know is that is
was allocated from the reserve, but it could be anything.
There is really nothing you can do at this point.

> Any ideas on how to resolve this are most welcome, detecting the
> situation on either rule insert or swapon and failing the respective
> action would be most ideal, but I have no idea if that is feasible.


Unfortunately this is not possible either. I don't really see why
queueing is special though, dropping the packets in the ruleset
will break things just as well, as will routing them to a blackhole.
I guess the user just needs to be smart enough not to do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
