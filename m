Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060812104224.GA12353@2ka.mipt.ru>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	 <20060809054648.GD17446@2ka.mipt.ru> <1155127040.12225.25.camel@twins>
	 <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins>
	 <44DD4E3A.4040000@redhat.com> <20060812084713.GA29523@2ka.mipt.ru>
	 <1155374390.13508.15.camel@lappy> <20060812093706.GA13554@2ka.mipt.ru>
	 <1155377887.13508.27.camel@lappy>  <20060812104224.GA12353@2ka.mipt.ru>
Content-Type: text/plain
Date: Sat, 12 Aug 2006 13:40:29 +0200
Message-Id: <1155382830.13508.38.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2006-08-12 at 14:42 +0400, Evgeniy Polyakov wrote:

> When network uses the same allocator, it depends on it, and thus it is
> possible to have (cut by you) a situation when reserve (which depends on
> SLAB and it's OOM too) is not filled or even does not exist.

No, the reserve does not depend on SLAB, and I totally short-circuit the
SLAB allocator for skbs and related on memory pressure.

The memalloc reserve is on the page allocator level and is only
accessable for PF_MEMALLOC processes or __GFP_MEMALLOC (new in my
patches) allocations. (arguably there could be some more deadlocks wrt.
PF_MEMALLOC where the code under PF_MEMALLOC is not properly bounded,
those would be bugs and should be fixed if present/found)

> If transferred to your implementation, then just steal some pages from
> SLAB when new network device is added and use them when OOM happens.
> It is much simpler and can help in the most of situations.

SLAB reclaim is painfull and has been tried by the time you OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
