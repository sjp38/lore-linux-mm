From: Daniel Phillips <phillips@istop.com>
Subject: Re: [RFC] Net vm deadlock fix (take two)
Date: Sun, 7 Aug 2005 03:46:36 +1000
References: <200508061722.24106.phillips@istop.com> <20050806160718.GB17136@havoc.gtf.org>
In-Reply-To: <20050806160718.GB17136@havoc.gtf.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508070346.37453.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 07 August 2005 02:07, Jeff Garzik wrote:
> > +static inline struct sk_buff *__dev_memalloc_skb(struct net_device *dev,
> > +	unsigned length, int gfp_mask)
> > +{
> > +	struct sk_buff *skb = __dev_alloc_skb(length, gfp_mask);
> > +	if (skb)
> > +		goto done;
> > +	if (dev->rx_reserve_used >= dev->rx_reserve)
> > +		return NULL;
> > +	if (!__dev_alloc_skb(length, gfp_mask|__GFP_MEMALLOC))
> > +		return NULL;;
> > +	dev->rx_reserve_used++;
>
> why bother with rx_reserve at all?  Why not just let the second
> allocation fail, without the rx_reserve_used test?

Because that would allow unbounded reserve use, either because of a leak or 
because of a legitimate backup in the softnet queues.  It is not worth it to 
run the risk of wedging the whole system just to save this check.  If we were 
using a mempool here, it would fail with a similar check.

> Additionally, I think the rx_reserve_used accounting is wrong, since I
> could simply free the skb

Good point, I should provide a kfree_skb variant that does the reserve 
accounting (dev_free_skb) in case some driver wants to do this.  Anyway, if 
somebody does free an skb in the delivery path without doing the accounting 
it is not a memory leak, but might cause a non-blockio packet to be 
unnecessarily dropped later.

> -- but doing so would cause a rx_reserve_used 
> leak in your code, since you only decrement the counter in the TCP IPv4
> path.

Reserve checks are needed not just on the IPv4 path but on every protocol path 
that is allowed to co-exist on the same wire as block IO.  I will add udp and 
sctp to the patch next.

If an unhandled protocol does get onto the wire, the consequences are not 
severe.  There is just a risk that the entire reserve may be consumed 
(another reason we need the limit check above) and we just fall back to the 
old unreliable block IO behavior.

Eventually this needs to be enforced automatically so that normal users don't 
have to worry about exactly what protocols they are running on an interface, 
but cluster users will just take care to run only supported protocols, they 
can already benefit from this without fancy checking.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
