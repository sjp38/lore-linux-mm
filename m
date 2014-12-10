Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2AAB56B0075
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:40:40 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id f51so2157767qge.32
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:40:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d1si5159723qaa.28.2014.12.10.06.40.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Dec 2014 06:40:39 -0800 (PST)
Date: Wed, 10 Dec 2014 15:40:19 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
 (backed by alf_queue)
Message-ID: <20141210154019.598da6d8@redhat.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA0A193@AcuExch.aculab.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
	<20141210141332.31779.56391.stgit@dragon>
	<063D6719AE5E284EB5DD2968C1650D6D1CA0A193@AcuExch.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: brouer@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Alexander Duyck <alexander.duyck@gmail.com>, Alexei Starovoitov <ast@plumgrid.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, 10 Dec 2014 14:22:22 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Jesper Dangaard Brouer
> > The network stack have some use-cases that puts some extreme demands
> > on the memory allocator.  One use-case, 10Gbit/s wirespeed at smallest
> > packet size[1], requires handling a packet every 67.2 ns (nanosec).
> > 
> > Micro benchmarking[2] the SLUB allocator (with skb size 256bytes
> > elements), show "fast-path" instant reuse only costs 19 ns, but a
> > closer to network usage pattern show the cost rise to 45 ns.
> > 
> > This patchset introduce a quick mempool (qmempool), which when used
> > in-front of the SKB (sk_buff) kmem_cache, saves 12 ns on "fast-path"
> > drop in iptables "raw" table, but more importantly saves 40 ns with
> > IP-forwarding, which were hitting the slower SLUB use-case.
> > 
> > 
> > One of the building blocks for achieving this speedup is a cmpxchg
> > based Lock-Free queue that supports bulking, named alf_queue for
> > Array-based Lock-Free queue.  By bulking elements (pointers) from the
> > queue, the cost of the cmpxchg (approx 8 ns) is amortized over several
> > elements.
> 
> It seems to me that these improvements could be added to the
> underlying allocator itself.
> Nesting allocators doesn't really seem right to me.

Yes, I would very much like to see these ideas integrated into the
underlying allocators (hence addressing the mm-list).

This patchset demonstrates that it is possible to do something faster
than the existing SLUB allocator.  Which the network stack have a need
for.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
