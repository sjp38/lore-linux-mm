Date: Sat, 12 Aug 2006 18:49:22 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Message-ID: <20060812144921.GA25058@2ka.mipt.ru>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060809054648.GD17446@2ka.mipt.ru> <1155127040.12225.25.camel@twins> <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins> <44DD4E3A.4040000@redhat.com> <20060812084713.GA29523@2ka.mipt.ru> <1155374390.13508.15.camel@lappy> <20060812093706.GA13554@2ka.mipt.ru> <44DDE857.3080703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <44DDE857.3080703@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 12, 2006 at 10:40:23AM -0400, Rik van Riel (riel@redhat.com) wrote:
> Evgeniy Polyakov wrote:
> >On Sat, Aug 12, 2006 at 11:19:49AM +0200, Peter Zijlstra 
> >(a.p.zijlstra@chello.nl) wrote:
> >>>As you described above, memory for each packet must be allocated (either
> >>>from SLAB or from reserve), so network needs special allocator in OOM
> >>>condition, and that allocator should be separated from SLAB's one which 
> >>>got OOM, so my purpose is just to use that different allocator (with
> >>>additional features) for netroking always.
> >
> >No it is not. There are socket queues and they are limited. Things like
> >TCP behave even better.
> 
> Ahhh, but there are two allocators in play here.
> 
> The first one allocates the memory for receiving packets.
> This can be one pool, as long as it is isolated from
> other things in the system it is fine.
> 
> The second allocator allocates more memory for socket
> buffers.  The memory critical sockets should get their
> memory from a mempool, once normal socket memory
> allocations start failing.
> 
> This means our allocation differentiation only needs
> to happen at the socket stage.
> 
> Or am I overlooking something?

Yep. Socket allocations end up with alloc_skb() which is essentialy the
same as what is being done for receiving path skbs.
If you really want to separate critical from non-critical sockets, it is
much better not to play with alloc_skb() but directly forbid it in
appropriate socket allocation function like sock_alloc_send_skb().

What I suggested in previous e-mail is to separate networking
allocations from other system allocations, so problem in main allocator
and it's OOM would never affect network path.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
