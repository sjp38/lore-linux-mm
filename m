Date: Mon, 14 Aug 2006 01:33:39 -0700 (PDT)
Message-Id: <20060814.013339.92582432.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060814000736.80e652bb.akpm@osdl.org>
References: <20060813222208.7e8583ac.akpm@osdl.org>
	<1155537940.5696.117.camel@twins>
	<20060814000736.80e652bb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Date: Mon, 14 Aug 2006 00:07:36 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: a.p.zijlstra@chello.nl, phillips@google.com, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, michaelc@cs.wisc.edu
List-ID: <linux-mm.kvack.org>

> What is a "socket wait queue" and how/why can it consume so much memory?
> 
> Can it be prevented from doing that?
>
> If this refers to the socket buffers, they're mostly allocated with
> at least __GFP_WAIT, aren't they?

He's talking about the fact that, once we've tied a receive buffer to
a socket, we can't liberate that memory in any way until the user
reads in the data (which can be whenever it likes) especially if we've
ACK'd the data for protocols such as TCP.

Receive buffers are allocated by the device, usually in interrupt of
software interrupt context, to refill it's RX ring using GFP_ATOMIC or
similar.

Send buffers are usually allocated with GFP_KERNEL, but that can be
modified via the sk->sk_allocation socket member.  This is used by
things like sunrpc and other cases which need to allocate socket
buffers with GFP_ATOMIC or with GFP_NOFS for NFS's sake.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
