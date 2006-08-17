Message-ID: <44E3F036.2060900@google.com>
Date: Wed, 16 Aug 2006 21:27:34 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
References: <20060808211731.GR14627@postel.suug.ch>	<44DBED4C.6040604@redhat.com>	<44DFA225.1020508@google.com>	<20060813.165540.56347790.davem@davemloft.net>	<44DFD262.5060106@google.com>	<20060813185309.928472f9.akpm@osdl.org>	<1155530453.5696.98.camel@twins>	<20060813215853.0ed0e973.akpm@osdl.org>	<1155531835.5696.103.camel@twins>	<20060813222208.7e8583ac.akpm@osdl.org>	<1155537940.5696.117.camel@twins> <20060814000736.80e652bb.akpm@osdl.org>
In-Reply-To: <20060814000736.80e652bb.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> What is a "socket wait queue" and how/why can it consume so much memory?

Two things:

   1) sk_buffs in flight between device receive interrupt and layer 3
      protocol/socket identification.

   2) sk_buffs queued onto a particular socket waiting for some task to
      come along and pull them off via read or equivalent.

Case (1) probably can't consume a unbounded amount of memory, but I
would not swear to that with my current reading knowledge of the network
stack.  The upper bound here is obscured by clever SMP device processing,
netfilter options, softirq scheduling questions, probably other things.
This needs a considered explanation from a network guru, or perhaps a
pointer to documentation.

Case (2) is the elephant under the rug.  Some form of TCP memory
throttling exists, but there is no organized way to correlate that with
actual memory conditions, and it appears to be exposed to user control.
Memory throttling seems to be entirely absent for non-TCP protocols,
e.g., UDP.

> Can it be prevented from doing that?

This patch set does that, and also provides an emergency reserve for
network devices in order to prevent atomic allocation failures while
trying to refill NIC DMA buffer rings.  It is the moral equivalent of
our bio reservation scheme, but with additional twists specific to the
network stack.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
