Date: Tue, 8 Aug 2006 13:57:21 -0700
From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Message-ID: <20060808135721.5af713fb@localhost.localdomain>
In-Reply-To: <20060808193345.1396.16773.sendpatchset@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060808193345.1396.16773.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 08 Aug 2006 21:33:45 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> 
> The core of the VM deadlock avoidance framework.
> 
> From the 'user' side of things it provides a function to mark a 'struct sock'
> as SOCK_MEMALLOC, meaning this socket may dip into the memalloc reserves on
> the receive side.
> 
> From the net_device side of things, the extra 'struct net_device *' argument
> to {,__}netdev_alloc_skb() is used to attribute/account the memalloc usage.
> Converted drivers will make use of this new API and will set NETIF_F_MEMALLOC
> to indicate the driver fully supports this feature.
> 
> When a SOCK_MEMALLOC socket is marked, the device is checked for this feature
> and tries to increase the memalloc pool; if both succeed, the device is marked
> with IFF_MEMALLOC, indicating to {,__}netdev_alloc_skb() that it is OK to dip
> into the memalloc pool.
> 
> Memalloc sk_buff allocations are not done from the SLAB but are done using 
> alloc_pages(). sk_buff::memalloc records this exception so that kfree_skbmem()
> can do the right thing.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Daniel Phillips <phillips@google.com>
> 

How much of this is just building special case support for large allocations
for jumbo frames? Wouldn't it make more sense to just fix those drivers to
do scatter and add the support hooks for that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
