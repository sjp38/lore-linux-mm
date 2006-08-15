From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Tue, 15 Aug 2006 22:21:22 +0200
References: <20060814110359.GA27704@2ka.mipt.ru>
In-Reply-To: <20060814110359.GA27704@2ka.mipt.ru>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200608152221.22883.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Am Monday 14 August 2006 13:04 schrieb Evgeniy Polyakov:
> ?* full per CPU allocation and freeing (objects are never freed on
> ????????different CPU)

Many of your data structures are per cpu, but your underlying allocations
are all using regular kzalloc/__get_free_page/__get_free_pages functions.
Shouldn't these be converted to calls to kmalloc_node and alloc_pages_node
in order to get better locality on NUMA systems?

OTOH, we have recently experimented with doing the dev_alloc_skb calls
with affinity to the NUMA node that holds the actual network adapter, and
got significant improvements on the Cell blade server. That of course
may be a conflicting goal since it would mean having per-cpu per-node
page pools if any CPU is supposed to be able to allocate pages for use
as DMA buffers on any node.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
