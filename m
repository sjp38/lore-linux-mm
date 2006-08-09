Date: Wed, 9 Aug 2006 15:19:42 +0200
From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Message-ID: <20060809131942.GY14627@postel.suug.ch>
References: <20060808193345.1396.16773.sendpatchset@lappy> <20060808211731.GR14627@postel.suug.ch> <44D93BB3.5070507@google.com> <20060808.183920.41636471.davem@davemloft.net> <44D976E6.5010106@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44D976E6.5010106@google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@google.com>
Cc: David Miller <davem@davemloft.net>, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Daniel Phillips <phillips@google.com> 2006-08-08 22:47
> David Miller wrote:
> >From: Daniel Phillips <phillips@google.com>
>  >>Can you please characterize the conditions under which skb->dev changes
> >>after the alloc?  Are there writings on this subtlety?
> >
> >The packet scheduler and classifier can redirect packets to different
> >devices, and can the netfilter layer.
> >
> >The setting of skb->dev is wholly transient and you cannot rely upon
> >it to be the same as when you set it on allocation.
> >
> >Even simple things like the bonding device change skb->dev on every
> >receive.
> 
> Thankyou, this is easily fixed.

It's not that simple, in order to just fix the most obvious case
being packet forwarding when skb->dev changes its meaning from
device the packet is coming from to device the packet will be leaving
on is difficult.

You can't unreserve at that point so you need to keep the original
skb->dev. Since the packet is mostly likely queued before freeing
you will lose the refcnt on the original skb->dev. Keeping a
refcnt just for this memalloc stuff is out of question. Even keeping
the ifindex on a best effort basis is unlikely an option, sk_buff is
way overweight already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
