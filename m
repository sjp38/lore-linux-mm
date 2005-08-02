From: Daniel Phillips <phillips@istop.com>
Subject: Re: Network vm deadlock... solution?
Date: Wed, 3 Aug 2005 09:04:27 +1000
References: <200508020654.32693.phillips@istop.com> <200508030613.37359.phillips@istop.com> <20050802214340.GA6309@electric-eye.fr.zoreil.com>
In-Reply-To: <20050802214340.GA6309@electric-eye.fr.zoreil.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508030904.27711.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 03 August 2005 07:43, Francois Romieu wrote:
> Daniel Phillips <phillips@istop.com> :
> [...]
>
> > A point on memory pressure: here, we are not talking about the continuous
> > state of running under heavy load, but rather the microscopically short
> > periods where not a single page of memory is available to normal tasks. 
> > It is when a block IO event happens to land inside one of those
> > microscopically short periods that we run into problems.
>
> You suggested in a previous message to use an emergency allocation pool at
> the driver level. Afaik, 1) the usual network driver can already buffer a
> bit with its Rx descriptor ring and 2) it more or less tries to refill it
> each time napi issues its ->poll() method. So it makes me wonder:
> - have you collected evidence that the drivers actually run out of memory
>   in the (microscopical) situation you describe ?

Yes, e.g:

   http://thunker.thunk.org/pipermail/ksummit-2005-discuss/2005-March/000200.html

and NBD is known to be unreliable for this reason.  I plan to put together
a before-and-after test that everybody can try, but after I show the patch for
comment.

> - instead of modifying each and every driver to be vm aware, why don't
>   you hook in net_rx_action() when memory starts to be low ?

Two reasons:

  * The first handling has to be where the packet is allocated

  * net_rx_action is on the far side of a queue, which would need to be
    throttled separately.  But the throttle would not know which packets to
    discard, because the packet headers have not been examined yet.

> Btw I do not get what the mempool/GFP_CRITICAL idea buys: it seems
> redundant with the threshold ("if (memory_pressure)") used in the Rx path
> to decide that memory is low.

It is not to decide if memory is low, but to tell the vm system that it is
allowed to allocate from the reserve if normal memory is exhausted.

Regards,

Daniel.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
