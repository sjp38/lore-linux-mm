Message-ID: <45E05954.8050204@trash.net>
Date: Sat, 24 Feb 2007 16:27:16 +0100
From: Patrick McHardy <kaber@trash.net>
MIME-Version: 1.0
Subject: Re: [PATCH 18/29] netfilter: notify about NF_QUEUE vs emergency skbs
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net> <20070221144843.299254000@taijtu.programming.kicks-ass.net>
In-Reply-To: <20070221144843.299254000@taijtu.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Emergency skbs should never touch user-space, however NF_QUEUE is fully user
> configurable. Notify the user of his mistake and try to continue.
>
> --- linux-2.6-git.orig/net/netfilter/core.c	2007-02-14 12:09:07.000000000 +0100
> +++ linux-2.6-git/net/netfilter/core.c	2007-02-14 12:09:18.000000000 +0100
> @@ -187,6 +187,11 @@ next_hook:
>  		kfree_skb(*pskb);
>  		ret = -EPERM;
>  	} else if ((verdict & NF_VERDICT_MASK)  == NF_QUEUE) {
> +		if (unlikely((*pskb)->emergency)) {
> +			printk(KERN_ERR "nf_hook: NF_QUEUE encountered for "
> +					"emergency skb - skipping rule.\n");
> +			goto next_hook;
> +		}

If I'm not mistaken any skb on the receive side might get
allocated from the reserve. I don't see how the user could
avoid this except by not using queueing at all.

I also didn't see a patch dropping packets allocated from
the reserve that are forwarded or processed directly without
getting queued to a socket, so this would allow them to
bypass userspace queueing and still go through.

I think the user should just exclude packets necessary for
swapping from queueing manually, based on IP addresses,
port numbers or something like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
