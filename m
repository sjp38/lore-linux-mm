Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060809131942.GY14627@postel.suug.ch>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	 <20060808211731.GR14627@postel.suug.ch> <44D93BB3.5070507@google.com>
	 <20060808.183920.41636471.davem@davemloft.net>
	 <44D976E6.5010106@google.com>  <20060809131942.GY14627@postel.suug.ch>
Content-Type: text/plain
Date: Wed, 09 Aug 2006 16:07:20 +0200
Message-Id: <1155132440.12225.70.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Graf <tgraf@suug.ch>
Cc: Daniel Phillips <phillips@google.com>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-09 at 15:19 +0200, Thomas Graf wrote:
> * Daniel Phillips <phillips@google.com> 2006-08-08 22:47
> > David Miller wrote:
> > >From: Daniel Phillips <phillips@google.com>
> >  >>Can you please characterize the conditions under which skb->dev changes
> > >>after the alloc?  Are there writings on this subtlety?
> > >
> > >The packet scheduler and classifier can redirect packets to different
> > >devices, and can the netfilter layer.
> > >
> > >The setting of skb->dev is wholly transient and you cannot rely upon
> > >it to be the same as when you set it on allocation.
> > >
> > >Even simple things like the bonding device change skb->dev on every
> > >receive.
> > 
> > Thankyou, this is easily fixed.
> 
> It's not that simple, in order to just fix the most obvious case
> being packet forwarding when skb->dev changes its meaning from
> device the packet is coming from to device the packet will be leaving
> on is difficult.
> 
> You can't unreserve at that point so you need to keep the original
> skb->dev. Since the packet is mostly likely queued before freeing
> you will lose the refcnt on the original skb->dev. Keeping a
> refcnt just for this memalloc stuff is out of question. Even keeping
> the ifindex on a best effort basis is unlikely an option, sk_buff is
> way overweight already.

I think Daniel was thinking of adding struct net_device *
sk_buff::alloc_dev,
I know I was after reading the first few mails. However if adding a
field 
there is strict no-no....

/me takes a look at struct sk_buff

Hmm, what does sk_buff::input_dev do? That seems to store the initial
device?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
