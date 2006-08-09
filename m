Date: Wed, 9 Aug 2006 18:18:16 +0200
From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Message-ID: <20060809161816.GA14627@postel.suug.ch>
References: <20060808193345.1396.16773.sendpatchset@lappy> <20060808211731.GR14627@postel.suug.ch> <44D93BB3.5070507@google.com> <20060808.183920.41636471.davem@davemloft.net> <44D976E6.5010106@google.com> <20060809131942.GY14627@postel.suug.ch> <1155132440.12225.70.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1155132440.12225.70.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Daniel Phillips <phillips@google.com>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <a.p.zijlstra@chello.nl> 2006-08-09 16:07
> I think Daniel was thinking of adding struct net_device *
> sk_buff::alloc_dev,
> I know I was after reading the first few mails. However if adding a
> field 
> there is strict no-no....
> 
> /me takes a look at struct sk_buff
> 
> Hmm, what does sk_buff::input_dev do? That seems to store the initial
> device?

No, skb->input_dev is used when redirecting packets around in the
stack and may change. Even if it would keep its value the reference
to the netdevice is not valid anymore when you free the skb as the
skb was queued and the refcnt acquired in __netifx_rx_schedule()
has been released again thus making it possible for the netdevice
to disappear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
